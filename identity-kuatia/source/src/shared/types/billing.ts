/**
 * Tipos del contrato de billing usados por la consola Kuatia.
 * Alineados a las respuestas de `/api/billing` (servicio billing v1).
 */

/** Identificador de plan comercial. */
export type PlanId = 'free' | 'pro' | 'business'

/** Estado de cuenta; puede incluir valores futuros del backend. */
export type AccountStatus = 'active' | 'suspended' | string

/** Rol del producto/resource: emisor o verificador (base para OpenID4VC). */
export type ResourceService = 'issuer' | 'verifier'

/** Cuenta autenticada y sus límites de plan. */
export type Account = {
  id: string
  name: string
  email: string | null
  plan: PlanId | string
  status: AccountStatus
  maxProducts: number
  rateLimitRpm: number
  monthlyTxQuota: number
  createdAt: string
  updatedAt: string
}

/** Respuesta de login/register: token + cuenta. */
export type AuthResponse = {
  accessToken: string
  account: Account
}

/** Resumen de una API key (sin el secreto). */
export type ApiKeySummary = {
  id: string
  prefix: string
  name: string | null
  lastUsedAt: string | null
  createdAt: string
}

/** Vista del resource provisionado (issuer/verifier) y sus keys. */
export type ResourceView = {
  id: string
  service: ResourceService
  walletId: string
  status: string
  apiKeys: ApiKeySummary[]
}

/** Producto de la cuenta con resource opcional embebido. */
export type Product = {
  id: string
  name: string
  description: string | null
  status: string
  service: ResourceService | null
  walletId: string | null
  resource: ResourceView | null
  createdAt: string
  updatedAt: string
}

/** Alta de producto: incluye la API key en claro una sola vez. */
export type ProductCreateResponse = {
  product: {
    id: string
    name: string
    description: string | null
    status: string
    service: ResourceService
    walletId: string
    resourceId: string
    resourceStatus: string
    apiKey: string
    prefix: string
  }
  warning: string
}

/** Uso del período de facturación actual. */
export type Usage = {
  periodKey: string
  monthlyTxUsed: number
  monthlyTxQuota: number
  rateLimitRpm: number
  maxProducts: number
  plan: string
}

/** Entrada del catálogo de planes. */
export type PlanInfo = {
  id: PlanId | string
  maxProducts: number
  rateLimitRpm: number
  monthlyTxQuota: number
  label?: string
}
