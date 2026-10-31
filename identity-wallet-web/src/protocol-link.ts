export type WalletRequest =
  | { kind: 'issue'; endpoint: string }
  | { kind: 'present'; endpoint: string; clientId: string }

const issuerOrigin = 'https://issuer.kuatia.xyz'
const verifierOrigin = 'https://verifier.kuatia.xyz'

function protocolEndpoint(value: string, kind: WalletRequest['kind']): string {
  let url: URL
  try {
    url = new URL(value)
  } catch {
    throw new Error('El enlace del protocolo no es una URL válida.')
  }

  const expectedOrigin = kind === 'issue' ? issuerOrigin : verifierOrigin
  const expectedPath = kind === 'issue'
    ? /^\/openid4vc-flow\/[^/]+\/offers\/[^/]+\/?$/
    : /^\/openid4vc-flow\/[^/]+\/authorize\/[^/]+\/?$/

  if (
    url.origin !== expectedOrigin ||
    url.username ||
    url.password ||
    url.hash ||
    !expectedPath.test(url.pathname)
  ) {
    throw new Error('El enlace no pertenece a un endpoint OpenID4VC esperado de Kuatia.')
  }
  return url.href
}

function fromParameters(params: URLSearchParams, kind: 'issue' | 'present'): WalletRequest {
  const endpointParameter = kind === 'issue' ? 'credential_offer_uri' : 'request_uri'
  const endpoint = params.get(endpointParameter)
  if (!endpoint) throw new Error(`Falta el parámetro ${endpointParameter}.`)

  if (kind === 'issue') {
    return { kind, endpoint: protocolEndpoint(endpoint, kind) }
  }

  const clientId = params.get('client_id')
  if (!clientId?.startsWith('decentralized_identifier:did:web:verifier.kuatia.xyz:')) {
    throw new Error('El client_id no corresponde a un verifier de Kuatia.')
  }
  return { kind, endpoint: protocolEndpoint(endpoint, kind), clientId }
}

export function parseIncomingLink(value: string): WalletRequest {
  let url: URL
  try {
    url = new URL(value)
  } catch {
    throw new Error('El enlace recibido no es válido.')
  }

  if (url.protocol === 'openid-credential-offer:') {
    return fromParameters(url.searchParams, 'issue')
  }
  if (url.protocol === 'openid4vp:') {
    return fromParameters(url.searchParams, 'present')
  }
  if (url.protocol === 'https:' && url.hostname === 'wallet.kuatia.xyz') {
    if (url.pathname === '/issue') return fromParameters(url.searchParams, 'issue')
    if (url.pathname === '/present') return fromParameters(url.searchParams, 'present')
  }
  throw new Error('Enlace no reconocido. Abrí una oferta o solicitud HTTPS de Kuatia.')
}

export function parseCurrentPage(pathname: string, search: string): WalletRequest | null {
  if (pathname !== '/issue' && pathname !== '/present') return null
  const kind = pathname.slice(1) as 'issue' | 'present'
  return fromParameters(new URLSearchParams(search), kind)
}
