import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common'
import { Request, Response } from 'express'

/** Shape estable del error JSON retornado al cliente (consumido por el wallet). */
export interface ErrorResponseBody {
  /** Código HTTP de la respuesta. */
  statusCode: number
  /** Mensaje legible para humanos. */
  message: string
  /** Nombre de la clase de error (`Bad Request`, `Unprocessable Entity`, etc.). */
  error: string
  /** Código semántico del dominio para lookup en el wallet (ej. `OID4VC_NO_MATCHING_CREDENTIAL`). */
  errorCode?: string
  /** Detalles adicionales (ej. array de errores de validación de class-validator). */
  details?: unknown
  /** Path HTTP donde ocurrió el error. */
  path: string
  /** Timestamp ISO del error. */
  timestamp: string
}

/**
 * Captura todas las excepciones no manejadas y retorna una respuesta JSON estructurada.
 *
 * Shape garantizado (ver `ErrorResponseBody`): `statusCode`, `message`, `error`, `path`, `timestamp`;
 * opcionalmente `errorCode` (código de dominio) y `details` (ej. errores de validación).
 *
 * - Los errores 4xx se registran a nivel WARN (errores del cliente, no fallas del servicio).
 * - Los errores 5xx se registran a nivel ERROR con el stack trace completo.
 *
 * Se registra globalmente en `main.ts` mediante `app.useGlobalFilters`.
 */
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter')

  /**
   * Maneja la excepción capturada, la registra en el nivel apropiado
   * y envía una respuesta JSON estructurada al cliente.
   */
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp()
    const req = ctx.getRequest<Request>()
    const res = ctx.getResponse<Response>()

    const isHttpException = exception instanceof HttpException
    const status = isHttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR

    const { message, error, errorCode, details } = this.extractPayload(exception, status)

    const body: ErrorResponseBody = {
      statusCode: status,
      message,
      error,
      ...(errorCode ? { errorCode } : {}),
      ...(details !== undefined ? { details } : {}),
      path: req.originalUrl,
      timestamp: new Date().toISOString(),
    }

    if (status >= 500) {
      this.logger.error(
        `${req.method} ${req.originalUrl} ${status} — ${message}`,
        exception instanceof Error ? exception.stack : undefined,
      )
    } else {
      this.logger.warn(`${req.method} ${req.originalUrl} ${status} — ${message}`)
    }

    res.status(status).json(body)
  }

  /**
   * Normaliza el payload de la excepción al shape esperado, soportando:
   * - `HttpException` con response string u objeto `{ message, error, errorCode, details }`
   * - `ValidationPipe` (array de mensajes en `response.message`)
   * - Errores no-HTTP (se exponen como 500 sin filtrar stack al cliente)
   */
  private extractPayload(
    exception: unknown,
    status: number,
  ): { message: string; error: string; errorCode?: string; details?: unknown } {
    if (!(exception instanceof HttpException)) {
      return { message: 'Internal server error', error: 'Internal Server Error' }
    }

    const response = exception.getResponse()
    const fallbackError = statusToErrorName(status)

    if (typeof response === 'string') {
      return { message: response, error: fallbackError }
    }

    // class-validator + ValidationPipe devuelven `message: string[]`; lo movemos a `details`.
    const body = response as Record<string, unknown>
    const rawMessage = body.message
    const isValidationArray = Array.isArray(rawMessage)

    return {
      message: isValidationArray ? 'Validation failed' : String(rawMessage ?? exception.message),
      error: typeof body.error === 'string' ? body.error : fallbackError,
      errorCode: typeof body.errorCode === 'string' ? body.errorCode : undefined,
      details: isValidationArray ? rawMessage : body.details,
    }
  }
}

/** Traduce un código HTTP a su nombre canónico para el campo `error`. */
function statusToErrorName(status: number): string {
  const name = HttpStatus[status]
  if (!name) return 'Error'
  return name
    .toLowerCase()
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ')
}
