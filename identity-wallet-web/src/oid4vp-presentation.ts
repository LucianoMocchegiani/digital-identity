import { verifySdJwtSignature } from './credential-verification'
import type { VerifiedOid4vpRequest } from './oid4vp-verification'

type StoredCredential = { id: string; label: string; compactSdJwt: string }
export type PresentationOption = { queryId: string; credentialId: string; label: string; claims: Record<string, unknown> }
export type StoredCredentialSummary = { id: string; label: string; format: 'dc+sd-jwt'; vct: string; claims: string[]; verified: boolean }

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function decodeJson(segment: string): Record<string, unknown> {
  if (!/^[\w-]+$/.test(segment)) throw new Error('JWT inválido')
  const base64 = segment.replace(/-/g, '+').replace(/_/g, '/')
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
    if (!/^[\w-]+$/.test(segment)) throw new Error('Disclosure inválido')
    const bytes = Uint8Array.from(atob(segment.replace(/-/g, '+').replace(/_/g, '/').padEnd(Math.ceil(segment.length / 4) * 4, '=')), char => char.charCodeAt(0))
    const disclosure: unknown = JSON.parse(new TextDecoder().decode(bytes))
    if (!Array.isArray(disclosure) || disclosure.length !== 3 || typeof disclosure[1] !== 'string') continue
    const digestBytes = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(segment))
    const digest = btoa(String.fromCharCode(...new Uint8Array(digestBytes))).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
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
