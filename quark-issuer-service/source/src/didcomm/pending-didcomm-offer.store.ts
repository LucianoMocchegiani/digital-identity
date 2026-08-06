import { Injectable } from '@nestjs/common'
import { randomUUID } from 'crypto'
import type { CredentialDto } from './didcomm-offer.dto'

/**
 * Offer DIDComm pendiente de que el holder complete (o reúse) la conexión OOB.
 */
export interface PendingDidCommOffer {
  /** Identificador público del pending (respuesta de `POST .../didcomm/offer`). */
  pendingOfferId: string
  /** Wallet/tenant del issuer que creó el offer. */
  walletId: string
  /** ID del `OutOfBandRecord` Credo al que se enlaza el offer. */
  outOfBandId: string
  credential: CredentialDto
  proofType?: string
  issuerDid?: string
  /**
   * Mensaje OOB en JSON para short URL (`GET /oob/:pendingOfferId`).
   * Vigente hasta `expiresAt` (RFC 0434: TTL; no se invalida al primer GET).
   */
  invitationMessage: Record<string, unknown>
  /** Si ya se disparó el auto-offer (el índice OOB se consumió). */
  consumed: boolean
  expiresAt: Date
  createdAt: Date
}

/**
 * Store en memoria de offers DIDComm indexados por `pendingOfferId` y OOB.
 *
 * - Por `outOfBandId`: dispara `offerCredential` cuando la conexión queda lista.
 * - Por `pendingOfferId`: sirve la short URL OOB hasta el TTL.
 */
@Injectable()
export class PendingDidCommOfferStore {
  private readonly byPendingId = new Map<string, PendingDidCommOffer>()
  private readonly byOutOfBandId = new Map<string, string>()

  /**
   * Registra un pending offer ligado a una invitación OOB.
   *
   * @param input - Datos del offer, mensaje OOB y TTL en segundos
   * @returns Pending creado con `pendingOfferId` y `expiresAt`
   */
  add(input: {
    walletId: string
    outOfBandId: string
    credential: CredentialDto
    invitationMessage: Record<string, unknown>
    proofType?: string
    issuerDid?: string
    expiresInSeconds: number
  }): PendingDidCommOffer {
    this.purgeExpired()
    const now = new Date()
    const pending: PendingDidCommOffer = {
      pendingOfferId: randomUUID(),
      walletId: input.walletId,
      outOfBandId: input.outOfBandId,
      credential: input.credential,
      invitationMessage: input.invitationMessage,
      proofType: input.proofType,
      issuerDid: input.issuerDid,
      consumed: false,
      createdAt: now,
      expiresAt: new Date(now.getTime() + input.expiresInSeconds * 1000),
    }
    this.byPendingId.set(pending.pendingOfferId, pending)
    this.byOutOfBandId.set(input.outOfBandId, pending.pendingOfferId)
    return pending
  }

  /**
   * Devuelve el mensaje OOB si el short id sigue dentro del TTL.
   *
   * No consume el pending (RFC 0434: invalidación por expiración, no al primer GET).
   *
   * @param pendingOfferId - ID público (= segmento de `GET /oob/:id`)
   * @returns JSON OOB o `null` si no existe / expiró
   */
  findInvitationMessage(
    pendingOfferId: string,
  ): Record<string, unknown> | null {
    this.purgeExpired()
    const pending = this.byPendingId.get(pendingOfferId)
    if (!pending) return null
    if (pending.expiresAt.getTime() <= Date.now()) return null
    return pending.invitationMessage
  }

  /**
   * Consume el pending asociado al OOB si sigue vigente y no fue disparado.
   *
   * Quita el índice OOB para no re-disparar el offer; el registro sigue
   * consultable por `pendingOfferId` (short URL) hasta el TTL.
   *
   * @param outOfBandId - ID del `OutOfBandRecord` Credo
   * @returns Pending vigente o `null` si no hay / expiró / ya se consumió
   */
  take(outOfBandId: string): PendingDidCommOffer | null {
    this.purgeExpired()
    const pendingOfferId = this.byOutOfBandId.get(outOfBandId)
    if (!pendingOfferId) return null

    const pending = this.byPendingId.get(pendingOfferId)
    this.byOutOfBandId.delete(outOfBandId)
    if (!pending || pending.consumed) return null
    if (pending.expiresAt.getTime() <= Date.now()) return null

    pending.consumed = true
    return pending
  }

  /** Elimina del mapa los pending cuyo `expiresAt` ya pasó. */
  private purgeExpired(): void {
    const now = Date.now()
    for (const [id, pending] of this.byPendingId) {
      if (pending.expiresAt.getTime() > now) continue
      this.byOutOfBandId.delete(pending.outOfBandId)
      this.byPendingId.delete(id)
    }
  }
}
