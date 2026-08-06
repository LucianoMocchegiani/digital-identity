import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common'
import { Observable, throwError } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'
import { AuditMessagingService } from './audit-messaging.service'

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(private readonly auditMessaging: AuditMessagingService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<{
      method: string
      url: string
      headers: Record<string, string | string[] | undefined>
    }>()

    const raw = req.headers['x-correlation-id']
    const correlationId = Array.isArray(raw) ? raw[0] : (raw ?? 'unknown')
    const start = Date.now()

    return next.handle().pipe(
      tap(() => {
        this.auditMessaging.publish({
          correlationId,
          source: 'issuer-service',
          operation: `${req.method} ${req.url}`,
          status: 'success',
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
      }),
      catchError((err: unknown) => {
        this.auditMessaging.publish({
          correlationId,
          source: 'issuer-service',
          operation: `${req.method} ${req.url}`,
          status: 'error',
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
        return throwError(() => err)
      }),
    )
  }
}
