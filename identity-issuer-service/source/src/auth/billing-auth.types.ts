export type BillingAuthContext = {
  accountId: string
  accountStatus: string
  plan: string
  rateLimitRpm: number
  monthlyTxQuota: number
  monthlyTxUsed: number
  maxProducts: number
  periodKey?: string
  productId: string
  productName: string
  resourceId: string
  service: 'issuer' | 'verifier'
  walletId: string
  resourceStatus: string
  apiKeyId: string
  apiKeyPrefix: string
}

declare module 'express-serve-static-core' {
  interface Request {
    billingAuth?: BillingAuthContext
  }
}
