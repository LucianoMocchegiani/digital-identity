/** Nombre del proveedor de pago activo (`PAYMENT_PROVIDER`). */
export type PaymentProviderName = 'manual' | 'mercadopago' | 'stripe'

/** Configuración de entorno tipada del servicio de billing. */
export type EnvironmentConfig = {
  port: number
  nodeEnv: string
  databaseUrl: string
  /** Clave para rutas `/admin/*` (header `x-admin-key` / `x-api-key`). */
  adminApiKey: string
  /** Token para rutas `/internal/*` (header `x-internal-token`). */
  billingInternalToken: string
  paymentProvider: PaymentProviderName
  jwtSecret: string
  jwtExpiresIn: string
  /** Base URL del issuer para provision al crear producto. */
  issuerUrl: string
  /** Base URL del verifier para provision al crear producto. */
  verifierUrl: string
  /** Si false, POST /products no llama a issuer/verifier (solo billing). */
  provisionOnCreate: boolean
  oauth: {
    /** Base pública del billing `/v1`, p.ej. https://billing.kuatia.xyz/v1 */
    publicBaseUrl: string
    /** Origen del frontend (callback post-login). */
    frontendUrl: string
    googleClientId: string
    googleClientSecret: string
    githubClientId: string
    githubClientSecret: string
  }
}

/**
 * Lee variables de entorno con defaults de desarrollo.
 * @returns Configuración lista para Nest / TypeORM / JWT.
 */
export const environmentConfig = (): EnvironmentConfig => {
  const paymentProvider = (process.env.PAYMENT_PROVIDER ?? 'manual') as PaymentProviderName
  return {
    port: Number(process.env.PORT ?? 9000),
    nodeEnv: process.env.NODE_ENV ?? 'development',
    databaseUrl:
      process.env.DATABASE_URL ??
      'postgresql://identity:identity@localhost:5432/identity_billing',
    adminApiKey: process.env.ADMIN_API_KEY ?? 'dev-admin-change-me',
    billingInternalToken: process.env.BILLING_INTERNAL_TOKEN ?? 'dev-internal-change-me',
    paymentProvider,
    jwtSecret: process.env.JWT_SECRET ?? 'dev-jwt-change-me',
    jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
    issuerUrl: process.env.ISSUER_URL ?? 'http://localhost:9001',
    verifierUrl: process.env.VERIFIER_URL ?? 'http://localhost:9002',
    provisionOnCreate: (process.env.PROVISION_ON_CREATE ?? 'true').toLowerCase() !== 'false',
    oauth: {
      publicBaseUrl: process.env.OAUTH_PUBLIC_BASE_URL ?? 'http://localhost:9000/v1',
      frontendUrl: process.env.OAUTH_FRONTEND_URL ?? 'http://localhost:3000',
      googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
      googleClientSecret: process.env.GOOGLE_CLIENT_SECRET ?? '',
      githubClientId: process.env.GITHUB_CLIENT_ID ?? '',
      githubClientSecret: process.env.GITHUB_CLIENT_SECRET ?? '',
    },
  }
}
