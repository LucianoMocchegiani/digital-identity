import type { WalletRequest } from './protocol-link'

export type ResolvedResource =
  | {
      kind: 'issue'
      credentialIssuer: string
      credentialEndpoint: string
      tokenEndpoint: string | null
      credentialConfigurationIds: string[]
      supportedConfigurations: Record<string, Record<string, unknown>>
      hasPreAuthorizedCode: boolean
      preAuthorizedCode: string | null
      txCode?: { length?: number; inputMode?: string; description?: string }
    }
  | { kind: 'present'; compactRequest: string; header: Record<string, unknown>; payload: Record<string, unknown> }

const maxResponseBytes = 512_000
const issuerOrigin = 'https://issuer.kuatia.xyz'
const preAuthorizedGrant = 'urn:ietf:params:oauth:grant-type:pre-authorized_code'

function isRecord(value: unknown): value is Record<string, unknown> {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value)
}

function decodeJwtPart(part: string): Record<string, unknown> {
  const base64 = part.replace(/-/g, '+').replace(/_/g, '/')
  const bytes = Uint8Array.from(atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '=')), char => char.charCodeAt(0))
  const value: unknown = JSON.parse(new TextDecoder().decode(bytes))
  if (!isRecord(value)) throw new Error('El Request Object no contiene un objeto JSON válido.')
  return value
}

function assertProtocolEndpoint(request: WalletRequest): URL {
  const url = new URL(request.endpoint)
  const origin = request.kind === 'issue' ? issuerOrigin : 'https://verifier.kuatia.xyz'
  const path = request.kind === 'issue'
    ? /^\/openid4vc-flow\/[^/]+\/offers\/[^/]+\/?$/
    : /^\/openid4vc-flow\/[^/]+\/authorize\/[^/]+\/?$/
  if (url.origin !== origin || url.username || url.password || url.hash || !path.test(url.pathname)) {
    throw new Error('El endpoint protocolario no es válido.')
  }
  return url
}

async function getText(url: URL, accept: string): Promise<string> {
  const response = await fetch(url, {
    method: 'GET',
    headers: { Accept: accept },
    credentials: 'omit',
    cache: 'no-store',
    redirect: 'error',
  })
  if (!response.ok) throw new Error(`El servidor rechazó la solicitud (HTTP ${response.status}).`)
  const text = await response.text()
  if (new TextEncoder().encode(text).byteLength > maxResponseBytes) throw new Error('La respuesta supera el tamaño permitido.')
  return text
}

function trustedIssuerEndpoint(value: unknown, issuer: URL, name: string): string {
  if (typeof value !== 'string') throw new Error(`La metadata no incluye ${name}.`)
  const endpoint = new URL(value)
  const issuerPath = issuer.pathname.replace(/\/$/, '')
  if (endpoint.origin !== issuer.origin || endpoint.username || endpoint.password || endpoint.hash || !endpoint.pathname.startsWith(`${issuerPath}/`)) {
    throw new Error(`El endpoint ${name} no pertenece al issuer esperado.`)
  }
  return endpoint.href
}

async function resolveTokenEndpoint(metadata: Record<string, unknown>, issuer: URL): Promise<string | null> {
  if (metadata.token_endpoint) return trustedIssuerEndpoint(metadata.token_endpoint, issuer, 'token_endpoint')

  const issuerPath = issuer.pathname.replace(/\/$/, '')
  for (const suffix of ['/.well-known/oauth-authorization-server', '/.well-known/openid-configuration']) {
    const discoveryUrl = new URL(`${issuerPath}${suffix}`, issuer.origin)
    try {
      const discovery: unknown = JSON.parse(await getText(discoveryUrl, 'application/json'))
      if (!isRecord(discovery)) continue
      if (typeof discovery.issuer === 'string' && discovery.issuer.replace(/\/$/, '') !== issuer.href.replace(/\/$/, '')) continue
      return trustedIssuerEndpoint(discovery.token_endpoint, issuer, 'token_endpoint')
    } catch {
      // Try the next standard discovery document; do not hide a missing token endpoint.
    }
  }
  return null
}

