import { verifySdJwtSignature } from './credential-verification'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

type StoredCredential = { id: string; label: string; compactSdJwt: string }
export type PresentationOption = { queryId: string; credentialId: string; label: string; claims: Record<string, unknown> }
export type StoredCredentialSummary = { id: string; label: string; format: 'dc+sd-jwt'; vct: string; claims: string[]; verified: boolean }

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function decodeJson(segment: string): Record<string, unknown> {
  if (!/^[A-Za-z0-9_-]+$/.test(segment)) throw new Error('JWT inválido')
  const base64 = segment.replaceAll('-', '+').replaceAll('_', '/')
  const bytes = Uint8Array.from(atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '=')), char => char.charCodeAt(0))
  const value: unknown = JSON.parse(new TextDecoder().decode(bytes))
  if (!isRecord(value)) throw new Error('JWT inválido')
  return value
}

function requestedClaims(query: Record<string, unknown>): string[] | null {
  if (!Array.isArray(query.claims) || !query.claims.length) return null
  // shortcut: solo previsualiza claims de nivel superior, cuando haya rutas DCQL anidadas se implementará su resolución.
  const paths = query.claims.map(claim => isRecord(claim) && Array.isArray(claim.path) && claim.path.length === 1 && typeof claim.path[0] === 'string' ? claim.path[0] : null)
  return paths.every((path): path is string => path !== null) ? paths : null
}

async function disclosedTopLevelClaims(segments: string[], references: unknown): Promise<Record<string, unknown>> {
  const claims: Record<string, unknown> = {}
  if (!Array.isArray(references)) return claims
  const topLevelDigests = new Set(references.filter((digest): digest is string => typeof digest === 'string'))
  for (const segment of segments) {
    if (!/^[A-Za-z0-9_-]+$/.test(segment)) throw new Error('Disclosure inválido')
    const bytes = Uint8Array.from(atob(segment.replaceAll('-', '+').replaceAll('_', '/').padEnd(Math.ceil(segment.length / 4) * 4, '=')), char => char.charCodeAt(0))
    const disclosure: unknown = JSON.parse(new TextDecoder().decode(bytes))
    if (!Array.isArray(disclosure) || disclosure.length !== 3 || typeof disclosure[1] !== 'string') continue
    const digestBytes = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(segment))
    const digest = btoa(String.fromCharCode(...new Uint8Array(digestBytes))).replace(/=/g, '').replaceAll('+', '-').replaceAll('/', '_')
    if (!topLevelDigests.has(digest)) continue
    if (Object.hasOwn(claims, disclosure[1])) throw new Error('Disclosure duplicado')
    claims[disclosure[1]] = disclosure[2]
  }
  return claims
}

const reservedClaims = new Set(['iss', 'iat', 'exp', 'nbf', 'vct', '_sd', '_sd_alg', 'cnf', 'status', 'aud', 'sub', 'jti'])

export async function inspectStoredCredentials(credentials: StoredCredential[]): Promise<StoredCredentialSummary[]> {
  return Promise.all(credentials.map(async credential => {
    let vct = 'No disponible'
    let claims: string[] = []
    try {
      const segments = credential.compactSdJwt.split('~')
      if (segments.at(-1) === '') segments.pop()
      const jwtParts = (segments.shift() ?? '').split('.')
      if (jwtParts.length !== 3) throw new Error('JWT inválido')
      const payload = decodeJson(jwtParts[1])
      if (typeof payload.vct === 'string') vct = payload.vct
      const disclosed = await disclosedTopLevelClaims(segments, payload._sd)
      claims = [...new Set([
        ...Object.keys(payload).filter(key => !reservedClaims.has(key) && !key.startsWith('_')),
        ...Object.keys(disclosed),
      ])].sort()
    } catch {
      // Keep the record visible, but never claim metadata could not be decoded.
    }
    const verified = await verifySdJwtSignature(credential.compactSdJwt).then(() => true).catch(cause => {
      // Log only the local record ID and generic verifier error; never log the credential or its claims.
      console.warn('No se pudo verificar la firma de una credencial guardada.', {
        credentialId: credential.id,
        reason: cause instanceof Error ? cause.message : 'error desconocido',
      })
      return false
    })
    return { id: credential.id, label: credential.label, format: 'dc+sd-jwt' as const, vct, claims, verified }
  }))
}

