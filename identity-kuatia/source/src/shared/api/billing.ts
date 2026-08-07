/**
 * Facade tipada del API de billing (auth, cuenta, planes, productos, API keys).
 *
 * Consume `billingFetch` (rewrite `/api/billing`). Endpoints de cuenta suelen
 * requerir Bearer; register/login van con `auth: false`.
 * Futura extensión OpenID4VC reutilizará productos issuer/verifier ya provisionados aquí.
 */
import { billingFetch } from './client'
import type {
  Account,
  AuthResponse,
  PlanInfo,
  Product,
  ProductCreateResponse,
  ResourceService,
  Usage,
} from '../types/billing'

/** Métodos del servicio de billing usados por la consola Kuatia. */
export const billingApi = {
  /** Alta de cuenta (sin token previo). */
  register(input: { name: string; email: string; password: string }) {
    return billingFetch<AuthResponse>('/auth/register', { body: input, auth: false })
  },

  /** Login; responde con `accessToken` + `account`. */
  login(input: { email: string; password: string }) {
    return billingFetch<AuthResponse>('/auth/login', { body: input, auth: false })
  },

  /** Perfil de la cuenta autenticada. */
  me() {
    return billingFetch<Account>('/me')
  },

  /** Uso del período actual (tx, cuota, rpm). */
  usage() {
    return billingFetch<Usage>('/me/usage')
  },

  /** Catálogo de planes disponibles. */
  plans() {
    return billingFetch<PlanInfo[]>('/me/plans')
  },

  /** Inicia checkout hacia un plan (provider manual en fase actual). */
  checkout(plan: string) {
    return billingFetch<unknown>('/me/checkout', { body: { plan } })
  },

  /** Lista productos (issuer/verifier) de la cuenta. */
  listProducts() {
    return billingFetch<Product[]>('/products')
  },

  /** Detalle de un producto por id. */
  getProduct(productId: string) {
    return billingFetch<Product>(`/products/${productId}`)
  },

  /** Crea producto y provisiona resource + API key (la key solo se muestra una vez). */
  createProduct(input: {
    name: string
    description?: string
    service: ResourceService
    walletId: string
  }) {
    return billingFetch<ProductCreateResponse>('/products', { body: input })
  },

  /** Actualiza metadatos del producto. */
  updateProduct(productId: string, input: { name?: string; description?: string }) {
    return billingFetch<Product>(`/products/${productId}`, {
      method: 'PATCH',
      body: input,
    })
  },

  /** Elimina un producto. */
  deleteProduct(productId: string) {
    return billingFetch<unknown>(`/products/${productId}`, { method: 'DELETE' })
  },

  /** Rota la API key del resource; la nueva key solo llega en esta respuesta. */
  rotateKey(resourceId: string) {
    return billingFetch<{ apiKey: string; prefix: string; warning?: string }>(
      `/resources/${resourceId}/keys/rotate`,
      { method: 'POST', body: {} },
    )
  },

  /** Revoca una API key por id. */
  revokeKey(apiKeyId: string) {
    return billingFetch<unknown>(`/api-keys/${apiKeyId}/revoke`, { method: 'POST', body: {} })
  },
}
