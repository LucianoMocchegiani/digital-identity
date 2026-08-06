import type * as amqplib from 'amqplib'
import amqp, { type AmqpConnectionManager, type ChannelWrapper } from 'amqp-connection-manager'
import { Logger } from '@nestjs/common'
import { INDEX_EXCHANGE, type DidEventPayload, type AuditEventPayload } from './messaging.constants'

export class MessagingClient {
  private readonly logger = new Logger(MessagingClient.name)
  private connection: AmqpConnectionManager | null = null
  private channel: ChannelWrapper | null = null
  private exchange: string = INDEX_EXCHANGE

  connect(url: string, exchange: string = INDEX_EXCHANGE): void {
    this.exchange = exchange
    this.connection = amqp.connect([url])

    this.connection.on('connect', () =>
      this.logger.log(`Connected to RabbitMQ (${this.exchange})`),
    )
    this.connection.on('disconnect', ({ err }: { err?: Error }) =>
      this.logger.warn(`Disconnected, will reconnect: ${err?.message}`),
    )

    this.channel = this.connection.createChannel({
      setup: (ch: amqplib.ConfirmChannel) =>
        ch.assertExchange(this.exchange, 'topic', { durable: true }),
    })
  }

  async close(): Promise<void> {
    try {
      await this.channel?.close()
      await this.connection?.close()
    } catch {
      // ignore cleanup errors
    }
  }

  publish(routingKey: string, payload: DidEventPayload | AuditEventPayload): void {
    if (!this.channel) {
      this.logger.warn(`Client not initialized, skipping: ${routingKey}`)
      return
    }
    const content = Buffer.from(JSON.stringify(payload))
    this.channel
      .publish(this.exchange, routingKey, content, { persistent: true })
      .catch((err: unknown) => this.logger.error(`Publish failed: ${err}`))
  }
}
