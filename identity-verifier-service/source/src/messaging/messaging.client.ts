import type * as amqplib from 'amqplib'
import amqp, { type AmqpConnectionManager, type ChannelWrapper } from 'amqp-connection-manager'
import { Logger } from '@nestjs/common'
import { INDEX_EXCHANGE, type DidEventPayload, type AuditEventPayload } from './messaging.constants'

/**
 * Cliente AMQP best-effort hacia RabbitMQ.
 *
 * @remarks Si el broker no está disponible, `publish` no encola trabajo: loguea
 * y retorna. Evita promesas colgadas cuando Compose corre sin RabbitMQ.
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
   * Publica sin bloquear al caller (fire-and-forget).
   *
   * Si el broker no está conectado, skip inmediato. Con broker up, el error
   * de publish se loguea y no se propaga.
   */
  publish(routingKey: string, payload: DidEventPayload | AuditEventPayload): void {
    if (!this.channel || !this.connected) {
      this.logger.warn(`RabbitMQ not connected, skipping: ${routingKey}`)
      return
    }
    const content = Buffer.from(JSON.stringify(payload))
    this.channel
      .publish(this.exchange, routingKey, content, { persistent: true })
      .catch((err: unknown) => this.logger.error(`Publish failed: ${err}`))
  }
}
