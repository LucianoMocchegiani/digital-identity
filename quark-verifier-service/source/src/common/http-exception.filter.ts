import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common'
import { Request, Response } from 'express'

/**
 * Captura todas las excepciones no manejadas y retorna una respuesta JSON de error consistente.
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

    const message = isHttpException
      ? exception.message
      : 'Internal server error'

    const errorResponse = {
      statusCode: status,
      message,
      path: req.originalUrl,
      timestamp: new Date().toISOString(),
    }

    if (res.headersSent) return

    if (status >= 500) {
      this.logger.error(
        `${req.method} ${req.originalUrl} ${status} — ${message}`,
        exception instanceof Error ? exception.stack : undefined,
      )
    } else {
      this.logger.warn(`${req.method} ${req.originalUrl} ${status} — ${message}`)
    }

    res.status(status).json(errorResponse)
  }
}
