import { Body, Controller, Headers, Inject, Param, Post } from '@nestjs/common'
import { BillingService } from '../billing/billing.service'
import { PAYMENT_PROVIDER, type PaymentProvider } from '../payment/payment-provider'

/**
 * Ingress de webhooks independiente del proveedor.
 * Fase 1: POST /v1/webhooks/payments/manual con payload del ManualProvider.
 */
@Controller('webhooks/payments')
export class WebhooksController {
  constructor(
    private readonly billing: BillingService,
    @Inject(PAYMENT_PROVIDER) private readonly paymentProvider: PaymentProvider,
  ) {}

  @Post(':provider')
  async handle(
    @Param('provider') provider: string,
    @Headers() headers: Record<string, string | string[] | undefined>,
    @Body() body: unknown,
  ) {
    if (provider !== this.paymentProvider.name) {
      return {
        ok: false,
        reason: `proveedor_incorrecto se_esperaba=${this.paymentProvider.name}`,
      }
    }
    const event = this.paymentProvider.parseWebhook(headers, body)
    await this.billing.applyPaymentEvent(event)
    return { ok: true, type: event.type }
  }
}
