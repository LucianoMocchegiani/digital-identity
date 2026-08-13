/** Identificadores de plan comerciales. */
export type PlanId = 'free' | 'pro' | 'pro_double' | 'business'

/** Definición estática de cupos y límites de un plan. */
export type PlanDefinition = {
  id: PlanId
  label: string
  maxProducts: number
  rateLimitRpm: number
  /** Cuota de transacciones por mes calendario (UTC). */
  monthlyTxQuota: number
}

/** Catálogo de planes (fuente de verdad de cupos por defecto). */
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
    /** Mismo cupo de productos que Free; más RPM y TX. */
    maxProducts: 2,
    rateLimitRpm: 600,
    monthlyTxQuota: 100_000,
  },
  /** Varias marcas / líneas de negocio (hasta 10 productos). */
  pro_double: {
    id: 'pro_double',
    label: 'Proveedores',
    maxProducts: 10,
    rateLimitRpm: 1_200,
    monthlyTxQuota: 200_000,
  },
  /**
   * Cupos baseline solo para overrides admin / contratos.
   * En marketing: card “Dedicado” (on-prem / gobierno) vía ventas — no self-serve.
   */
  business: {
    id: 'business',
    label: 'Dedicado',
    maxProducts: 20,
    rateLimitRpm: 3_000,
    monthlyTxQuota: 1_000_000,
  },
}

/**
 * Resuelve un plan desde string (incluye alias legacy `paid` → pro).
 * Desconocido → free.
 * @param plan - Id o alias entrante
 */
export function resolvePlan(plan: string): PlanDefinition {
  if (plan === 'paid') return PLANS.pro
  if (isPlanId(plan)) return PLANS[plan]
  return PLANS.free
}

/** Lista los planes en orden free → pro → pro_double → business. */
export function listPlans(): PlanDefinition[] {
  return [PLANS.free, PLANS.pro, PLANS.pro_double, PLANS.business]
}

/** Type guard: ¿es un {@link PlanId} válido? */
export function isPlanId(value: string): value is PlanId {
  return (
    value === 'free' ||
    value === 'pro' ||
    value === 'pro_double' ||
    value === 'business'
  )
}

/**
 * Normaliza plan entrante (incluye alias `paid` → `pro`).
 * Valores desconocidos → `free`.
 */
export function normalizePlanId(value: string): PlanId {
  if (value === 'paid') return 'pro'
  if (isPlanId(value)) return value
  return 'free'
}
