/**
 * Abstracción sobre pasarelas de pago (Mercado Pago, Stripe, manual, …).
 * BillingService depende solo de este puerto — nunca de un PSP concreto.
 */
import type { PlanId } from '../billing/plans'

export type PaymentEventType =
  | 'payment.succeeded'
  | 'payment.failed'
  | 'subscription.updated'
  | 'subscription.canceled'

export type NormalizedPaymentEvent = {
  type: PaymentEventType
  accountId?: string
  externalId?: string
  plan?: PlanId | 'paid'
  raw: Record<string, unknown>
}

export type CheckoutResult = {
  /** URL de checkout alojado, si aplica. */
  url: string | null
  externalId: string | null
}

export interface PaymentProvider {
  readonly name: string

  createCheckout(input: {
    accountId: string
    plan: PlanId
  }): Promise<CheckoutResult>

  /** Parsea el webhook del proveedor a un evento normalizado. */
  parseWebhook(
    headers: Record<string, string | string[] | undefined>,
    body: unknown,
  ): NormalizedPaymentEvent
}

export const PAYMENT_PROVIDER = Symbol('PAYMENT_PROVIDER')
