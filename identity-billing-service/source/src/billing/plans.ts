export type PlanId = 'free' | 'pro' | 'business'

export type PlanDefinition = {
  id: PlanId
  label: string
  maxProducts: number
  rateLimitRpm: number
  /** Cuota de transacciones por mes calendario (UTC). */
  monthlyTxQuota: number
}

export const PLANS: Record<PlanId, PlanDefinition> = {
  free: {
    id: 'free',
    label: 'Free',
    /** Típicamente 1 issuer + 1 verifier (cada uno es un producto). */
    maxProducts: 2,
    rateLimitRpm: 30,
    monthlyTxQuota: 5_000,
  },
  pro: {
    id: 'pro',
    label: 'Pro',
    maxProducts: 5,
    rateLimitRpm: 600,
    monthlyTxQuota: 100_000,
  },
  business: {
    id: 'business',
    label: 'Business',
    maxProducts: 20,
    rateLimitRpm: 3_000,
    monthlyTxQuota: 1_000_000,
  },
}

/** Alias legacy: cuentas/webhooks con `paid` se tratan como `pro`. */
export function resolvePlan(plan: string): PlanDefinition {
  if (plan === 'paid') return PLANS.pro
  if (plan === 'free' || plan === 'pro' || plan === 'business') return PLANS[plan]
  return PLANS.free
}

export function listPlans(): PlanDefinition[] {
  return [PLANS.free, PLANS.pro, PLANS.business]
}

export function isPlanId(value: string): value is PlanId {
  return value === 'free' || value === 'pro' || value === 'business'
}

/** Normaliza plan entrante (incluye alias `paid` → `pro`). */
export function normalizePlanId(value: string): PlanId {
  if (value === 'paid') return 'pro'
  if (isPlanId(value)) return value
  return 'free'
}
