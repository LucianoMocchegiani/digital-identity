const env = process.env

export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'

const baseUrl = env.BASE_URL || 'http://identity-holder-service:9005'

export const environmentConfig = () => ({
  port: Number(env.PORT || 9005),
  serviceHost: env.SERVICE_HOST || 'localhost',
  logLevel: (env.LOG_LEVEL || 'INFO').toUpperCase() as LogLevel,
  didcommEndpoint: baseUrl + '/didcomm',
  /** Única URL Postgres del servicio (Askar store, sidecar BBS). */
  databaseUrl: env.DATABASE_URL || '',
  askarStoreId: env.ASKAR_STORE_ID || '',
  askarStoreKey: env.ASKAR_STORE_KEY || '',
  vdrServiceUrl: env.VDR_SERVICE_URL || 'http://localhost:4003',
  useHttpForWebDid: env.NODE_ENV !== 'production',
  walletOrigin: env.WALLET_ORIGIN || '*',
  rabbitmq: { url: env.RABBITMQ_URL || 'amqp://localhost:5672' },
})
