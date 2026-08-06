import type { AgentContext } from '@credo-ts/core'
import { Kms } from '@credo-ts/core'
import type { Bls12381G2KeyPair } from '@mattrglobal/bls12381-key-pair'
import { BLS12381_G2_KEY_TYPE } from '../credential/bbs/constants'
import { BbsKeyManagementService } from './bbs-key-management.service'
import { PostgresKeyManagementService } from './postgres-key-management.service'

/** Backend capaz de crear/leer claves Bls12381G2 (sidecar BBS o Postgres full). */
export type Bls12381G2KeyBackend =
  | BbsKeyManagementService
  | PostgresKeyManagementService

/**
 * Resuelve el backend BLS registrado en el agente.
 *
 * Preferencia: `BbsKeyManagementService` (producto Askar) →
 * `PostgresKeyManagementService` (integrador Postgres full).
 */
export function tryResolveBls12381G2KeyBackend(
  agentContext: AgentContext,
): Bls12381G2KeyBackend | null {
  const config = agentContext.dependencyManager.resolve(Kms.KeyManagementModuleConfig)
  const bbs = config.backends.find(
    (b): b is BbsKeyManagementService => b instanceof BbsKeyManagementService,
  )
  if (bbs) return bbs
  const postgres = config.backends.find(
    (b): b is PostgresKeyManagementService =>
      b instanceof PostgresKeyManagementService,
  )
  return postgres ?? null
}

/**
 * Crea un par Bls12381G2 sin pasar por `KeyManagementApi` (Zod de Credo lo rechaza).
 *
 * Requiere `BbsKeyManagementService` o `PostgresKeyManagementService` registrado.
 */
export async function createBls12381G2Key(
  agentContext: AgentContext,
  keyId?: string,
): Promise<{ keyId: string; publicKeyBase58: string }> {
  const backend = tryResolveBls12381G2KeyBackend(agentContext)
  if (!backend) {
    throw new Error(
      'Bls12381G2 (BBS+) requiere BbsKeyManagementService o PostgresKeyManagementService registrado en el agente.',
    )
  }

  const created = await backend.createKey(agentContext, {
    type: BLS12381_G2_KEY_TYPE as never,
    keyId,
  })
  const publicKeyBase58 =
    (created as { publicKeyBase58?: string }).publicKeyBase58 ??
    (created.publicJwk as { publicKeyBase58?: string } | undefined)?.publicKeyBase58
  if (!publicKeyBase58) {
    throw new Error('createKey Bls12381G2 did not return publicKeyBase58')
  }
  return { keyId: created.keyId, publicKeyBase58 }
}

/**
 * Reconstruye el key pair MATTR BLS desde el sidecar BBS o Postgres full.
 */
export async function getBls12381G2KeyPair(
  agentContext: AgentContext,
  keyId: string,
): Promise<Bls12381G2KeyPair> {
  const backend = tryResolveBls12381G2KeyBackend(agentContext)
  if (!backend) {
    throw new Error(
      'Bls12381G2 (BBS+) requiere BbsKeyManagementService o PostgresKeyManagementService registrado en el agente.',
    )
  }
  return backend.getBls12381G2KeyPair(agentContext, keyId)
}