export async function findPresentationOptions(
  request: VerifiedOid4vpRequest,
  credentials: StoredCredential[],
  holderPublicJwk: JsonWebKey,
): Promise<PresentationOption[]> {
  const dcql = request.payload.dcql_query
  if (!isRecord(dcql) || !Array.isArray(dcql.credentials)) return []
  const options: PresentationOption[] = []
  for (const query of dcql.credentials) {
    if (!isRecord(query) || typeof query.id !== 'string' || query.format !== 'dc+sd-jwt') continue
    const claimsRequested = requestedClaims(query)
    const metadata = query.meta
    if (!claimsRequested || !isRecord(metadata) || !Array.isArray(metadata.vct_values)) continue
    const vcts = metadata.vct_values.filter((value): value is string => typeof value === 'string')
    for (const credential of credentials) {
      for (const vct of vcts) {
        try {
          await verifySdJwtSignature(credential.compactSdJwt, undefined, vct)
          const segments = credential.compactSdJwt.split('~')
          if (segments.at(-1) === '') segments.pop()
          const jwtParts = segments.shift()?.split('.') ?? []
          if (jwtParts.length !== 3) continue
          const payload = decodeJson(jwtParts[1])
          const holderJwk = isRecord(payload.cnf) ? payload.cnf.jwk : undefined
          if (!isRecord(holderJwk) || holderJwk.kty !== 'EC' || holderJwk.crv !== 'P-256' ||
              typeof holderJwk.x !== 'string' || typeof holderJwk.y !== 'string' ||
              holderJwk.x !== holderPublicJwk.x || holderJwk.y !== holderPublicJwk.y ||
              holderPublicJwk.kty !== 'EC' || holderPublicJwk.crv !== 'P-256') continue
          const disclosed = await disclosedTopLevelClaims(segments, payload._sd)
          if (Object.keys(disclosed).some(key => Object.hasOwn(payload, key))) continue
          const available = { ...payload, ...disclosed }
          if (payload.vct !== vct || !claimsRequested.every(path => Object.hasOwn(available, path))) continue
          options.push({
            queryId: query.id,
            credentialId: credential.id,
            label: credential.label,
            claims: Object.fromEntries(claimsRequested.map(path => [path, available[path]])),
          })
          break
        } catch {
          // Credentials that fail verification or cannot satisfy this exact query are not offered.
        }
      }
    }
  }
  return options
}

function encodeBase64url(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes)).replace(/=/g, '').replaceAll('+', '-').replaceAll('/', '_')
}

