import type { WalletRequest } from './protocol-link'

export type ResolvedResource =
  | { kind: 'issue'; credentialOffer: Record<string, unknown> }
  | { kind: 'present'; compactRequest: string; header: Record<string, unknown>; payload: Record<string, unknown> }

const maxResponseBytes = 512_000

function decodeJwtPart(part: string): Record<string, unknown> {
  const base64 = part.replace(/-/g, '+').replace(/_/g, '/')
  const bytes = Uint8Array.from(atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '=')), char => char.charCodeAt(0))
  const value: unknown = JSON.parse(new TextDecoder().decode(bytes))
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error('El Request Object no contiene un objeto JSON válido.')
  return value as Record<string, unknown>
}

function assertProtocolEndpoint(request: WalletRequest): URL {
  const url = new URL(request.endpoint)
  const origin = request.kind === 'issue' ? 'https://issuer.kuatia.xyz' : 'https://verifier.kuatia.xyz'
  const path = request.kind === 'issue'
    ? /^\/openid4vc-flow\/[^/]+\/offers\/[^/]+\/?$/
    : /^\/openid4vc-flow\/[^/]+\/authorize\/[^/]+\/?$/
  if (url.origin !== origin || url.username || url.password || url.hash || !path.test(url.pathname)) {
    throw new Error('El endpoint protocolario no es válido.')
  }
  return url
}

export async function resolveProtocolResource(request: WalletRequest): Promise<ResolvedResource> {
  const response = await fetch(assertProtocolEndpoint(request), {
    method: 'GET',
    headers: { Accept: 'application/json, application/oauth-authz-req+jwt' },
    credentials: 'omit',
    cache: 'no-store',
    redirect: 'error',
  })
  if (!response.ok) throw new Error(`El servidor rechazó la solicitud (HTTP ${response.status}).`)

  const text = await response.text()
  if (new TextEncoder().encode(text).byteLength > maxResponseBytes) throw new Error('La respuesta supera el tamaño permitido.')

  if (request.kind === 'issue') {
    const credentialOffer: unknown = JSON.parse(text)
    if (!credentialOffer || typeof credentialOffer !== 'object' || Array.isArray(credentialOffer)) {
      throw new Error('La oferta de credenciales no tiene un formato JSON válido.')
    }
    return { kind: 'issue', credentialOffer: credentialOffer as Record<string, unknown> }
  }

  const parts = text.trim().split('.')
  if (parts.length !== 3 || parts.some(part => !part)) throw new Error('El verifier no devolvió un Request Object JWT compacto válido.')
  return { kind: 'present', compactRequest: text.trim(), header: decodeJwtPart(parts[0]), payload: decodeJwtPart(parts[1]) }
}
