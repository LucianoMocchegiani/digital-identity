import type { VerifierOid4vcOptions } from '@identity/core'

/**
 * Configuración por-tenant del verifier.
 * TODO: reemplazar con carga desde DB por tenantId cuando se implemente multi-tenancy.
 */
export interface VerifierTenantConfig {
  verifierOptions: VerifierOid4vcOptions
}

export const verifierConfigMock: VerifierTenantConfig = {
  verifierOptions: {
    clientMetadata: {
      client_name: 'Quark Verifier',
    },
  },
}
