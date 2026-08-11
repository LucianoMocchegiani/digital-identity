/**
 * Persistencia temporal de API keys en el navegador (sessionStorage).
 * Billing no reexpone el secreto; Credenciales necesita la key en claro.
 */

const PREFIX = 'kuatia.apiKey.'

function storageKey(productId: string): string {
  return `${PREFIX}${productId}`
}

/** Lee la API key guardada para un producto (o null). */
export function getStoredApiKey(productId: string): string | null {
  if (typeof window === 'undefined') return null
  try {
    return sessionStorage.getItem(storageKey(productId))
  } catch {
    return null
  }
}

/** Guarda la API key para el producto (solo esta pestaña/sesión). */
export function setStoredApiKey(productId: string, apiKey: string): void {
  if (typeof window === 'undefined') return
  try {
    sessionStorage.setItem(storageKey(productId), apiKey)
  } catch {
    /* quota / private mode */
  }
}

/** Elimina la key guardada del producto. */
export function clearStoredApiKey(productId: string): void {
  if (typeof window === 'undefined') return
  try {
    sessionStorage.removeItem(storageKey(productId))
  } catch {
    /* ignore */
  }
}
