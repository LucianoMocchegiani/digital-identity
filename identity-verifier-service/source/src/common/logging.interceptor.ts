import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common'
import { Observable, tap } from 'rxjs'
import { Request, Response } from 'express'

/**
 * Registra cada solicitud HTTP entrante con método, ruta, código de estado y latencia.
 *
 * Las respuestas exitosas se registran a nivel INFO; los errores a nivel ERROR.
 * Se registra globalmente en `main.ts` mediante `app.useGlobalInterceptors`.
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP')

  /** @returns Observable que emite después de registrar el resultado de la solicitud. */
  // La interfaz NestInterceptor de NestJS retorna Observable<any>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const ctx = context.switchToHttp()
    const req = ctx.getRequest<Request>()
    const { method, originalUrl } = req

    const start = Date.now()

    return next.handle().pipe(
      tap({
        next: () => {
          const res = ctx.getResponse<Response>()
          const latency = Date.now() - start
          this.logger.log(
            `${method} ${originalUrl} ${res.statusCode} ${latency}ms`,
          )
        },
        error: (err: { status?: number; getStatus?: () => number; message: string }) => {
          const latency = Date.now() - start
          const status = err?.status || err?.getStatus?.() || 500
          this.logger.error(
            `${method} ${originalUrl} ${status} ${latency}ms — ${err.message}`,
          )
        },
      }),
    )
  }
}
