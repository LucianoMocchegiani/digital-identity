const env = process.env

export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'

export const environmentConfig = () => {
  const baseUrl = env.BASE_URL || 'http://identity-verifier-service:9002'
  const parsedUrl = new URL(baseUrl)
  const didWebDomain = parsedUrl.port
    ? `${parsedUrl.hostname}%3A${parsedUrl.port}`
    : parsedUrl.hostname

  return {
    port: Number(env.PORT || 9004),
    serviceHost: env.SERVICE_HOST || 'localhost',
    logLevel: (env.LOG_LEVEL || 'INFO').toUpperCase() as LogLevel,
    didcommEndpoint: baseUrl + '/didcomm',
    invitationUrlPrefix: baseUrl,
    /** Única URL Postgres del servicio (Askar store, sidecar BBS). */
    databaseUrl: env.DATABASE_URL || '',
    askarStoreId: env.ASKAR_STORE_ID || '',
    askarStoreKey: env.ASKAR_STORE_KEY || '',
    vdrServiceUrl: env.VDR_SERVICE_URL || 'http://localhost:4003',
    didWebDomain,
    useHttpForWebDid: env.NODE_ENV !== 'production',
    oid4vcBaseUrl: `${baseUrl}/openid4vc-flow`,
    oid4vpX5cCertificatesBase64: env.OID4VP_X5C_CERTIFICATES_BASE64
      ? env.OID4VP_X5C_CERTIFICATES_BASE64.split(',').map((v) => v.trim()).filter(Boolean)
      : [],
    oid4vpX5cLeafCertificateKeyId: env.OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID || '',
    oid4vpX5cClientIdPrefix: (env.OID4VP_X5C_CLIENT_ID_PREFIX || 'x509_hash') as
      | 'x509_hash'
      | 'x509_san_dns',
    rabbitmq: { url: env.RABBITMQ_URL || 'amqp://localhost:5672' },
  }
}
