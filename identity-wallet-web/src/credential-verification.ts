const issuerOrigin = 'https://issuer.kuatia.xyz'
const maxResponseBytes = 512_000

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function decodeBase64url(value: string): Uint8Array {
  if (!/^[\w-]+$/.test(value)) throw new Error('La credencial contiene Base64URL inválido.')
  const base64 = value.replace(/-/g, '+').replace(/_/g, '/')
  const binary = atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '='))
  return Uint8Array.from(binary, char => char.charCodeAt(0))
}

function decodeJson(value: string): Record<string, unknown> {
  const decoded: unknown = JSON.parse(new TextDecoder().decode(decodeBase64url(value)))
  if (!isRecord(decoded)) throw new Error('La credencial contiene una sección JWT inválida.')
  return decoded
}

function issuerContext(value: unknown): { issuer: string; tenant: string; did: string } {
  if (typeof value !== 'string') throw new Error('La credencial no declara un issuer válido.')
  const didMatch = /^did:web:issuer\.kuatia\.xyz:([^:/?#]+)$/.exec(value)
  const issuer = didMatch ? `${issuerOrigin}/openid4vc-flow/${didMatch[1]}` : value
  const url = new URL(issuer)
  const tenantMatch = /^\/openid4vc-flow\/([^/]+)\/?$/.exec(url.pathname)
  if (url.origin !== issuerOrigin || url.username || url.password || url.search || url.hash || !tenantMatch) {
    throw new Error('El issuer de la credencial no pertenece a un tenant esperado de Kuatia.')
  }
  const tenant = tenantMatch[1]
  return { issuer: `${issuerOrigin}/openid4vc-flow/${tenant}`, tenant, did: `did:web:issuer.kuatia.xyz:${tenant}` }
}

function disclosureReferences(value: unknown): Set<string> {
  const references = new Set<string>()
  const pending = [value]
  while (pending.length) {
    const current = pending.pop()
    if (Array.isArray(current)) {
      pending.push(...current)
    } else if (isRecord(current)) {
      if (current._sd_alg !== undefined && current._sd_alg !== 'sha-256') {
        throw new Error('La credencial usa un algoritmo de disclosures no compatible.')
      }
      if (current._sd !== undefined) {
        if (!Array.isArray(current._sd)) throw new Error('La credencial contiene referencias SD-JWT inválidas.')
        for (const digest of current._sd) {
          if (typeof digest !== 'string' || !/^[\w-]{43}$/.test(digest) || references.has(digest)) {
            throw new Error('La credencial contiene referencias SD-JWT inválidas o duplicadas.')
          }
          references.add(digest)
        }
      }
      for (const [key, child] of Object.entries(current)) {
        if (key === '...') {
          if (typeof child !== 'string' || !/^[\w-]{43}$/.test(child) || references.has(child)) {
            throw new Error('La credencial contiene una referencia SD-JWT de array inválida.')
          }
          references.add(child)
        } else if (key !== '_sd') {
          pending.push(child)
        }
      }
    }
  }
  return references
}

async function verifyDisclosures(payload: Record<string, unknown>, encodedDisclosures: string[]): Promise<void> {
  const references = disclosureReferences(payload)
  const pending = new Map<string, unknown>()
  for (const encoded of encodedDisclosures) {
    const parsed: unknown = JSON.parse(new TextDecoder().decode(decodeBase64url(encoded)))
    if (!Array.isArray(parsed) || (parsed.length !== 2 && parsed.length !== 3) || typeof parsed[0] !== 'string' || !parsed[0] || (parsed.length === 3 && (typeof parsed[1] !== 'string' || !parsed[1]))) {
      throw new Error('La credencial contiene un disclosure SD-JWT inválido.')
    }
    const digestBytes = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(encoded))
    const digest = btoa(String.fromCharCode(...new Uint8Array(digestBytes))).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
    if (pending.has(digest)) throw new Error('La credencial contiene disclosures duplicados.')
    pending.set(digest, parsed[parsed.length - 1])
  }

  let resolved = true
  while (pending.size && resolved) {
    resolved = false
    for (const [digest, value] of pending) {
      if (!references.delete(digest)) continue
      pending.delete(digest)
      for (const nested of disclosureReferences(value)) {
        if (references.has(nested)) throw new Error('La credencial contiene referencias SD-JWT duplicadas.')
        references.add(nested)
      }
      resolved = true
    }
  }
  if (pending.size) throw new Error('Un disclosure SD-JWT no coincide con los hashes firmados por el issuer.')
}

export async function verifySdJwtSignature(
  compactSdJwt: string,
  expectedIssuer?: string,
  expectedVct?: string,
): Promise<void> {
  if (compactSdJwt.length > maxResponseBytes) throw new Error('La credencial supera el tamaño permitido.')
  const segments = compactSdJwt.split('~')
  if (segments.at(-1) === '') segments.pop()
  if (segments.some(segment => !segment)) throw new Error('La credencial contiene segmentos SD-JWT vacíos.')
  const issuerJwt = segments.shift() ?? ''
  const parts = issuerJwt.split('.')
  if (parts.length !== 3 || parts.some(part => !part)) throw new Error('La credencial no contiene un JWT compacto válido.')

  const header = decodeJson(parts[0])
  const payload = decodeJson(parts[1])
  if (header.alg !== 'ES256' || typeof header.kid !== 'string') throw new Error('La credencial no identifica una firma ES256 verificable.')
  const context = issuerContext(expectedIssuer ?? payload.iss)
  if (payload.iss !== context.issuer && payload.iss !== context.did) throw new Error('El issuer firmado no coincide con el issuer esperado.')
  if (expectedIssuer && issuerContext(expectedIssuer).did !== context.did) throw new Error('La credencial pertenece a otro issuer.')
  if (expectedVct && payload.vct !== expectedVct) throw new Error('El VCT firmado no coincide con la configuración ofrecida.')
  if (typeof payload.exp === 'number' && payload.exp <= Date.now() / 1000) throw new Error('La credencial está vencida.')
  if (typeof payload.nbf === 'number' && payload.nbf > Date.now() / 1000) throw new Error('La credencial todavía no es válida.')

  // Kuatia publica el DID de cada tenant en esta ruta.
  const didUrl = `${issuerOrigin}/${context.tenant}/did.json`
  const response = await fetch(didUrl, { credentials: 'omit', cache: 'no-store', redirect: 'error' })
  if (!response.ok) throw new Error(`No se pudo obtener el DID document del issuer (HTTP ${response.status}).`)
  const text = await response.text()
  if (new TextEncoder().encode(text).byteLength > maxResponseBytes) throw new Error('El DID document supera el tamaño permitido.')
  let document: unknown
  try {
    document = JSON.parse(text)
  } catch {
    throw new Error('El issuer devolvió un DID document inválido.')
  }
  if (!isRecord(document) || document.id !== context.did || !Array.isArray(document.verificationMethod) || !Array.isArray(document.assertionMethod)) {
    throw new Error('El DID document no coincide con el issuer de la credencial.')
  }
  const method = document.verificationMethod.find((item: unknown) =>
    isRecord(item) && (item.id === header.kid || (isRecord(item.publicKeyJwk) && item.publicKeyJwk.kid === header.kid)),
  )
  if (!isRecord(method) || method.controller !== context.did || !document.assertionMethod.includes(method.id) || !isRecord(method.publicKeyJwk)) {
    throw new Error('La clave de firma no está autorizada por el DID document del issuer.')
  }
  const jwk = method.publicKeyJwk
  if (jwk.kty !== 'EC' || jwk.crv !== 'P-256' || typeof jwk.x !== 'string' || typeof jwk.y !== 'string') {
    throw new Error('El DID document no contiene una clave pública ES256 válida.')
  }

  const key = await crypto.subtle.importKey('jwk', jwk as JsonWebKey, { name: 'ECDSA', namedCurve: 'P-256' }, false, ['verify'])
  const valid = await crypto.subtle.verify(
    { name: 'ECDSA', hash: 'SHA-256' },
    key,
    new Uint8Array(decodeBase64url(parts[2])),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  )
  if (!valid) throw new Error('La firma ES256 de la credencial no es válida.')
  await verifyDisclosures(payload, segments)
}
