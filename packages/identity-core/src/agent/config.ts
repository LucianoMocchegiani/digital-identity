import type { CredoAgentBaseConfig } from '../types/config.types'

/**
 * Variables de entorno mapeadas a {@link CredoAgentBaseConfig}.
 * El KMS/records los inyecta el integrador; no forman parte de este config.
 */
export interface CredoEnvConfig {
  vdrServiceUrl: string
  didcommEndpoint: string
  didcommPort?: number
  /** Usar HTTP en lugar de HTTPS para resolver did:web. Default false. */
  useHttpForWebDid?: boolean
  /** URL base pública para los endpoints OID4VCI. Si se omite, OID4VCI no se activa. */
  oid4vcBaseUrl?: string
}

export function buildCredoConfigFromEnv(env: CredoEnvConfig): CredoAgentBaseConfig {
  return {
    vdrServiceUrl: env.vdrServiceUrl,
    didcommEndpoint: env.didcommEndpoint,
    didcommPort: env.didcommPort,
    useHttpForWebDid: env.useHttpForWebDid,
    oid4vcBaseUrl: env.oid4vcBaseUrl,
  }
}
