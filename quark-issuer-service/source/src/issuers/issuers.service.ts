import { ConflictException, Injectable, Logger } from '@nestjs/common'
import {
  createIssuerWallet,
  getTenantWebDid,
  type IssuerOid4vcOptions,
} from '@quarkid/identity-core'
import { ConfigService } from '@nestjs/config'
import { ROUTING_KEYS } from '../messaging/messaging.constants'
import { MessagingService } from '../messaging/messaging.service'
import { hasWallet, listWallets, registerTenant, rootAgent, withWallet } from '../agent/agent-store'
import type { CreateIssuerDto } from './dto/create-issuer.dto'

/** Respuesta de alta de issuer (`POST /issuers`). */
export type CreateIssuerResult = {
  issuerId: string
  tenantId: string
  did: string | null
  recordsCreated: string[]
}

/** Item del listado (`GET /issuers`). */
export type IssuerListItem = {
  issuerId: string
  tenantId: string
  did: string | null
}

/** Respuesta de listado de issuers. */
export type ListIssuersResult = {
  issuers: IssuerListItem[]
}

/**
 * Alta y listado de tenants issuer.
 */
@Injectable()
export class IssuersService {
  private readonly logger = new Logger(IssuersService.name)

  constructor(
    private readonly messaging: MessagingService,
    private readonly config: ConfigService,
  ) {}

  /**
   * Lista issuers registrados en el proceso (mapa en memoria + tenants persistidos al bootstrap).
   */
  async list(): Promise<ListIssuersResult> {
    if (!rootAgent) throw new Error('Agent not initialized')

    const issuers: IssuerListItem[] = []
    for (const { walletId, tenantId } of listWallets()) {
      let did: string | null = null
      try {
        did = await withWallet(walletId, (agent) => getTenantWebDid(agent))
      } catch {
        did = null
      }
      issuers.push({ issuerId: walletId, tenantId, did })
    }

    return { issuers }
  }

  /**
   * Crea un tenant issuer con DID web y, opcionalmente, metadata OID4VCI inicial.
   *
   * Records Credo materializados: `DidRecord`, `OpenId4VcIssuerRecord` (si `oid4vc` en body),
   * `StorageVersionRecord` (seed). El tenant vive en Credo Tenants (no en `GET /records`).
   *
   * @throws {ConflictException} Si `issuerId` ya está registrado en el mapa en memoria
   */
  async create(dto: CreateIssuerDto): Promise<CreateIssuerResult> {
    if (!rootAgent) throw new Error('Agent not initialized')
    if (hasWallet(dto.issuerId)) {
      throw new ConflictException(`Issuer '${dto.issuerId}' ya existe`)
    }

    const oid4vcOptions = dto.oid4vc as IssuerOid4vcOptions | undefined
    const tenantId = await createIssuerWallet(rootAgent, dto.issuerId, '', {
      didcommEndpoint: this.config.get<string>('didcommEndpoint') ?? '',
      oid4vcOptions,
    })
    registerTenant(dto.issuerId, tenantId)

    const { did, didDocument } = await withWallet(dto.issuerId, async (agent) => {
      const records = await agent.dids.getCreatedDids({ method: 'web' })
      const record = records[0]
      return {
        did: record?.did ?? null,
        didDocument: (record?.didDocument as unknown as Record<string, unknown>) ?? {},
      }
    })

    const recordsCreated = ['DidRecord', 'StorageVersionRecord']
    if (oid4vcOptions) recordsCreated.push('OpenId4VcIssuerRecord')

    if (did) {
      try {
        await this.messaging.publish(ROUTING_KEYS.DID_CREATED, {
          did,
          didDocument,
          source: `issuer-${dto.issuerId}`,
          timestamp: new Date().toISOString(),
        })
      } catch (err) {
        // El adapter (`MessagingService.publish`) ya loguea el error y resuelve
        // sin rechazar; este catch es defensa en profundidad por si el adapter
        // cambiara su contrato en el futuro.
        this.logger.warn(
          `Failed to publish DID_CREATED for ${dto.issuerId}: ${
            err instanceof Error ? err.message : String(err)
          }`,
        )
      }
    }

    return {
      issuerId: dto.issuerId,
      tenantId,
      did,
      recordsCreated,
    }
  }
}
