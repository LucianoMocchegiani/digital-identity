import { BaseLogger, LogLevel } from '@credo-ts/core'

import { defaultLogger, type CredoLogger } from './logger.types'

/**
 * Adapta un {@link CredoLogger} (Nest `JsonLoggerService`, etc.) a la interfaz
 * `Logger` de Credo-TS, para que los errores internos (DIDComm decrypt, etc.)
 * salgan en el mismo formato JSON estructurado del servicio.
 */
export class QuarkCredoAgentLogger extends BaseLogger {
  constructor(
    private readonly appLogger: CredoLogger = defaultLogger,
    logLevel: LogLevel = LogLevel.Warn,
  ) {
    super(logLevel)
  }

  test(message: string, data?: Record<string, unknown>): void {
    this.emit('log', message, data)
  }

  trace(message: string, data?: Record<string, unknown>): void {
    this.emit('log', message, data)
  }

  debug(message: string, data?: Record<string, unknown>): void {
    this.emit('log', message, data)
  }

  info(message: string, data?: Record<string, unknown>): void {
    this.emit('log', message, data)
  }

  warn(message: string, data?: Record<string, unknown>): void {
    this.emit('warn', message, data)
  }

  error(message: string, data?: Record<string, unknown>): void {
    this.emit('error', message, data)
  }

  fatal(message: string, data?: Record<string, unknown>): void {
    this.emit('error', message, data)
  }

  private emit(
    level: 'log' | 'warn' | 'error',
    message: string,
    data?: Record<string, unknown>,
  ): void {
    const context = 'Credo'
    if (data && Object.keys(data).length > 0) {
      this.appLogger[level](message, sanitizeCredoLogData(data), context)
      return
    }
    this.appLogger[level](message, context)
  }
}

/**
 * Reduce payloads DIDComm (ciphertext, protected) para no inundar stdout
 * ni filtrar material cifrado completo en agregadores de logs.
 */
function sanitizeCredoLogData(data: Record<string, unknown>): Record<string, unknown> {
  const out: Record<string, unknown> = { ...data }

  if (out.encryptedMessage && typeof out.encryptedMessage === 'object' && out.encryptedMessage !== null) {
    const em = out.encryptedMessage as Record<string, unknown>
    out.encryptedMessage = {
      ...em,
      protected: redactLongString(em.protected),
      ciphertext: redactLongString(em.ciphertext),
      iv: typeof em.iv === 'string' ? em.iv : em.iv,
      tag: typeof em.tag === 'string' ? em.tag : em.tag,
    }
  }

  if (out.error && typeof out.error === 'object' && out.error !== null) {
    const err = out.error as Record<string, unknown>
    const cause = err.cause
    let causeSummary: { name?: unknown; message?: unknown } | undefined
    if (cause && typeof cause === 'object') {
      const c = cause as Record<string, unknown>
      causeSummary = { name: c.name, message: c.message }
    } else if (typeof cause === 'string') {
      causeSummary = { message: cause }
    }
    out.error = {
      name: err.name,
      message: err.message,
      ...(causeSummary ? { cause: causeSummary } : {}),
      ...(typeof err.serialized === 'string' ? { serialized: err.serialized } : {}),
    }
  }

  return out
}

function redactLongString(value: unknown): unknown {
  if (typeof value !== 'string') return value
  if (value.length <= 64) return value
  return `[redacted len=${value.length}]`
}
