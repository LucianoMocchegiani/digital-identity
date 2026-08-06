export type PaymentProviderName = 'manual' | 'mercadopago' | 'stripe'

export type EnvironmentConfig = {
  port: number
  nodeEnv: string
  databaseUrl: string
  adminApiKey: string
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
}

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
  }
}
