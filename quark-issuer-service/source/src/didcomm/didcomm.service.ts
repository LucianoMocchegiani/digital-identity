import { Injectable, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import {
  createInvitation,
  offerCredential,
  type ConnectionReadyPayload,
} from '@quarkid/identity-core'
import { withWallet } from '../agent/agent-store'
import type {
  CreateDidCommOfferDto,
  OfferCredentialParams,
} from './didcomm-offer.dto'
import { PendingDidCommOfferStore } from './pending-didcomm-offer.store'

const DEFAULT_EXPIRES_IN_SECONDS = 1800

@Injectable()
export class DidCommService {
  private readonly logger = new Logger(DidCommService.name)

  constructor(
    private readonly config: ConfigService,
    private readonly pendingOffers: PendingDidCommOfferStore,
  ) {}

  /**
   * Envía `offer-credential` por una conexión ya lista (uso interno del auto-offer).
   *
   * @param walletId - ID de la wallet del issuer
   * @param params - `connectionId` + credential
   */
  async offerCredential(walletId: string, params: OfferCredentialParams) {
    return withWallet(walletId, (agent) => offerCredential(agent, params))
  }

  /**
   * Crea invitación OOB + pending offer en un solo paso (análogo a OID4VCI).
   *
   * No requiere `connectionId`: al completar o reusar la conexión ligada al OOB,
   * {@link onConnectionReady} envía el `offer-credential` vía Credo-TS.
   *
   * La URL devuelta es short URL RFC 0434 (`/oob/:pendingOfferId`): el JSON OOB
   * se descarga con GET + `Accept: application/json` y vive hasta `expiresAt`.
   *
   * @param walletId - ID de la wallet del issuer
   * @param body - Claims de la credencial y TTL opcional del pending
   * @returns URL corta de invitación (QR), `pendingOfferId` y `expiresAt` ISO
   */
  async createOffer(walletId: string, body: CreateDidCommOfferDto) {
    const domain = this.config.get<string>('invitationUrlPrefix')
    const expiresInSeconds = body.expiresInSeconds ?? DEFAULT_EXPIRES_IN_SECONDS

    // goal_code `issue-vc`: la wallet lo clasifica como flujo issue.
    const { outOfBandId, invitationMessage } = await withWallet(
      walletId,
      (agent) =>
        createInvitation(agent, {
          domain,
          goalCode: 'issue-vc',
          goal: 'Emisión de credencial',
        }),
    )

    const pending = this.pendingOffers.add({
      walletId,
      outOfBandId,
      credential: body.credential,
      invitationMessage,
      proofType: body.proofType,
      issuerDid: body.issuerDid,
      expiresInSeconds,
    })

    const base = (domain ?? '').replace(/\/$/, '')
    const shortInvitationUrl = `${base}/oob/${pending.pendingOfferId}`

    this.logger.log(
      `Pending DIDComm offer ${pending.pendingOfferId} oob=${outOfBandId} expiresAt=${pending.expiresAt.toISOString()}`,
    )

    return {
      invitation: shortInvitationUrl,
      pendingOfferId: pending.pendingOfferId,
      expiresAt: pending.expiresAt.toISOString(),
    }
  }

  /**
   * Sirve el mensaje OOB de una short URL (`GET /oob/:id`).
   *
   * @param invitationId - `pendingOfferId` embebido en la short URL
   * @returns JSON OOB o `null` si no existe / expiró
   */
  getShortInvitation(
    invitationId: string,
  ): Record<string, unknown> | null {
    return this.pendingOffers.findInvitationMessage(invitationId)
  }

  /**
   * Dispara el pending offer cuando la conexión DIDComm queda lista.
   *
   * Invocado desde los listeners Credo (`completed` o `HandshakeReused`).
   * Si no hay pending para el `outOfBandId`, o ya expiró, no hace nada.
   *
   * @param payload - `connectionId`, `outOfBandId` opcional y flag `reused`
   */
  async onConnectionReady(payload: ConnectionReadyPayload): Promise<void> {
    const outOfBandId = payload.outOfBandId
    if (!outOfBandId) {
      this.logger.debug(
        `Connection ${payload.connectionId} ready without outOfBandId (reused=${payload.reused})`,
      )
      return
    }

    const pending = this.pendingOffers.take(outOfBandId)
    if (!pending) {
      this.logger.debug(
        `No pending offer for oob=${outOfBandId} connection=${payload.connectionId}`,
      )
      return
    }

    this.logger.log(
      `Auto-offering pending ${pending.pendingOfferId} on connection=${payload.connectionId} reused=${payload.reused}`,
    )

    const result = await this.offerCredential(pending.walletId, {
      connectionId: payload.connectionId,
      credential: pending.credential,
      proofType: pending.proofType,
      issuerDid: pending.issuerDid,
    })

    if (result && typeof result === 'object' && 'error' in result) {
      this.logger.error(
        `Auto-offer failed for ${pending.pendingOfferId}: ${String((result as { error: string }).error)}`,
      )
    }
  }
}
