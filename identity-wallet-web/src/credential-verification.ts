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

export async function verifySdJwtSignature(
  compactSdJwt: string,
  expectedIssuer?: string,
  expectedVct?: string,
): Promise<void> {
  if (compactSdJwt.length > maxResponseBytes) throw new Error('La credencial supera el tamaño permitido.')
  const issuerJwt = compactSdJwt.split('~', 1)[0]
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
}
