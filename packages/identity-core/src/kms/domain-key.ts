import type { Agent } from '@credo-ts/core'
import { Kms } from '@credo-ts/core'
import { AskarDomainKeyManagementService } from './askar-domain-key-management.service'

/**
 * Importa una clave privada al backend Askar de dominio (`askar-domain-key`).
 *
 * Requiere que el agente tenga registrado {@link AskarDomainKeyManagementService}.
 * Uso típico: certificado leaf x5c del dominio para OID4VP con EUDI wallet.
 *
 * Quien use Postgres como KMS primario puede seguir el path SQL legacy vía
 * `PostgresKeyManagementService` (fallback `DOMAIN_KEY_SCOPE` en `getKey`).
 *
 * @param agent - Agente root (o cualquier contexto con el backend domain-key)
 * @param keyId - Identificador de la clave (coincide con `OID4VP_X5C_LEAF_CERTIFICATE_KEY_ID`)
 * @param privateJwk - JWK privado (P-256 / Ed25519)
 * @throws {Kms.KeyManagementKeyExistsError} Si `keyId` ya existe en el perfil domain-key
 */
export async function importDomainKey(
  agent: Agent,
  keyId: string,
  privateJwk: Record<string, unknown>,
): Promise<{ keyId: string }> {
  const result = await agent.kms.importKey({
    backend: AskarDomainKeyManagementService.backend,
    privateJwk: {
      ...privateJwk,
      kid: keyId,
    } as Kms.KmsJwkPrivate,
  })
  return { keyId: result.keyId }
}
