import type { BitsPerStatus, StatusListInfo } from './status-list.types'

/**
 * Puerto de persistencia para StatusList y revocaciones.
 *
 * El core (`@quarkid/identity-core`) lo usa para persistir el estado del
 * Token Status List (TSL). El consumidor (servicio Nest) provee un adapter
 * concreto (típicamente `PostgresStatusListStorage` sobre un `pg.Pool`).
 *
 * El método `withTransaction` permite agrupar varias operaciones
 * (p. ej. `revoke`: actualizar bitstring + incrementar contador + registrar
 * fila de auditoría) en una transacción Postgres real.
 *
 * @module revocation
 */
export interface StatusListStorage {
  /**
   * Busca la StatusList de un tenant para un VCT concreto.
   * Una sola lista por `(walletId, vct)`.
   */
  findByWalletAndVct(walletId: string, vct: string): Promise<StatusListInfo | null>

  /** Busca la StatusList por su id interno. */
  findById(id: string): Promise<StatusListInfo | null>

  /**
   * Persiste una nueva StatusList vacía para `(walletId, vct)`.
   * Lanza error si ya existe (constraint UNIQUE en la BD).
   */
  create(data: {
    walletId: string
    vct: string
    bits: BitsPerStatus
    capacity: number
    compressedBitstring: string
    nextIndex: number
  }): Promise<StatusListInfo>

  /**
   * Actualiza la bitstring comprimida y el cursor `nextIndex`.
   * Llamado por `allocateIndex` después de marcar un bit como válido.
   */
  updateCompressedBitstring(id: string, compressedBitstring: string, nextIndex: number): Promise<void>

  /** Incrementa atómicamente el contador de revocaciones. */
  incrementRevokedCount(id: string): Promise<void>

  /**
   * Inserta una fila de auditoría para una revocación.
   * Lanza `CredentialAlreadyRevokedError` si ya existe (código Postgres `23505`).
   */
  saveRevocation(data: {
    statusListId: string
    index: number
    credentialId?: string
    reason?: string
    revokedBy?: string
  }): Promise<void>

  /** Busca la fila de auditoría para una revocación previa. */
  findRevocation(
    statusListId: string,
    index: number,
  ): Promise<{
    id: string
    index: number
    credentialId?: string
    reason?: string
    revokedBy?: string
    revokedAt: Date
  } | null>

  /**
   * Actualiza el motivo / revoker de una revocación existente.
   * Llamado cuando se re-revoca un índice ya revocado.
   */
  updateRevocation(data: {
    statusListId: string
    index: number
    reason?: string
    revokedBy?: string
  }): Promise<void>

  /**
   * Ejecuta `fn` dentro de una transacción. Si `fn` lanza, se hace rollback.
   * El parámetro `tx` es un `StatusListStorage` que usa la misma conexión
   * comprometida, garantizando atomicidad.
   *
   * @example
   * ```ts
   * await storage.withTransaction(async (tx) => {
   *   await tx.updateCompressedBitstring(id, compressed, nextIndex)
   *   await tx.incrementRevokedCount(id)
   *   await tx.saveRevocation({ statusListId: id, index, reason })
   * })
   * ```
   */
  withTransaction<T>(fn: (tx: StatusListStorage) => Promise<T>): Promise<T>
}