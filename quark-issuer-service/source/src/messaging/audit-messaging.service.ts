import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { MessagingClient } from './messaging.client'
import { AUDIT_EXCHANGE, AUDIT_ROUTING_KEYS, type AuditEventPayload } from './messaging.constants'

export type { AuditEventPayload }

@Injectable()
export class AuditMessagingService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(AuditMessagingService.name)
  private readonly client = new MessagingClient()

  constructor(private readonly config: ConfigService) {}

  onModuleInit(): void {
    const url = this.config.get<string>('rabbitmq.url') ?? 'amqp://localhost:5672'
    this.client.connect(url, AUDIT_EXCHANGE)
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.close()
  }

  /**
   * Fire-and-forget deliberado: la auditoría no debe bloquear ni propagar
   * errores al `AuditInterceptor` (que ejecuta `publish` dentro de un `tap` /
   * `catchError` de RxJS). Si el broker está caído, se loguea en el cliente y
   * se descarta la promesa — el request HTTP auditado sigue su curso normal.
   *
   * Nótese que este servicio NO implementa el puerto `MessagingService` de
   * identity-core (que exige `Promise<void>` y se inyecta vía `MESSAGING_SERVICE`).
   * `MessagingService` ya cumple ese contrato; este es un cliente paralelo
   * para el exchange de auditoría con semántica intencionalmente distinta.
   *
   * @param payload - Evento de auditoría a publicar en el exchange `AUDIT_EXCHANGE`.
   */
  publish(payload: AuditEventPayload): void {
    this.client
      .publish(AUDIT_ROUTING_KEYS.OPERATION, payload)
      .catch((err: unknown) => {
        // El cliente ya loguea en operaciones normales; este catch es la red
        // de seguridad final para evitar unhandled-rejection si el channel
        // falla a mitad del publish.
        this.logger.error(
          `Audit publish failed: ${
            err instanceof Error ? err.message : String(err)
          }`,
        )
      })
  }
}
