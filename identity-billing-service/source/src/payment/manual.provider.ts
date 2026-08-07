import { Injectable } from '@nestjs/common'
import { isPlanId, normalizePlanId, type PlanId } from '../billing/plans'
import type {
  CheckoutResult,
  NormalizedPaymentEvent,
  PaymentProvider,
} from './payment-provider'

/**
 * Proveedor fase 1: sin PSP externo. El admin marca cuentas como pagadas vía BillingService.
 * Checkout devuelve url null; los webhooks aceptan un JSON simple para pruebas.
 */
@Injectable()
export class ManualPaymentProvider implements PaymentProvider {
  readonly name = 'manual'

  /**
   * Checkout stub: no hay URL; `externalId` = `manual_{accountId}_{plan}`.
   */
  async createCheckout(input: {
    accountId: string
    plan: PlanId
  }): Promise<CheckoutResult> {
    return {
      url: null,
      externalId: `manual_${input.accountId}_${input.plan}`,
    }
  }

  /**
   * Parsea body JSON `{ type?, accountId?, externalId?, plan? }`.
   * Default type: `payment.succeeded`.
   */
  parseWebhook(
    _headers: Record<string, string | string[] | undefined>,
    body: unknown,
  ): NormalizedPaymentEvent {
    const payload = (body ?? {}) as Record<string, unknown>
    const type = String(payload.type ?? 'payment.succeeded') as NormalizedPaymentEvent['type']
    const rawPlan = typeof payload.plan === 'string' ? payload.plan : undefined
    const plan =
      rawPlan && (isPlanId(rawPlan) || rawPlan === 'paid')
        ? normalizePlanId(rawPlan)
        : undefined
    return {
      type,
      accountId: typeof payload.accountId === 'string' ? payload.accountId : undefined,
      externalId: typeof payload.externalId === 'string' ? payload.externalId : undefined,
      plan,
      raw: payload,
    }
  }
}