async function resolveCredentialOffer(endpoint: URL): Promise<ResolvedResource> {
  const value: unknown = JSON.parse(await getText(endpoint, 'application/json'))
  if (!isRecord(value) || typeof value.credential_issuer !== 'string' || !Array.isArray(value.credential_configuration_ids) || !isRecord(value.grants)) {
    throw new Error('La oferta no tiene el formato OID4VCI esperado.')
  }

  const credentialConfigurationIds = value.credential_configuration_ids
  if (!credentialConfigurationIds.length || !credentialConfigurationIds.every(id => typeof id === 'string' && id.length > 0) || new Set(credentialConfigurationIds).size !== credentialConfigurationIds.length) {
    throw new Error('La oferta no indica configuraciones de credencial válidas y únicas.')
  }

  const issuer = new URL(value.credential_issuer)
  const tenantPath = endpoint.pathname.split('/').slice(0, 3).join('/')
  if (issuer.origin !== issuerOrigin || issuer.username || issuer.password || issuer.search || issuer.hash || issuer.pathname.replace(/\/$/, '') !== tenantPath) {
    throw new Error('El issuer de la oferta no coincide con el tenant de Kuatia esperado.')
  }

  const metadataUrl = new URL(`${issuer.pathname.replace(/\/$/, '')}/.well-known/openid-credential-issuer`, issuer.origin)
  const metadata: unknown = JSON.parse(await getText(metadataUrl, 'application/json'))
  if (!isRecord(metadata) || typeof metadata.credential_issuer !== 'string' || !isRecord(metadata.credential_configurations_supported)) {
    throw new Error('La metadata del issuer no tiene el formato OID4VCI esperado.')
  }
  if (metadata.credential_issuer.replace(/\/$/, '') !== issuer.href.replace(/\/$/, '')) {
    throw new Error('La metadata anuncia un issuer distinto al de la oferta.')
  }

  const configurations = metadata.credential_configurations_supported
  const supportedConfigurations: Record<string, Record<string, unknown>> = {}
  for (const id of credentialConfigurationIds) {
    const configuration = configurations[id]
    if (!isRecord(configuration)) throw new Error(`El issuer no anuncia la configuración ${id}.`)
    supportedConfigurations[id] = configuration
  }

  const grants = value.grants
  const grant = grants[preAuthorizedGrant] ?? grants['pre-authorized_code']
  const hasPreAuthorizedCode = isRecord(grant) && typeof grant['pre-authorized_code'] === 'string' && grant['pre-authorized_code'].length > 0
  const preAuthorizedCode = hasPreAuthorizedCode ? grant['pre-authorized_code'] as string : null
  const txCode = isRecord(grant) && isRecord(grant.tx_code) ? {
    length: typeof grant.tx_code.length === 'number' ? grant.tx_code.length : undefined,
    inputMode: typeof grant.tx_code.input_mode === 'string' ? grant.tx_code.input_mode : undefined,
    description: typeof grant.tx_code.description === 'string' ? grant.tx_code.description : undefined,
  } : undefined

  return {
    kind: 'issue',
    credentialIssuer: issuer.href,
    credentialEndpoint: trustedIssuerEndpoint(metadata.credential_endpoint, issuer, 'credential_endpoint'),
    tokenEndpoint: hasPreAuthorizedCode ? await resolveTokenEndpoint(metadata, issuer) : null,
    credentialConfigurationIds,
    supportedConfigurations,
    hasPreAuthorizedCode,
    preAuthorizedCode,
    ...(txCode ? { txCode } : {}),
  }
}

export async function resolveProtocolResource(request: WalletRequest): Promise<ResolvedResource> {
  const endpoint = assertProtocolEndpoint(request)
  if (request.kind === 'issue') return resolveCredentialOffer(endpoint)

  const text = await getText(endpoint, 'application/json, application/oauth-authz-req+jwt')
  const parts = text.trim().split('.')
  if (parts.length !== 3 || parts.some(part => !part)) throw new Error('El verifier no devolvió un Request Object JWT compacto válido.')
  return { kind: 'present', compactRequest: text.trim(), header: decodeJwtPart(parts[0]), payload: decodeJwtPart(parts[1]) }
}
