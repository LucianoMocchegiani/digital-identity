import { Injectable, Logger, NotFoundException } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import {
  createInvitation,
  getDidCommProofDetails,
  requestProof,
  type ConnectionReadyPayload,
  type DidCommProofDetails,
} from '@quarkid/identity-core'
import { withWallet } from '../agent/agent-store'
import type {
  CreateDidCommRequestDto,
  RequestProofParams,
} from './didcomm-request.dto'
import { PendingDidCommProofStore } from './pending-didcomm-proof.store'

const DEFAULT_EXPIRES_IN_SECONDS = 1800

/**
 * Estado consultable de un request DIDComm (`GET .../didcomm/request/:pendingRequestId`).
 *
 * Combina el tracking en memoria del QR con el detalle Credo cuando ya existe
 * el proof exchange.
 */
export type DidCommRequestStatus = {
  pendingRequestId: string
  /** `pending` | `request-sent` | `done` | `error` */
  status: 'pending' | 'request-sent' | 'done' | 'error'
  expiresAt: string
  createdAt: string
  updatedAt: string
  proofExchangeRecordId?: string
  proofState?: string
  connectionId?: string
  threadId?: string
  isVerified?: boolean
  errorMessage?: string
  request?: unknown
  presentation?: unknown
}

@Injectable()
export class DidCommService {
  private readonly logger = new Logger(DidCommService.name)

  constructor(
    private readonly config: ConfigService,
    private readonly pendingProofs: PendingDidCommProofStore,
  ) {}

  /**
   * Envía `request-presentation` por una conexión ya lista (uso interno del auto-request).
   *
   * @param walletId - ID de la wallet del verifier
   * @param params - `connectionId` + presentation definition
   */
  async requestProof(walletId: string, params: RequestProofParams): Promise<{
    proofExchangeRecordId: string
    state: string
    mode: string
    error?: string
  }> {
    return withWallet(walletId, (agent) => requestProof(agent, params))
  }

  /**
   * Crea invitación OOB + pending proof en un solo paso (análogo a issuer `didcomm/offer`).
   *
   * No requiere `connectionId`: al completar o reusar la conexión ligada al OOB,
   * {@link onConnectionReady} envía el `request-presentation` vía Credo-TS.
   *
   * La URL devuelta es short URL RFC 0434 (`/oob/:pendingRequestId`): el JSON OOB
   * se descarga con GET + `Accept: application/json` y vive hasta `expiresAt`.
   *
   * @param walletId - ID de la wallet del verifier
   * @param body - Parámetros PEX y TTL opcional del pending
   * @returns URL corta de invitación (QR), `pendingRequestId` y `expiresAt` ISO
   */
  async createRequest(walletId: string, body: CreateDidCommRequestDto) {
    const domain = this.config.get<string>('invitationUrlPrefix')
    const expiresInSeconds = body.expiresInSeconds ?? DEFAULT_EXPIRES_IN_SECONDS

    // goal_code `request-proof`: la wallet lo clasifica como flujo verify
    // (sin él cae en connect y descarta el request-presentation).
    const { outOfBandId, invitationMessage } = await withWallet(
      walletId,
      (agent) =>
        createInvitation(agent, {
          domain,
          goalCode: 'request-proof',
          goal: 'Verificación de credenciales',
        }),
    )

    const pending = this.pendingProofs.add({
      walletId,
      outOfBandId,
      presentationDefinition: body.presentationDefinition,
      invitationMessage,
      challenge: body.challenge,
      domain: body.domain,
      expiresInSeconds,
    })

    const base = (domain ?? '').replace(/\/$/, '')
    const shortInvitationUrl = `${base}/oob/${pending.pendingRequestId}`

    this.logger.log(
      `Pending DIDComm proof ${pending.pendingRequestId} oob=${outOfBandId} expiresAt=${pending.expiresAt.toISOString()}`,
    )

    return {
      invitation: shortInvitationUrl,
      pendingRequestId: pending.pendingRequestId,
      expiresAt: pending.expiresAt.toISOString(),
    }
  }

  /**
   * Sirve el mensaje OOB de una short URL (`GET /oob/:id`).
   *
   * @param invitationId - `pendingRequestId` embebido en la short URL
   * @returns JSON OOB o `null` si no existe / expiró
   */
  getShortInvitation(
    invitationId: string,
  ): Record<string, unknown> | null {
    return this.pendingProofs.findInvitationMessage(invitationId)
  }

