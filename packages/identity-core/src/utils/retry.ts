export interface WithRetryOptions {
  /** Número máximo de intentos (incluye el primero). */
  attempts: number
  /** Delay inicial en ms. Se duplica en cada intento, con tope en maxDelayMs. */
  baseDelayMs: number
  /** Delay máximo en ms entre intentos. */
  maxDelayMs: number
  /** Etiqueta usada en los mensajes de log (ej. "[EnsureDid]"). */
  label: string
  /**
   * Predicado opcional para decidir si un error es reintentable.
   * Por defecto reintenta todos los errores.
   */
  shouldRetry?: (err: unknown) => boolean
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

/**
 * Ejecuta `fn` hasta `options.attempts` veces con backoff exponencial.
 * Loguea un warning en cada fallo con el intento actual y el tiempo de espera.
 * Si `shouldRetry` devuelve `false` para un error, aborta inmediatamente sin más reintentos.
 *
 * @param fn - Función asíncrona a ejecutar con reintentos.
 * @param options - Configuración de reintentos, delays y logging.
 * @returns El valor resuelto por `fn` en el primer intento exitoso.
 * @throws El último error capturado si se agotan todos los intentos o el error no es reintentable.
 */
export async function withRetry<T>(fn: () => Promise<T>, options: WithRetryOptions): Promise<T> {
  const { attempts, baseDelayMs, maxDelayMs, label, shouldRetry } = options
  let lastErr: unknown

  for (let attempt = 1; attempt <= attempts; attempt++) {
    try {
      return await fn()
    } catch (err) {
      lastErr = err
      const retryable = shouldRetry ? shouldRetry(err) : true
      if (!retryable || attempt === attempts) {
        break
      }
      const waitMs = Math.min(baseDelayMs * Math.pow(2, attempt - 1), maxDelayMs)
      const msg = err instanceof Error ? err.message : String(err)
      console.warn(`${label} intento ${attempt}/${attempts} fallido: ${msg} — reintentando en ${waitMs / 1000}s`)
      await delay(waitMs)
    }
  }

  throw lastErr
}
