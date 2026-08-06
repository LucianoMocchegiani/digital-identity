export interface VdrConfig {
  vdrServiceUrl: string;
}

/**
 * Config base del agente Credo (infra: VDR, DIDComm, OID4VC).
 * El KMS se inyecta por separado vía `options.keyManagementService`.
 */
export interface CredoAgentBaseConfig {
  vdrServiceUrl: string
  didcommEndpoint: string
  didcommPort?: number
  /** Usar HTTP en lugar de HTTPS para resolver did:web. Útil en dev local sin TLS. */
  useHttpForWebDid?: boolean
  /** URL base pública para los endpoints OID4VCI (ej. https://issuer.example.com/openid4vc-flow). Si se omite, OID4VCI no se activa. */
  oid4vcBaseUrl?: string
}