  /**
   * Dispara el pending proof cuando la conexión DIDComm queda lista.
   *
   * Invocado desde los listeners Credo (`completed` o `HandshakeReused`).
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

    const pending = this.pendingProofs.take(outOfBandId)
    if (!pending) {
      this.logger.debug(
        `No pending proof for oob=${outOfBandId} connection=${payload.connectionId}`,
      )
      return
    }

    this.logger.log(
      `Auto-requesting proof ${pending.pendingRequestId} on connection=${payload.connectionId} reused=${payload.reused}`,
    )

    const result = await this.requestProof(pending.walletId, {
      connectionId: payload.connectionId,
      presentationDefinition: pending.presentationDefinition,
      challenge: pending.challenge,
      domain: pending.domain,
    })

    if (result.error || !result.proofExchangeRecordId) {
      const message = result.error ?? 'Auto-request sin proofExchangeRecordId'
      this.pendingProofs.markError(pending.pendingRequestId, message)
      this.logger.error(
        `Auto-request failed for ${pending.pendingRequestId}: ${message}`,
      )
      return
    }

    this.pendingProofs.attachProofExchange(
      pending.pendingRequestId,
      result.proofExchangeRecordId,
    )
  }

  /**
   * Consulta el progreso / resultado de un request DIDComm por `pendingRequestId`.
   *
   * Análogo a `GET .../openid4vc/session/:id`: usa el ID devuelto al crear el QR
   * y, cuando el proof exchange existe, incluye la VP y los claims verificados.
   *
   * @param walletId - ID de la wallet del verifier
   * @param pendingRequestId - ID público retornado por `POST .../didcomm/request`
   * @returns Estado del request y detalle de la verificación si ya existe
   * @throws {NotFoundException} Si el pending no pertenece al tenant o no existe
   */
  async getRequestByPendingId(
    walletId: string,
    pendingRequestId: string,
  ): Promise<DidCommRequestStatus> {
    const pending = this.pendingProofs.findByPendingRequestId(pendingRequestId)
    if (!pending || pending.walletId !== walletId) {
      throw new NotFoundException(
        `Request DIDComm '${pendingRequestId}' no encontrado`,
      )
    }

    const base: DidCommRequestStatus = {
      pendingRequestId: pending.pendingRequestId,
      status: pending.status,
      expiresAt: pending.expiresAt.toISOString(),
      createdAt: pending.createdAt.toISOString(),
      updatedAt: pending.updatedAt.toISOString(),
      proofExchangeRecordId: pending.proofExchangeRecordId,
      errorMessage: pending.errorMessage,
    }

    if (!pending.proofExchangeRecordId) {
      return base
    }

    const details = await withWallet(walletId, (agent) =>
      getDidCommProofDetails(agent, pending.proofExchangeRecordId!),
    )
    if (!details) {
      return {
        ...base,
        status: 'error',
        errorMessage:
          pending.errorMessage ??
          `Proof exchange '${pending.proofExchangeRecordId}' no encontrado`,
      }
    }

    return {
      ...base,
      // Cuando Credo marca done, el status operativo del request es `done`.
      status:
        details.state === 'done'
          ? 'done'
          : details.state === 'abandoned'
            ? 'error'
            : pending.status,
      isVerified: details.isVerified,
      proofState: details.state,
      connectionId: details.connectionId,
      threadId: details.threadId,
      request: details.request,
      presentation: details.presentation,
      errorMessage: details.errorMessage ?? pending.errorMessage,
    }
  }

  /**
   * Recupera el resultado completo de una verificación DIDComm.
   *
   * Incluye el estado e indicador criptográfico del exchange, el request DIF
   * PEX original y la VP JSON-LD recibida con sus credenciales y claims.
   *
   * @param walletId - ID de la wallet del verifier
   * @param proofExchangeRecordId - ID del exchange DIDComm de Credo-TS
   * @returns Detalle auditable de la presentación verificada
   * @throws {NotFoundException} Si el exchange no existe en el tenant
   */
  async getProofDetails(
    walletId: string,
    proofExchangeRecordId: string,
  ): Promise<DidCommProofDetails> {
    const details = await withWallet(walletId, (agent) =>
      getDidCommProofDetails(agent, proofExchangeRecordId),
    )
    if (!details) {
      throw new NotFoundException(
        `Proof DIDComm '${proofExchangeRecordId}' no encontrado`,
      )
    }
    return details
  }
}
