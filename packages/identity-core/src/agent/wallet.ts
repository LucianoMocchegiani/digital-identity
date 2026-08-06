import type { Agent } from '@credo-ts/core'
import { ensureWebDid } from '../did/web-did'
import { ensureKeyDid } from '../did/key-did'
import { initializeIssuerOid4vc } from '../protocol/openid4vc/issuer.oid4vc'
import { initializeVerifierOid4vc } from '../protocol/openid4vc/verifier.oid4vc'
import { ensureTenant, withTenant } from './tenant'
import type { IssuerOid4vcOptions, VerifierOid4vcOptions } from './create-agent-options.types'

/**
 * Crea (o recupera si ya existe) el tenant de un issuer e inicializa DID web y OID4VCI.
 *
 * Records Credo que materializa en el storage del tenant:
 * - **Tenant** (módulo Credo Tenants, no tabla `records`): aislamiento por `contextCorrelationId`
 * - **`DidRecord`**: DID `did:web` del issuer y clave DIDComm
 * - **`OpenId4VcIssuerRecord`**: metadata OID4VCI (`issuerId` = `walletId`) si se pasan `oid4vcOptions`
 * - **`StorageVersionRecord`**: versión de schema (seed automático del storage)
 *
 * @param rootAgent - Agente root multi-tenant
 * @param walletId - ID lógico del issuer (`label` del tenant y `issuerId` OID4VCI)
 * @param walletKey - Reservado; no persistido con KMS interno
 * @param opts - `didcommEndpoint` para el DID web y `oid4vcOptions` opcionales
 * @returns `tenantId` interno de Credo (`TenantRecord.id`)
 */
export async function createIssuerWallet(
  rootAgent: Agent,
  walletId: string,
  walletKey: string,
  opts: { didcommEndpoint: string; oid4vcOptions?: IssuerOid4vcOptions },
): Promise<string> {
  const tenantId = await ensureTenant(rootAgent, walletId, walletKey)
  await withTenant(rootAgent, tenantId, async (agent) => {
    const url = new URL(opts.didcommEndpoint)
    const host = url.port ? `${url.hostname}%3A${url.port}` : url.hostname
    await ensureWebDid(agent, {
      domain: `${host}:${walletId}`,
      didcommEndpoint: opts.didcommEndpoint,
      addDidCommKey: true,
    })
    if (opts.oid4vcOptions) {
      await initializeIssuerOid4vc(agent, { ...opts.oid4vcOptions, issuerId: walletId })
    }
  })
  return tenantId
}

/**
 * Crea (o recupera si ya existe) el tenant de un verifier e inicializa DID web y OID4VP.
 *
 * Records Credo que materializa en el storage del tenant:
 * - **Tenant** (Credo Tenants)
 * - **`DidRecord`**: DID `did:web` y clave DIDComm
 * - **`OpenId4VcVerifierRecord`**: metadata OID4VP (`verifierId` = `walletId`) si hay `oid4vpOptions`
 * - **`StorageVersionRecord`**: seed del storage
 *
 * @param rootAgent - Agente root multi-tenant
 * @param walletId - ID lógico del verifier (`verifierId` OID4VP)
 * @param walletKey - Reservado; no persistido con KMS interno
 * @param opts - `didcommEndpoint` para el DID web y `oid4vpOptions` opcionales
 * @returns `tenantId` interno de Credo
 */
export async function createVerifierWallet(
  rootAgent: Agent,
  walletId: string,
  walletKey: string,
  opts: { didcommEndpoint: string; oid4vpOptions?: VerifierOid4vcOptions },
): Promise<string> {
  const tenantId = await ensureTenant(rootAgent, walletId, walletKey)
  await withTenant(rootAgent, tenantId, async (agent) => {
    const url = new URL(opts.didcommEndpoint)
    const host = url.port ? `${url.hostname}%3A${url.port}` : url.hostname
    await ensureWebDid(agent, {
      domain: `${host}:${walletId}`,
      didcommEndpoint: opts.didcommEndpoint,
      addDidCommKey: true,
    })
    if (opts.oid4vpOptions) {
      await initializeVerifierOid4vc(agent, { ...opts.oid4vpOptions, verifierId: walletId })
    }
  })
  return tenantId
}

/**
 * Crea (o recupera si ya existe) el tenant de un holder e inicializa su DID key Ed25519.
 *
 * Records Credo que materializa en el storage del tenant:
 * - **Tenant** (Credo Tenants)
 * - **`DidRecord`**: DID `did:key` Ed25519 del holder
 * - **`StorageVersionRecord`**: seed del storage
 *
 * No crea `OpenId4VcIssuerRecord` ni `OpenId4VcVerifierRecord` (el holder no publica metadata OID4VC).
 *
 * @param rootAgent - Agente root multi-tenant
 * @param walletId - ID lógico del holder
 * @param walletKey - Reservado; no persistido con KMS interno
 * @returns `tenantId` interno de Credo
 */
export async function createHolderWallet(
  rootAgent: Agent,
  walletId: string,
  walletKey: string,
): Promise<string> {
  const tenantId = await ensureTenant(rootAgent, walletId, walletKey)
  await withTenant(rootAgent, tenantId, async (agent) => {
    await ensureKeyDid(agent, { keyType: 'Ed25519' })
  })
  return tenantId
}

/**
 * Devuelve el primer DID `did:web` creado en el agente del tenant, si existe.
 *
 * @param agent - Agente del tenant (tras `withTenant`)
 */
export async function getTenantWebDid(agent: Agent): Promise<string | null> {
  const records = await agent.dids.getCreatedDids({ method: 'web' })
  return records[0]?.did ?? null
}

/**
 * Devuelve el primer DID `did:key` creado en el agente del tenant, si existe.
 *
 * @param agent - Agente del tenant (tras `withTenant`)
 */
export async function getTenantKeyDid(agent: Agent): Promise<string | null> {
  const records = await agent.dids.getCreatedDids({ method: 'key' })
  return records[0]?.did ?? null
}
