/**
 * Abstracción sobre pasarelas de pago (Mercado Pago, Stripe, manual, …).
 * BillingService depende solo de este puerto — nunca de un PSP concreto.
 */
import type { PlanId } from '../billing/plans'

/** Tipos de evento normalizados que billing sabe aplicar. */
export type PaymentEventType =
  | 'payment.succeeded'
  | 'payment.failed'
  | 'subscription.updated'
  | 'subscription.canceled'

/** Evento de pago ya normalizado desde cualquier PSP. */
export type NormalizedPaymentEvent = {
  type: PaymentEventType
  accountId?: string
  externalId?: string
  /** Plan a activar en `payment.succeeded` (default pro). */
  plan?: PlanId | 'paid'
  raw: Record<string, unknown>
}

/** Resultado de iniciar un checkout hospedado. */
export type CheckoutResult = {
  /** URL de checkout alojado, si aplica. */
  url: string | null
  externalId: string | null
}

/**
 * Puerto de integración con el proveedor de pagos.
 * Implementaciones: {@link ManualPaymentProvider}, futuros MP/Stripe.
 */
export interface PaymentProvider {
  readonly name: string

  /**
   * Crea una sesión de checkout para upgrade de plan.
   * @returns URL (o null en modo manual) + id externo
   */
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

/** Token de inyección Nest para el PaymentProvider activo. */
export const PAYMENT_PROVIDER = Symbol('PAYMENT_PROVIDER')
