/**
 * Persistencia del access token de billing en `localStorage`.
 *
 * El token se envía como Bearer en `billingFetch` (excepto login/register).
 * Solo opera en el browser; en SSR retorna `null`.
 */
const TOKEN_KEY = 'kuatia.accessToken'

/** Lee el access token de sesión, o `null` si no hay / estamos en SSR. */
export function getAccessToken(): string | null {
  if (typeof window === 'undefined') return null
  return window.localStorage.getItem(TOKEN_KEY)
}

/** Guarda el access token tras login o registro. */
export function setAccessToken(token: string): void {
  window.localStorage.setItem(TOKEN_KEY, token)
}

/** Borra el token (logout o sesión inválida 401/403). */
export function clearAccessToken(): void {
  window.localStorage.removeItem(TOKEN_KEY)
}
