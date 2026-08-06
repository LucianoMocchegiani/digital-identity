import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { MessagingClient } from './messaging.client'
import { AUDIT_EXCHANGE, AUDIT_ROUTING_KEYS, type AuditEventPayload } from './messaging.constants'

export type { AuditEventPayload }

@Injectable()
export class AuditMessagingService implements OnModuleInit, OnModuleDestroy {
  private readonly client = new MessagingClient()

  constructor(private readonly config: ConfigService) {}

  onModuleInit(): void {
    const url = this.config.get<string>('rabbitmq.url') ?? 'amqp://localhost:5672'
    this.client.connect(url, AUDIT_EXCHANGE)
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.close()
  }

  publish(payload: AuditEventPayload): void {
    this.client.publish(AUDIT_ROUTING_KEYS.OPERATION, payload)
  }
}