export async function sendOid4vpPresentation(
  request: VerifiedOid4vpRequest,
  option: PresentationOption,
  credential: StoredCredential,
  holderKey: { privateKey: CryptoKey; publicJwk: JsonWebKey },
): Promise<void> {
  if (credential.id !== option.credentialId) throw new Error('La credencial seleccionada ya no está disponible.')
  const dcql = request.payload.dcql_query
  if (!isRecord(dcql) || !Array.isArray(dcql.credentials)) throw new Error('La consulta DCQL no es válida.')
  const query = dcql.credentials.find(item => isRecord(item) && item.id === option.queryId)
  if (!isRecord(query) || query.format !== 'dc+sd-jwt') throw new Error('La consulta de credencial seleccionada no es válida.')
  const claimsRequested = requestedClaims(query)
  const metadata = query.meta
  if (!claimsRequested || !isRecord(metadata) || !Array.isArray(metadata.vct_values)) throw new Error('La consulta solicita claims no compatibles con esta wallet.')
  if (Object.keys(option.claims).length !== claimsRequested.length || claimsRequested.some(name => !Object.hasOwn(option.claims, name))) {
    throw new Error('La selección no coincide con los claims solicitados.')
  }

  const segments = credential.compactSdJwt.split('~')
  if (segments.at(-1) === '') segments.pop()
  const issuerJwt = segments.shift() ?? ''
  const jwtParts = issuerJwt.split('.')
  if (jwtParts.length !== 3) throw new Error('La credencial no contiene un JWT compacto válido.')
  const payload = decodeJson(jwtParts[1])
  if (typeof payload.vct !== 'string' || !metadata.vct_values.includes(payload.vct)) throw new Error('El VCT de la credencial no satisface la consulta.')
  await verifySdJwtSignature(credential.compactSdJwt, undefined, payload.vct)

  const holderJwk = isRecord(payload.cnf) ? payload.cnf.jwk : undefined
  if (!isRecord(holderJwk) || holderJwk.kty !== 'EC' || holderJwk.crv !== 'P-256' ||
      holderJwk.x !== holderKey.publicJwk.x || holderJwk.y !== holderKey.publicJwk.y ||
      holderKey.publicJwk.kty !== 'EC' || holderKey.publicJwk.crv !== 'P-256') {
    throw new Error('La credencial no está vinculada a la clave local de holder.')
  }

  const disclosures: string[] = []
  const disclosedNames = new Set<string>()
  const signedDigests = new Set(Array.isArray(payload._sd) ? payload._sd.filter((value): value is string => typeof value === 'string') : [])
  for (const segment of segments) {
    if (!/^[A-Za-z0-9_-]+$/.test(segment)) throw new Error('Disclosure inválido')
    const parsed: unknown = JSON.parse(new TextDecoder().decode(Uint8Array.from(
      atob(segment.replaceAll('-', '+').replaceAll('_', '/').padEnd(Math.ceil(segment.length / 4) * 4, '=')),
      char => char.charCodeAt(0),
    )))
    if (!Array.isArray(parsed) || parsed.length !== 3 || typeof parsed[1] !== 'string') continue
    const digest = encodeBase64url(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(segment))))
    if (!signedDigests.has(digest) || !claimsRequested.includes(parsed[1])) continue
    if (disclosedNames.has(parsed[1]) || Object.hasOwn(payload, parsed[1])) throw new Error('La credencial contiene claims duplicados.')
    disclosedNames.add(parsed[1])
    disclosures.push(segment)
  }

  const plaintextClaims = Object.keys(payload).filter(key => !reservedClaims.has(key) && !key.startsWith('_'))
  if (plaintextClaims.some(name => !claimsRequested.includes(name)) ||
      claimsRequested.some(name => !Object.hasOwn(payload, name) && !disclosedNames.has(name))) {
    throw new Error('La credencial no puede revelar únicamente los claims solicitados.')
  }

  const sdJwt = [issuerJwt, ...disclosures].join('~')
  const clientId = request.payload.client_id
  if (typeof clientId !== 'string' || !clientId) throw new Error('El Request Object no declara un client_id válido.')
  const header = encodeBase64url(new TextEncoder().encode(JSON.stringify({ typ: 'kb+jwt', alg: 'ES256' })))
  const sdHash = encodeBase64url(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(`${sdJwt}~`))))
  const body = encodeBase64url(new TextEncoder().encode(JSON.stringify({ aud: clientId, nonce: request.nonce, iat: Math.floor(Date.now() / 1000), sd_hash: sdHash })))
  const signingInput = `${header}.${body}`
  const signature = encodeBase64url(new Uint8Array(await crypto.subtle.sign(
    { name: 'ECDSA', hash: 'SHA-256' }, holderKey.privateKey, new TextEncoder().encode(signingInput),
  )))
  const vpToken = JSON.stringify({ [option.queryId]: [`${sdJwt}~${signingInput}.${signature}`] })
  const form = new URLSearchParams({ vp_token: vpToken })
  if (request.state) form.set('state', request.state)
  const response = await fetch(request.responseUri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: form,
    credentials: 'omit',
    cache: 'no-store',
    redirect: 'error',
  })
  if (!response.ok) throw new Error(`El verifier rechazó la presentación (HTTP ${response.status}).`)
}
