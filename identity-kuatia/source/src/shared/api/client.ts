/**
 * Cliente HTTP same-origin hacia billing.
 *
 * Todas las llamadas pasan por el rewrite de Next (`/api/billing` → servicio billing).
 * Por defecto adjunta el Bearer de sesión (`getAccessToken`); usar `auth: false` en login/register.
 */
import { getAccessToken } from '../auth/session'

/** Error de API con status HTTP y cuerpo opcional parseado. */
export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
    readonly body?: unknown,
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

type RequestOptions = {
  method?: string
  body?: unknown
  /** Si es `false`, no envía Authorization. Default: true. */
  auth?: boolean
}

/**
 * Fetch tipado hacia billing vía rewrite same-origin `/api/billing`.
 * @param path Ruta relativa al rewrite (ej. `/me`, `/products`).
 * @param options Método, body JSON y flag de auth.
 */
export async function billingFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const headers: Record<string, string> = {
    Accept: 'application/json',
  }

  if (options.body !== undefined) {
    headers['Content-Type'] = 'application/json'
  }

  if (options.auth !== false) {
    const token = getAccessToken()
    if (token) headers.Authorization = `Bearer ${token}`
  }

  const res = await fetch(`/api/billing${path}`, {
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
