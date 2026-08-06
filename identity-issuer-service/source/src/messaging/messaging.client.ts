import type * as amqplib from 'amqplib'
import amqp, { type AmqpConnectionManager, type ChannelWrapper } from 'amqp-connection-manager'
import { Logger } from '@nestjs/common'
import { INDEX_EXCHANGE, type DidEventPayload, type AuditEventPayload } from './messaging.constants'

/**
 * Cliente AMQP best-effort hacia RabbitMQ.
 *
 * @remarks Si el broker no está disponible, `publish` no bloquea: loguea y
 * resuelve. Evita colgar flujos de negocio (p. ej. `allocateIndex` → offer)
 * cuando Compose corre sin RabbitMQ.
 */
export class MessagingClient {
  private readonly logger = new Logger(MessagingClient.name)
  private connection: AmqpConnectionManager | null = null
  private channel: ChannelWrapper | null = null
  private exchange: string = INDEX_EXCHANGE
  /** True solo tras handshake exitoso con el broker. */
  private connected = false

  connect(url: string, exchange: string = INDEX_EXCHANGE): void {
    this.exchange = exchange
    this.connected = false
    this.connection = amqp.connect([url])

    this.connection.on('connect', () => {
      this.connected = true
      this.logger.log(`Connected to RabbitMQ (${this.exchange})`)
    })
    this.connection.on('disconnect', ({ err }: { err?: Error }) => {
      this.connected = false
      this.logger.warn(`Disconnected, will reconnect: ${err?.message}`)
    })

    this.channel = this.connection.createChannel({
      setup: (ch: amqplib.ConfirmChannel) =>
        ch.assertExchange(this.exchange, 'topic', { durable: true }),
    })
  }

  async close(): Promise<void> {
    this.connected = false
    try {
      await this.channel?.close()
      await this.connection?.close()
    } catch {
      // ignore cleanup errors
    }
  }

  /**
   * Publica un mensaje en el exchange y espera la confirmación del broker.
   *
   * Devuelve `Promise<void>` para honrar el contrato del puerto
   * `MessagingService` de `@identity/core`. `amqp-connection-manager`
   * activa `publisherConfirms` por default, por lo que el `await` solo resuelve
   * cuando el broker confirma (o rechaza) el mensaje. Los errores se propagan
   * al caller, que decide si loguear y continuar o abortar.
   *
   * Si el channel no está inicializado **o el broker aún no conectó** (p. ej.
   * Compose sin RabbitMQ, handshake pendiente), se loguea y se resuelve con
   * éxito para no bloquear el flujo de negocio.
   *
   * @param routingKey - Clave de enrutamiento AMQP (topic exchange).
   * @param payload - Evento a serializar como JSON antes de publicar.
   * @returns Promesa que resuelve cuando el broker confirma, o de inmediato
   *   si no hay conexión.
   * @throws {Error} Si el channel se cayó durante el publish o el broker
   *   rechaza el mensaje (negative publisher confirm).
   */
  async publish(
    routingKey: string,
    payload: DidEventPayload | AuditEventPayload,
  ): Promise<void> {
    if (!this.channel || !this.connected) {
      this.logger.warn(`RabbitMQ not connected, skipping: ${routingKey}`)
      return
    }
    const content = Buffer.from(JSON.stringify(payload))
    await this.channel.publish(this.exchange, routingKey, content, {
      persistent: true,
    })
  }
}
