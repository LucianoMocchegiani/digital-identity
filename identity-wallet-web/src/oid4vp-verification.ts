export interface VerifiedOid4vpRequest {
  header: Record<string, unknown>
  payload: Record<string, unknown>
  verifierDid: string
  responseUri: string
  nonce: string
  state?: string
}

const verifierOrigin = 'https://verifier.kuatia.xyz'
const selfIssuedAudience = 'https://self-issued.me/v2'
const maxRequestBytes = 512_000

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function decodeBase64url(value: string): Uint8Array {
  if (!/^[\w-]+$/.test(value)) throw new Error('El Request Object contiene Base64URL inválido.')
  const base64 = value.replace(/-/g, '+').replace(/_/g, '/')
  const binary = atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '='))
  return Uint8Array.from(binary, char => char.charCodeAt(0))
}

function decodeJson(value: string): Record<string, unknown> {
  const parsed: unknown = JSON.parse(new TextDecoder().decode(decodeBase64url(value)))
  if (!isRecord(parsed)) throw new Error('El Request Object contiene JSON inválido.')
  return parsed
}

function expectedVerifier(clientId: string): { clientId: string; did: string; tenant: string } {
  const prefix = 'decentralized_identifier:'
  const did = clientId.startsWith(prefix) ? clientId.slice(prefix.length) : clientId
  const match = /^did:web:verifier\.kuatia\.xyz:([A-Za-z0-9][A-Za-z0-9_-]{0,127})$/.exec(did)
  if (!match) throw new Error('El client_id no identifica un DID web de verifier Kuatia válido.')
  return { clientId, did, tenant: match[1] }
}

export async function verifyOid4vpRequest(compactRequest: string, clientId: string): Promise<VerifiedOid4vpRequest> {
  if (new TextEncoder().encode(compactRequest).byteLength > maxRequestBytes) throw new Error('El Request Object supera el tamaño permitido.')
  const parts = compactRequest.trim().split('.')
  if (parts.length !== 3 || parts.some(part => !part)) throw new Error('El Request Object no es un JWT compacto válido.')

  const expected = expectedVerifier(clientId)
  const header = decodeJson(parts[0])
  const payload = decodeJson(parts[1])
  if (payload.client_id !== expected.clientId || (payload.iss !== undefined && payload.iss !== expected.clientId)) {
    throw new Error('El client_id o issuer del Request Object no coincide con el enlace.')
  }
  if (header.alg !== 'ES256' || typeof header.kid !== 'string' || !header.kid.startsWith(`${expected.did}#`)) {
    throw new Error('El Request Object no está firmado con ES256 por el DID esperado.')
  }
  if (typeof payload.exp !== 'number' || payload.exp <= Date.now() / 1000 || typeof payload.iat !== 'number' || payload.iat > Date.now() / 1000 + 60) {
    throw new Error('El Request Object está vencido o tiene fechas inválidas.')
  }
  if (typeof payload.nonce !== 'string' || !payload.nonce || payload.response_type !== 'vp_token' || payload.response_mode !== 'direct_post') {
    throw new Error('El Request Object no usa un flujo OID4VP compatible.')
  }
  const audiences = typeof payload.aud === 'string' ? [payload.aud] : payload.aud
  if (!Array.isArray(audiences) || !audiences.includes(selfIssuedAudience)) {
    throw new Error('La audiencia del Request Object no corresponde a una wallet OID4VP.')
  }
  if (!isRecord(payload.dcql_query) || !Array.isArray(payload.dcql_query.credentials) || !payload.dcql_query.credentials.length) {
    throw new Error('La PoC solo acepta solicitudes DCQL con credenciales explícitas.')
  }

  if (typeof payload.response_uri !== 'string') throw new Error('El Request Object no declara response_uri.')
  const responseUri = new URL(payload.response_uri)
  if (responseUri.origin !== verifierOrigin || responseUri.username || responseUri.password || responseUri.search || responseUri.hash || responseUri.pathname !== `/openid4vc-flow/${expected.tenant}/authorize`) {
    throw new Error('El response_uri no pertenece al endpoint de autorización de ese verifier Kuatia.')
  }
  if (payload.state !== undefined && (typeof payload.state !== 'string' || !payload.state)) {
    throw new Error('El Request Object contiene un state inválido.')
  }

  const response = await fetch(`${verifierOrigin}/${expected.tenant}/did.json`, {
    credentials: 'omit', cache: 'no-store', redirect: 'error',
  })
  if (!response.ok) throw new Error(`No se pudo obtener el DID document del verifier (HTTP ${response.status}).`)
  const text = await response.text()
  if (new TextEncoder().encode(text).byteLength > maxRequestBytes) throw new Error('El DID document del verifier supera el tamaño permitido.')
  let document: unknown
  try {
    document = JSON.parse(text)
  } catch {
    throw new Error('El verifier devolvió un DID document inválido.')
  }
  if (!isRecord(document) || document.id !== expected.did || !Array.isArray(document.verificationMethod) || !Array.isArray(document.assertionMethod)) {
    throw new Error('El DID document no corresponde al client_id del verifier.')
  }
  const method = document.verificationMethod.find((item: unknown) => isRecord(item) && item.id === header.kid)
  if (!isRecord(method) || method.controller !== expected.did || !document.assertionMethod.includes(method.id) || !isRecord(method.publicKeyJwk)) {
    throw new Error('La clave del Request Object no está autorizada por el DID document.')
  }
  const jwk = method.publicKeyJwk
  if (jwk.kty !== 'EC' || jwk.crv !== 'P-256' || typeof jwk.x !== 'string' || typeof jwk.y !== 'string') {
    throw new Error('El DID document no contiene una clave ES256 válida para el verifier.')
  }
  const key = await crypto.subtle.importKey('jwk', jwk as JsonWebKey, { name: 'ECDSA', namedCurve: 'P-256' }, false, ['verify'])
  const valid = await crypto.subtle.verify(
    { name: 'ECDSA', hash: 'SHA-256' },
    key,
    new Uint8Array(decodeBase64url(parts[2])),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  )
  if (!valid) throw new Error('La firma ES256 del Request Object no es válida.')

  return {
    header,
    payload,
    verifierDid: expected.did,
    responseUri: responseUri.href,
    nonce: payload.nonce,
    ...(typeof payload.state === 'string' ? { state: payload.state } : {}),
  }
}
