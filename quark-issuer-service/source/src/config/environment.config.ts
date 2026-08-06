const env = process.env

export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'

const baseUrl = env.BASE_URL || 'http://quark-issuer-service:9001'

export const environmentConfig = () => ({
  port: Number(env.PORT || 3000),
  serviceHost: env.SERVICE_HOST || 'localhost',
  logLevel: (env.LOG_LEVEL || 'INFO').toUpperCase() as LogLevel,
  jwt: {
    secret: env.JWT_SECRET,
    issuer: env.JWT_ISSUER ?? 'quarkid',
    audience: env.JWT_AUDIENCE ?? 'quarkid-services',
  },
  /**
   * URL pública base del servicio (sin prefijos de protocolo DIDComm/OID4VC).
   * Usar para construir URIs que serán consumidos por terceros (holders, verifiers,
   * resolvers, status lists, etc.).
   */
  publicBaseUrl: baseUrl,
  didcommEndpoint: baseUrl + '/didcomm',
  invitationUrlPrefix: baseUrl,
  /**
   * Única URL Postgres del servicio (Askar store, sidecar BBS, StatusList).
   */
  databaseUrl: env.DATABASE_URL || '',
  askarStoreId: env.ASKAR_STORE_ID || '',
  askarStoreKey: env.ASKAR_STORE_KEY || '',
  /**
   * Config del `CredoWalletSignerProvider` (puerto `SignerProvider` del core).
   */
  revocationSigner: {
    algOverride: env.REVOCATION_SIGNER_ALG || undefined,
    kidOverride: env.REVOCATION_SIGNER_KID || undefined,
    keyFragment: env.REVOCATION_SIGNER_KEY_FRAGMENT || undefined,
    didMethod: (env.REVOCATION_SIGNER_DID_METHOD || 'web') as 'web' | 'key',
  },
  vdrServiceUrl: env.VDR_SERVICE_URL || 'http://localhost:4003',
  oid4vcBaseUrl: `${baseUrl}/openid4vc-flow`,
  oid4vcSupportedAlgs: (env.OID4VC_SUPPORTED_ALGS ?? 'ES256').split(',').map((s) => s.trim()),
  rabbitmq: { url: env.RABBITMQ_URL || 'amqp://localhost:5672' },
})
