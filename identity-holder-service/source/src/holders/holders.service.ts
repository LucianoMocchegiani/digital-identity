import { ConflictException, Injectable } from '@nestjs/common'
import { createHolderWallet, getTenantKeyDid } from '@identity/core'
import { ROUTING_KEYS } from '../messaging/messaging.constants'
import { MessagingService } from '../messaging/messaging.service'
import { hasWallet, listWallets, registerTenant, rootAgent, withWallet } from '../agent/agent-store'
import type { CreateHolderDto } from './dto/create-holder.dto'

/** Respuesta de alta de holder (`POST /holders`). */
export type CreateHolderResult = {
  holderId: string
  tenantId: string
  did: string | null
  recordsCreated: string[]
}

export type HolderListItem = {
  holderId: string
  tenantId: string
  did: string | null
}

export type ListHoldersResult = {
  holders: HolderListItem[]
}

/**
 * Alta de tenants holder (sin metadata OID4VC de issuer/verifier).
 */
@Injectable()
export class HoldersService {
  constructor(private readonly messaging: MessagingService) {}

  /** Lista holders registrados en el proceso. */
  async list(): Promise<ListHoldersResult> {
    if (!rootAgent) throw new Error('Agent not initialized')

    const holders: HolderListItem[] = []
    for (const { walletId, tenantId } of listWallets()) {
      let did: string | null = null
      try {
        did = await withWallet(walletId, (agent) => getTenantKeyDid(agent))
      } catch {
        did = null
      }
      holders.push({ holderId: walletId, tenantId, did })
    }

    return { holders }
  }

  /**
   * Crea un tenant holder con DID `did:key` Ed25519.
   *
   * Records Credo: `DidRecord`, `StorageVersionRecord`. Tenant en Credo Tenants.
   *
   * @throws {ConflictException} Si `holderId` ya está registrado
   */
  async create(dto: CreateHolderDto): Promise<CreateHolderResult> {
    if (!rootAgent) throw new Error('Agent not initialized')
    if (hasWallet(dto.holderId)) {
      throw new ConflictException(`Holder '${dto.holderId}' ya existe`)
    }

    const tenantId = await createHolderWallet(rootAgent, dto.holderId, '')
    registerTenant(dto.holderId, tenantId)

    const { did, didDocument } = await withWallet(dto.holderId, async (agent) => {
      const records = await agent.dids.getCreatedDids({ method: 'key' })
      const record = records[0]
      return {
        did: record?.did ?? null,
        didDocument: (record?.didDocument as unknown as Record<string, unknown>) ?? {},
      }
    })

    if (did) {
      this.messaging.publish(ROUTING_KEYS.DID_CREATED, {
        did,
        didDocument,
        source: `holder-${dto.holderId}`,
        timestamp: new Date().toISOString(),
      })
    }

    return {
      holderId: dto.holderId,
      tenantId,
      did,
      recordsCreated: ['DidRecord', 'StorageVersionRecord'],
    }
  }
}
