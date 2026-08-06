import { AgentContext, DidRepository, Kms } from '@credo-ts/core'
import type { Agent } from '@credo-ts/core'

export interface EnsureKeyDidOptions {
  /** Tipo de clave. Por defecto P-256. */
  keyType?: 'P-256' | 'Ed25519'
}

/**
 * Obtiene o crea un DID `did:key` para el agente.
 *
 * Si ya existe un `did:key` creado y su clave KMS es válida, lo retorna directamente.
 * Si la clave KMS se perdió, elimina el registro y crea uno nuevo.
 * No depende de ningún servicio externo — el DID se deriva directamente de la clave pública.
 *
 * @param agent - Instancia del agente Credo-TS inicializado
 * @param options - Tipo de clave opcional (default: P-256)
 * @returns El DID generado (ej. `did:key:z...`)
 * @throws {Error} Si la creación del DID falla
 */
export async function ensureKeyDid(
  agent: Agent,
  options: EnsureKeyDidOptions = {}
): Promise<string> {
  const created = await agent.dids.getCreatedDids({ method: 'key' })

  if (created.length > 0) {
    const existing = created[0]
    const keyId = existing.keys?.[0]?.kmsKeyId
    if (keyId) {
      try {
        await agent.kms.getPublicKey({ keyId })
        return existing.did
      } catch (e) {
        if (e instanceof Kms.KeyManagementKeyNotFoundError) {
          const ctx = agent.dependencyManager.resolve(AgentContext)
          const didRepo = agent.dependencyManager.resolve(DidRepository)
          await didRepo.deleteById(ctx, existing.id)
        } else {
          throw e
        }
      }
    }
  }

  const keyType = options.keyType ?? 'P-256'
  const type =
    keyType === 'Ed25519'
      ? { kty: 'OKP' as const, crv: 'Ed25519' as const }
      : { kty: 'EC' as const, crv: 'P-256' as const }

  const result = await agent.dids.create({
    method: 'key',
    options: { createKey: { type } },
  })

  if (result.didState.state !== 'finished' || !result.didState.did) {
    const reason = (result.didState as { reason?: string }).reason ?? 'unknown'
    throw new Error(`Error al crear did:key: ${reason}`)
  }

  return result.didState.did
}
