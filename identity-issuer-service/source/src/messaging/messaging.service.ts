import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { MessagingClient } from './messaging.client'
import type { DidEventPayload } from './messaging.constants'

export type { DidEventPayload }

/**
 * Payload genérico aceptado por el puerto `MessagingService` de identity-core.
 * `Record<string, unknown>` es supertipo de los payloads tipados del issuer
 * (DID events, audit events, revocation events) y permite reutilizar este
 * adapter para cualquier evento que quiera publicar el core.
 */
export type MessagingPayload = Record<string, unknown>

@Injectable()
export class MessagingService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(MessagingService.name)
  private readonly client = new MessagingClient()

  constructor(private readonly config: ConfigService) {}

  onModuleInit(): void {
    const url = this.config.get<string>('rabbitmq.url') ?? 'amqp://localhost:5672'
    this.client.connect(url)
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.close()
  }

  /**
   * Publica un evento en RabbitMQ y espera la confirmación del broker.
   *
   * Implementa el contrato del puerto `MessagingService` de
   * `@identity/core` (token `MESSAGING_SERVICE`): la promesa resuelve
   * cuando el broker confirma el publish, no antes. Si el publish falla, el
   * error se loguea y se resuelve sin rechazarla — la operación de negocio
   * (revocación, creación de issuer, etc.) no debe abortarse por un fallo de
   * mensajería, alineado con la semántica de `publishEvent` del core
   * (`packages/identity-core/src/revocation/revocation.service.ts`).
   *
   * Internamente se envía al exchange `quarkid.index`. Los consumidores
   * especializados (`issuers.service`, `RevocationIssuerService`) lo siguen
   * invocando con sus DTOs tipados — `MessagingPayload` es supertipo.
   *
   * @param routingKey - Clave de enrutamiento AMQP (topic exchange `quarkid.index`).
   * @param payload - Evento a publicar; se acepta `MessagingPayload` (genérico)
   *   o `DidEventPayload` (tipado) porque este último es subtipo del primero.
   * @returns Promesa que siempre resuelve: nunca rechaza (los errores de
   *   publish se loguean y se descartan para no abortar la operación de negocio).
   */
  async publish(
    routingKey: string,
    payload: MessagingPayload | DidEventPayload,
  ): Promise<void> {
    try {
      await this.client.publish(routingKey, payload as DidEventPayload)
    } catch (err) {
      this.logger.error(
        `Failed to publish ${routingKey}: ${
          err instanceof Error ? err.message : String(err)
        }`,
      )
      // No se relanza: la operación de negocio ya completó y publicar el
      // evento es best-effort, igual que en `RevocationService.publishEvent`.
    }
  }
}
