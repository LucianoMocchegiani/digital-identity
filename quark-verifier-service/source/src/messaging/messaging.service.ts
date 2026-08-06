import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { MessagingClient } from './messaging.client'
import type { DidEventPayload } from './messaging.constants'

export type { DidEventPayload }

@Injectable()
export class MessagingService implements OnModuleInit, OnModuleDestroy {
  private readonly client = new MessagingClient()

  constructor(private readonly config: ConfigService) {}

  onModuleInit(): void {
    const url = this.config.get<string>('rabbitmq.url') ?? 'amqp://localhost:5672'
    this.client.connect(url)
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.close()
  }

  publish(routingKey: string, payload: DidEventPayload): void {
    this.client.publish(routingKey, payload)
  }
}
