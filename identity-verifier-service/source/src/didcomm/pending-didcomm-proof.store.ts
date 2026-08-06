import { Injectable } from '@nestjs/common'
import { randomUUID } from 'crypto'

/**
 * Estados de un request DIDComm creado vía `POST .../didcomm/request`.
 *
 * - `pending`: invitación emitida; aún no hay conexión ni proof exchange.
 * - `request-sent`: se envió `request-presentation` (hay `proofExchangeRecordId`).
 * - `error`: falló el auto-request o el pending expiró sin conexión.
 */
export type PendingDidCommProofStatus = 'pending' | 'request-sent' | 'error'

/**
 * Sesión de verificación DIDComm ligada a un QR / `pendingRequestId`.
 *
 * Persiste en memoria el vínculo entre la invitación OOB y el proof exchange
 * de Credo-TS, permitiendo consultar el resultado con el ID devuelto al crear
 * el request (análogo a `verificationSessionId` en OID4VP).
 */
export interface PendingDidCommProof {
  /** Identificador público del request (respuesta de `POST .../didcomm/request`). */
  pendingRequestId: string
  /** Wallet/tenant del verifier que creó el request. */
  walletId: string
  /** ID del `OutOfBandRecord` Credo al que se enlaza el request. */
  outOfBandId: string
  presentationDefinition: Record<string, unknown>
  challenge?: string
  domain?: string
  /**
   * Mensaje OOB en JSON para short URL (`GET /oob/:pendingRequestId`).
   * Vigente hasta `expiresAt` (RFC 0434: TTL; no se invalida al primer GET).
   */
  invitationMessage: Record<string, unknown>
  status: PendingDidCommProofStatus
  /** ID del exchange Credo una vez enviado el `request-presentation`. */
  proofExchangeRecordId?: string
  /** Motivo si `status === 'error'`. */
  errorMessage?: string
  expiresAt: Date
  createdAt: Date
  updatedAt: Date
}

/**
 * Store en memoria de requests DIDComm indexados por `pendingRequestId` y OOB.
 *
 * - Por `outOfBandId`: dispara `requestProof` cuando la conexión queda lista.
 * - Por `pendingRequestId`: permite consultar el progreso / resultado del QR.
 */
@Injectable()
export class PendingDidCommProofStore {
  private readonly byPendingId = new Map<string, PendingDidCommProof>()
  private readonly byOutOfBandId = new Map<string, string>()

  /**
   * Registra un pending proof ligado a una invitación OOB.
   *
   * @param input - Parámetros del request y TTL en segundos
   * @returns Pending creado con `pendingRequestId` y `expiresAt`
   */
  add(input: {
    walletId: string
    outOfBandId: string
    presentationDefinition: Record<string, unknown>
    invitationMessage: Record<string, unknown>
    challenge?: string
    domain?: string
    expiresInSeconds: number
  }): PendingDidCommProof {
    this.purgeExpired()
    const now = new Date()
    const pending: PendingDidCommProof = {
      pendingRequestId: randomUUID(),
      walletId: input.walletId,
      outOfBandId: input.outOfBandId,
      presentationDefinition: input.presentationDefinition,
      invitationMessage: input.invitationMessage,
      challenge: input.challenge,
      domain: input.domain,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
      expiresAt: new Date(now.getTime() + input.expiresInSeconds * 1000),
    }
    this.byPendingId.set(pending.pendingRequestId, pending)
    this.byOutOfBandId.set(input.outOfBandId, pending.pendingRequestId)
    return pending
  }

  /**
   * Busca un pending por su ID público.
   *
   * @param pendingRequestId - ID devuelto al crear el request
   * @returns Pending vigente o `null` si no existe / expiró sin proof
   */
  findByPendingRequestId(pendingRequestId: string): PendingDidCommProof | null {
    this.purgeExpired()
    return this.byPendingId.get(pendingRequestId) ?? null
  }

  /**
   * Devuelve el mensaje OOB si el short id sigue dentro del TTL.
   *
   * No consume el pending (RFC 0434: invalidación por expiración, no al primer GET).
   *
   * @param pendingRequestId - ID público (= segmento de `GET /oob/:id`)
   * @returns JSON OOB o `null` si no existe / expiró
   */
  findInvitationMessage(
    pendingRequestId: string,
  ): Record<string, unknown> | null {
    this.purgeExpired()
    const pending = this.byPendingId.get(pendingRequestId)
    if (!pending) return null
    if (pending.expiresAt.getTime() <= Date.now()) return null
    return pending.invitationMessage
  }

  /**
   * Consume el pending asociado al OOB si sigue en `pending` y vigente.
   *
   * No elimina la sesión: solo quita el índice OOB para no disparar dos veces.
   * El registro queda consultable por `pendingRequestId`.
   *
   * @param outOfBandId - ID del `OutOfBandRecord` Credo
   * @returns Pending vigente o `null` si no hay / ya se disparó / expiró
   */
  take(outOfBandId: string): PendingDidCommProof | null {
    this.purgeExpired()
    const pendingRequestId = this.byOutOfBandId.get(outOfBandId)
    if (!pendingRequestId) return null

    const pending = this.byPendingId.get(pendingRequestId)
    this.byOutOfBandId.delete(outOfBandId)
    if (!pending) return null
    if (pending.status !== 'pending') return null
    if (pending.expiresAt.getTime() <= Date.now()) {
      this.markError(pending.pendingRequestId, 'Pending request expirado')
      return null
    }
    return pending
  }

  /**
   * Vincula el proof exchange de Credo al pending tras enviar el request.
   *
   * @param pendingRequestId - ID público del request
   * @param proofExchangeRecordId - ID del exchange Credo-TS
   */
  attachProofExchange(
    pendingRequestId: string,
    proofExchangeRecordId: string,
  ): void {
    const pending = this.byPendingId.get(pendingRequestId)
    if (!pending) return
    pending.status = 'request-sent'
    pending.proofExchangeRecordId = proofExchangeRecordId
    pending.updatedAt = new Date()
  }

  /**
   * Marca el pending como error (auto-request fallido o expiración).
   *
   * @param pendingRequestId - ID público del request
   * @param errorMessage - Motivo del fallo
   */
  markError(pendingRequestId: string, errorMessage: string): void {
    const pending = this.byPendingId.get(pendingRequestId)
    if (!pending) return
    pending.status = 'error'
    pending.errorMessage = errorMessage
    pending.updatedAt = new Date()
  }

  /**
   * Elimina pendings vencidos que aún no tienen proof exchange.
   *
   * Los que ya tienen `proofExchangeRecordId` se conservan para poder
   * consultar el resultado con el mismo `pendingRequestId` del QR.
   */
  private purgeExpired(): void {
    const now = Date.now()
    for (const [id, pending] of this.byPendingId) {
      if (pending.expiresAt.getTime() > now) continue
      if (pending.proofExchangeRecordId) continue
      if (pending.status === 'pending') {
        pending.status = 'error'
        pending.errorMessage = 'Pending request expirado'
        pending.updatedAt = new Date()
      }
      this.byOutOfBandId.delete(pending.outOfBandId)
      // Conservar un rato el error; si ya expiró y no hay proof, borrar.
      if (pending.status === 'error' && pending.expiresAt.getTime() + 300_000 <= now) {
        this.byPendingId.delete(id)
      }
    }
  }
}
