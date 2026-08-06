import { ConflictException, Injectable } from '@nestjs/common'
import {
  createVerifierWallet,
  getTenantWebDid,
  type VerifierOid4vcOptions,
} from '@identity/core'
import { ConfigService } from '@nestjs/config'
import { ROUTING_KEYS } from '../messaging/messaging.constants'
import { MessagingService } from '../messaging/messaging.service'
import { hasWallet, listWallets, registerTenant, rootAgent, withWallet } from '../agent/agent-store'
import type { CreateVerifierDto } from './dto/create-verifier.dto'

export type CreateVerifierResult = {
  verifierId: string
  tenantId: string
  did: string | null
  recordsCreated: string[]
}

export type VerifierListItem = {
  verifierId: string
  tenantId: string
  did: string | null
}

export type ListVerifiersResult = {
  verifiers: VerifierListItem[]
}

@Injectable()
export class VerifiersService {
  constructor(
    private readonly messaging: MessagingService,
    private readonly config: ConfigService,
  ) {}

  /** Lista verifiers registrados en el proceso. */
  async list(): Promise<ListVerifiersResult> {
    if (!rootAgent) throw new Error('Agent not initialized')

    const verifiers: VerifierListItem[] = []
    for (const { walletId, tenantId } of listWallets()) {
      let did: string | null = null
      try {
        did = await withWallet(walletId, (agent) => getTenantWebDid(agent))
      } catch {
        did = null
      }
      verifiers.push({ verifierId: walletId, tenantId, did })
    }

    return { verifiers }
  }

  /**
   * Crea tenant verifier con DID web y, opcionalmente, `OpenId4VcVerifierRecord`.
   *
   * @throws {ConflictException} Si `verifierId` ya existe en el mapa
   */
  async create(dto: CreateVerifierDto): Promise<CreateVerifierResult> {
    if (!rootAgent) throw new Error('Agent not initialized')
    if (hasWallet(dto.verifierId)) {
      throw new ConflictException(`Verifier '${dto.verifierId}' ya existe`)
    }

    const oid4vpOptions = dto.oid4vp as VerifierOid4vcOptions | undefined
    const tenantId = await createVerifierWallet(rootAgent, dto.verifierId, '', {
      didcommEndpoint: this.config.get<string>('didcommEndpoint') ?? '',
      oid4vpOptions,
    })
    registerTenant(dto.verifierId, tenantId)

    const { did, didDocument } = await withWallet(dto.verifierId, async (agent) => {
      const records = await agent.dids.getCreatedDids({ method: 'web' })
      const record = records[0]
      return {
        did: record?.did ?? null,
        didDocument: (record?.didDocument as unknown as Record<string, unknown>) ?? {},
      }
    })

    const recordsCreated = ['DidRecord', 'StorageVersionRecord']
    if (oid4vpOptions) recordsCreated.push('OpenId4VcVerifierRecord')

    if (did) {
      this.messaging.publish(ROUTING_KEYS.DID_CREATED, {
        did,
        didDocument,
        source: `verifier-${dto.verifierId}`,
        timestamp: new Date().toISOString(),
      })
    }

    return {
      verifierId: dto.verifierId,
      tenantId,
      did,
      recordsCreated,
    }
  }
}
