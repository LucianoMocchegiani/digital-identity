/**
 * Cliente HTTP same-origin hacia issuer/verifier (consola Credenciales).
 *
 * Rewrites: `/api/issuer/*` → ISSUER_URL, `/api/verifier/*` → VERIFIER_URL.
 * Auth: header `X-API-Key` (la key la pega el usuario; no viene de billing).
 */
import { ApiError } from './client'

export type ProtocolService = 'issuer' | 'verifier'

type ProtocolOptions = {
  apiKey: string
  method?: string
  body?: unknown
}

/**
 * Fetch tipado hacia issuer o verifier vía rewrite same-origin.
 * @param service `issuer` | `verifier`
 * @param path Ruta absoluta del servicio (ej. `/v1/issuers/acme/openid4vc/offer`)
 */
export async function protocolFetch<T>(
  service: ProtocolService,
  path: string,
  options: ProtocolOptions,
): Promise<T> {
  const headers: Record<string, string> = {
    Accept: 'application/json',
    'X-API-Key': options.apiKey,
  }

  if (options.body !== undefined) {
    headers['Content-Type'] = 'application/json'
  }

  const base = service === 'issuer' ? '/api/issuer' : '/api/verifier'
  const normalized = path.startsWith('/') ? path : `/${path}`

  const res = await fetch(`${base}${normalized}`, {
    method: options.method ?? (options.body !== undefined ? 'POST' : 'GET'),
    headers,
    body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
  })

  const text = await res.text()
  const data = text ? safeJson(text) : null

  if (!res.ok) {
    const raw =
      data && typeof data === 'object' && data !== null && 'message' in data
        ? (data as { message: unknown }).message
        : null
    const message = Array.isArray(raw)
      ? raw.map(String).join(', ')
      : typeof raw === 'string'
        ? raw
        : res.statusText || 'Error de API'
    throw new ApiError(message, res.status, data)
  }

  return data as T
}

function safeJson(text: string): unknown {
  try {
    return JSON.parse(text)
  } catch {
    return text
  }
}

/** Body mínimo de oferta OID4VCI (alineado a docs `/docs/emitir`). */
export type OfferBody = {
  credentialConfigurationId: string
  vct?: string
  claims?: Record<string, unknown>
  disclosureFrame?: Record<string, unknown>
  claimsDisplay?: Record<string, unknown>
  preAuthorizedCode?: string
}

export type OfferResponse = {
  offerUri: string
  issuanceSessionId: string
}

/** Crea una oferta de emisión. */
export function createOffer(walletId: string, apiKey: string, body: OfferBody) {
  return protocolFetch<OfferResponse>(
    'issuer',
    `/v1/issuers/${encodeURIComponent(walletId)}/openid4vc/offer`,
    { apiKey, body },
  )
}

/** Body de request OID4VP. */
export type RequestBody = {
  dcqlQuery?: unknown
  presentationDefinition?: unknown
  responseMode?: string
  requestSignerMethod?: 'did' | 'none' | 'x5c'
  authorizationResponseRedirectUri?: string
}

export type RequestResponse = {
  requestUri: string
  verificationSessionId: string
}

/** Crea una solicitud de presentación. */
export function createRequest(walletId: string, apiKey: string, body: RequestBody) {
  return protocolFetch<RequestResponse>(
    'verifier',
    `/v1/verifiers/${encodeURIComponent(walletId)}/openid4vc/request`,
    { apiKey, body },
  )
}

/** Sesión de verificación (poll). */
export type VerificationSession = {
  id?: string
  state?: string
  status?: string
  authorizationResponsePayload?: unknown
  error?: unknown
  [key: string]: unknown
}

/** Obtiene el estado de una sesión OID4VP. */
export function getVerificationSession(
  walletId: string,
  sessionId: string,
  apiKey: string,
) {
  return protocolFetch<VerificationSession>(
    'verifier',
    `/v1/verifiers/${encodeURIComponent(walletId)}/openid4vc/session/${encodeURIComponent(sessionId)}`,
    { apiKey, method: 'GET' },
  )
}

/** ¿La sesión ya terminó (éxito o error)? */
export function isTerminalVerificationState(state: string | undefined | null): boolean {
  if (!state) return false
  const s = state.toLowerCase().replace(/_/g, '-')
  return (
    s === 'done' ||
    s === 'error' ||
    s === 'failed' ||
    s === 'responseverified' ||
    s === 'response-verified' ||
    s.includes('error') ||
    s.includes('verified') ||
    s.includes('abandoned') ||
    s.includes('expired')
  )
}

/** ¿Éxito de verificación? */
export function isSuccessfulVerificationState(state: string | undefined | null): boolean {
  if (!state) return false
  const s = state.toLowerCase().replace(/_/g, '-')
  return (
    s === 'done' ||
    s === 'responseverified' ||
    s === 'response-verified' ||
    (s.includes('verified') && !s.includes('error'))
  )
}
