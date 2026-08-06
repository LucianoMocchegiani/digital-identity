import { Pool, PoolClient } from 'pg'

import { withRetry } from '../utils/retry'
import { CredentialAlreadyRevokedError } from './revocation.errors'
import type { StatusListInfo } from './status-list.types'
import type { StatusListStorage } from './status-list-storage.interface'

/** Versión del esquema gestionada por este adapter. Se loguea al inicializar. */
const SCHEMA_VERSION = 1

/**
 * Adapter Postgres para {@link StatusListStorage}.
 *
 * El `Pool` lo provee el servicio Nest (`StatusListStorageModule`). Este
 * adapter solo ejecuta queries y crea las dos tablas necesarias con DDL
 * idempotente. Tolerante a race conditions en el DDL inicial
 * (`42P07` duplicate_table, `23505` unique_violation).
 *
 * @module revocation
 */
export class PostgresStatusListStorage implements StatusListStorage {
  private readonly ready: Promise<void>

  constructor(private readonly pool: Pool) {
    this.ready = withRetry(() => this.initialize(), {
      attempts: 10,
      baseDelayMs: 2_000,
      maxDelayMs: 15_000,
      label: '[PostgresStatusListStorage]',
      shouldRetry: (err) => {
        const code = (err as { code?: string })?.code
        return code !== '42P07' && code !== '23505'
      },
    }).catch((err) => {
      console.error(
        '[PostgresStatusListStorage] initialization failed after all retries:',
        err instanceof Error ? err.message : err,
      )
    })
  }

  private async initialize(): Promise<void> {
    try {
      await this.pool.query(`CREATE EXTENSION IF NOT EXISTS pgcrypto`)
      await this.pool.query(`
        CREATE TABLE IF NOT EXISTS status_lists (
          id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          wallet_id            VARCHAR(128) NOT NULL,
          vct                  VARCHAR(256) NOT NULL,
          bits                 INT NOT NULL DEFAULT 1,
          capacity             INT NOT NULL DEFAULT 16384,
          compressed_bitstring TEXT NOT NULL,
          next_index           INT NOT NULL DEFAULT 0,
          revoked_count        INT NOT NULL DEFAULT 0,
          last_updated_at      TIMESTAMPTZ,
          created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
          updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
        )
      `)
    } catch (err: unknown) {
      const code = (err as { code?: string })?.code
      if (code !== '42P07' && code !== '23505') throw err
    }

    await this.pool.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS status_lists_wallet_vct_idx
      ON status_lists (wallet_id, vct)
    `)

    await this.pool.query(`
      CREATE TABLE IF NOT EXISTS status_list_revocations (
        id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        status_list_id  UUID NOT NULL REFERENCES status_lists(id) ON DELETE CASCADE,
        index           INT  NOT NULL,
        credential_id   VARCHAR(256),
        reason          VARCHAR(256),
        revoked_by      VARCHAR(128),
        revoked_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (status_list_id, index)
      )
    `)

    console.log(`[PostgresStatusListStorage] schema version ${SCHEMA_VERSION} ready`)
  }

  /**
   * Busca la StatusList del tenant para el VCT indicado.
   *
   * @param walletId - ID del tenant issuer.
   * @param vct - Verifiable Credential Type.
   * @returns `StatusListInfo` o `null` si no existe.
   */
  async findByWalletAndVct(walletId: string, vct: string): Promise<StatusListInfo | null> {
    await this.ready
    const { rows } = await this.pool.query<StatusListRow>(
      `SELECT id, wallet_id, vct, bits, capacity, compressed_bitstring,
              next_index, revoked_count, last_updated_at, created_at, updated_at
       FROM status_lists WHERE wallet_id = $1 AND vct = $2`,
      [walletId, vct],
    )
    return rows[0] ? toStatusListInfo(rows[0]) : null
  }

  /**
   * Busca una StatusList por su id interno.
   *
   * @param id - UUID interno de la lista.
   * @returns `StatusListInfo` o `null` si no existe.
   */
  async findById(id: string): Promise<StatusListInfo | null> {
    await this.ready
    const { rows } = await this.pool.query<StatusListRow>(
      `SELECT id, wallet_id, vct, bits, capacity, compressed_bitstring,
              next_index, revoked_count, last_updated_at, created_at, updated_at
       FROM status_lists WHERE id = $1`,
      [id],
    )
    return rows[0] ? toStatusListInfo(rows[0]) : null
  }

  /**
   * Persiste una nueva StatusList vacía para `(walletId, vct)`.
   *
   * @param data - Datos de la lista a crear.
   * @returns `StatusListInfo` con los valores persistidos (id, timestamps, etc.).
   * @throws {Error} Si ya existe una lista con ese `(walletId, vct)` (constraint UNIQUE).
   */
  async create(data: {
    walletId: string
    vct: string
    bits: 1 | 2 | 4 | 8
    capacity: number
    compressedBitstring: string
    nextIndex: number
  }): Promise<StatusListInfo> {
    await this.ready
    const { rows } = await this.pool.query<StatusListRow>(
      `INSERT INTO status_lists
         (wallet_id, vct, bits, capacity, compressed_bitstring, next_index)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, wallet_id, vct, bits, capacity, compressed_bitstring,
                 next_index, revoked_count, last_updated_at, created_at, updated_at`,
      [
        data.walletId,
        data.vct,
        data.bits,
        data.capacity,
        data.compressedBitstring,
        data.nextIndex,
      ],
    )
    return toStatusListInfo(rows[0])
  }

  /**
   * Actualiza la bitstring comprimida y el cursor `nextIndex` de la lista.
   *
   * Típicamente llamado desde `RevocationService.allocateIndex` después de
   * marcar un bit como válido.
   *
   * @param id - UUID interno de la lista.
   * @param compressedBitstring - Bitstring comprimida (formato TSL).
   * @param nextIndex - Nuevo valor del cursor secuencial.
   */
  async updateCompressedBitstring(
    id: string,
    compressedBitstring: string,
    nextIndex: number,
  ): Promise<void> {
    await this.ready
    await this.pool.query(
      `UPDATE status_lists
       SET compressed_bitstring = $1,
           next_index = $2,
           last_updated_at = NOW(),
           updated_at = NOW()
       WHERE id = $3`,
      [compressedBitstring, nextIndex, id],
    )
  }

  /**
   * Incrementa atómicamente el contador de revocaciones de la lista.
   *
   * @param id - UUID interno de la lista.
   */
  async incrementRevokedCount(id: string): Promise<void> {
    await this.ready
    await this.pool.query(
      `UPDATE status_lists SET revoked_count = revoked_count + 1 WHERE id = $1`,
      [id],
    )
  }

  /**
   * Inserta una fila de auditoría para una revocación.
   *
   * Mapea el error de Postgres `23505` (unique_violation en `UNIQUE
   * (status_list_id, index)`) a `CredentialAlreadyRevokedError` para que
   * `RevocationService` lo traduzca a un HTTP 409.
   *
   * @param data - Datos de la fila de auditoría.
   * @throws {CredentialAlreadyRevokedError} Si ya existe una fila para ese
   *   `(statusListId, index)`.
   */
  async saveRevocation(data: {
    statusListId: string
    index: number
    credentialId?: string
    reason?: string
    revokedBy?: string
  }): Promise<void> {
    await this.ready
    try {
      await this.pool.query(
        `INSERT INTO status_list_revocations
           (status_list_id, index, credential_id, reason, revoked_by)
         VALUES ($1, $2, $3, $4, $5)`,
        [data.statusListId, data.index, data.credentialId ?? null, data.reason ?? null, data.revokedBy ?? null],
      )
    } catch (err: unknown) {
      const code = (err as { code?: string })?.code
      if (code === '23505') {
        throw new CredentialAlreadyRevokedError(data.index)
      }
      throw err
    }
  }

  /**
   * Busca la fila de auditoría de una revocación previa.
   *
   * @param statusListId - UUID interno de la lista.
   * @param index - Índice revocado.
   * @returns Datos de la fila o `null` si no existe.
   */
  async findRevocation(
    statusListId: string,
    index: number,
  ): Promise<{
    id: string
    index: number
    credentialId?: string
    reason?: string
    revokedBy?: string
    revokedAt: Date
  } | null> {
    await this.ready
    const { rows } = await this.pool.query<{
      id: string
      index: number
      credential_id: string | null
      reason: string | null
      revoked_by: string | null
      revoked_at: Date
    }>(
      `SELECT id, index, credential_id, reason, revoked_by, revoked_at
       FROM status_list_revocations
       WHERE status_list_id = $1 AND index = $2`,
      [statusListId, index],
    )
    if (!rows[0]) return null
    const r = rows[0]
    return {
      id: r.id,
      index: r.index,
      credentialId: r.credential_id ?? undefined,
      reason: r.reason ?? undefined,
      revokedBy: r.revoked_by ?? undefined,
      revokedAt: r.revoked_at,
    }
  }

  /**
   * Actualiza `reason` y `revokedBy` de una revocación existente usando
   * `COALESCE` para no pisar valores no provistos.
   *
   * @param data - Datos a actualizar.
   */
  async updateRevocation(data: {
    statusListId: string
    index: number
    reason?: string
    revokedBy?: string
  }): Promise<void> {
    await this.ready
    await this.pool.query(
      `UPDATE status_list_revocations
       SET reason = COALESCE($1, reason),
           revoked_by = COALESCE($2, revoked_by),
           revoked_at = NOW()
       WHERE status_list_id = $3 AND index = $4`,
      [data.reason ?? null, data.revokedBy ?? null, data.statusListId, data.index],
    )
  }

  /**
   * Ejecuta `fn` dentro de una transacción Postgres (`BEGIN`/`COMMIT`/`ROLLBACK`).
   *
   * El parámetro `tx` es una instancia de `StatusListStorage` que comparte
   * la misma conexión, garantizando atomicidad entre las operaciones que
   * `fn` ejecute. Si alguna operación lanza, se hace rollback completo.
   *
   * @param fn - Función que recibe el `tx` con la misma interfaz.
   * @returns Lo que `fn` retorne.
   */
  async withTransaction<T>(fn: (tx: StatusListStorage) => Promise<T>): Promise<T> {
    const client = await this.pool.connect()
    try {
      await client.query('BEGIN')
      const txStorage = new PostgresStatusListStorageTx(client)
      const result = await fn(txStorage)
      await client.query('COMMIT')
      return result
    } catch (err) {
      await client.query('ROLLBACK').catch(() => undefined)
      throw err
    } finally {
      client.release()
    }
  }
}

/** Variante transaccional del adapter. Comparte el contrato pero usa `PoolClient`. */
class PostgresStatusListStorageTx implements StatusListStorage {
  constructor(private readonly client: PoolClient) {}

  private async run<T extends Record<string, unknown>>(
    sql: string,
    params: unknown[],
  ): Promise<{ rows: T[] }> {
    const result = await this.client.query(sql, params)
    return { rows: result.rows as T[] }
  }

  async findByWalletAndVct(walletId: string, vct: string): Promise<StatusListInfo | null> {
    const { rows } = await this.run<StatusListRow>(
      `SELECT id, wallet_id, vct, bits, capacity, compressed_bitstring,
              next_index, revoked_count, last_updated_at, created_at, updated_at
       FROM status_lists WHERE wallet_id = $1 AND vct = $2`,
      [walletId, vct],
    )
    return rows[0] ? toStatusListInfo(rows[0]) : null
  }

  async findById(id: string): Promise<StatusListInfo | null> {
    const { rows } = await this.run<StatusListRow>(
      `SELECT id, wallet_id, vct, bits, capacity, compressed_bitstring,
              next_index, revoked_count, last_updated_at, created_at, updated_at
       FROM status_lists WHERE id = $1`,
      [id],
    )
    return rows[0] ? toStatusListInfo(rows[0]) : null
  }

  async create(data: {
    walletId: string
    vct: string
    bits: 1 | 2 | 4 | 8
    capacity: number
    compressedBitstring: string
    nextIndex: number
  }): Promise<StatusListInfo> {
    const { rows } = await this.run<StatusListRow>(
      `INSERT INTO status_lists
         (wallet_id, vct, bits, capacity, compressed_bitstring, next_index)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, wallet_id, vct, bits, capacity, compressed_bitstring,
                 next_index, revoked_count, last_updated_at, created_at, updated_at`,
      [
        data.walletId,
        data.vct,
        data.bits,
        data.capacity,
        data.compressedBitstring,
        data.nextIndex,
      ],
    )
    return toStatusListInfo(rows[0])
  }

  async updateCompressedBitstring(
    id: string,
    compressedBitstring: string,
    nextIndex: number,
  ): Promise<void> {
    await this.run(
      `UPDATE status_lists
       SET compressed_bitstring = $1,
           next_index = $2,
           last_updated_at = NOW(),
           updated_at = NOW()
       WHERE id = $3`,
      [compressedBitstring, nextIndex, id],
    )
  }

  async incrementRevokedCount(id: string): Promise<void> {
    await this.run(
      `UPDATE status_lists SET revoked_count = revoked_count + 1 WHERE id = $1`,
      [id],
    )
  }

  async saveRevocation(data: {
    statusListId: string
    index: number
    credentialId?: string
    reason?: string
    revokedBy?: string
  }): Promise<void> {
    try {
      await this.run(
        `INSERT INTO status_list_revocations
           (status_list_id, index, credential_id, reason, revoked_by)
         VALUES ($1, $2, $3, $4, $5)`,
        [data.statusListId, data.index, data.credentialId ?? null, data.reason ?? null, data.revokedBy ?? null],
      )
    } catch (err: unknown) {
      const code = (err as { code?: string })?.code
      if (code === '23505') {
        throw new CredentialAlreadyRevokedError(data.index)
      }
      throw err
    }
  }

  async findRevocation(
    statusListId: string,
    index: number,
  ): Promise<{
    id: string
    index: number
    credentialId?: string
    reason?: string
    revokedBy?: string
    revokedAt: Date
  } | null> {
    const { rows } = await this.run<{
      id: string
      index: number
      credential_id: string | null
      reason: string | null
      revoked_by: string | null
      revoked_at: Date
    }>(
      `SELECT id, index, credential_id, reason, revoked_by, revoked_at
       FROM status_list_revocations
       WHERE status_list_id = $1 AND index = $2`,
      [statusListId, index],
    )
    if (!rows[0]) return null
    const r = rows[0]
    return {
      id: r.id,
      index: r.index,
      credentialId: r.credential_id ?? undefined,
      reason: r.reason ?? undefined,
      revokedBy: r.revoked_by ?? undefined,
      revokedAt: r.revoked_at,
    }
  }

  async updateRevocation(data: {
    statusListId: string
    index: number
    reason?: string
    revokedBy?: string
  }): Promise<void> {
    await this.run(
      `UPDATE status_list_revocations
       SET reason = COALESCE($1, reason),
           revoked_by = COALESCE($2, revoked_by),
           revoked_at = NOW()
       WHERE status_list_id = $3 AND index = $4`,
      [data.reason ?? null, data.revokedBy ?? null, data.statusListId, data.index],
    )
  }

  /**
   * Las transacciones no se anidan en Postgres: si el caller ya está dentro
   * de una transacción, devolvemos el mismo `tx` para que las operaciones se
   * ejecuten sobre la misma conexión.
   */
  async withTransaction<T>(fn: (tx: StatusListStorage) => Promise<T>): Promise<T> {
    return fn(this)
  }
}

/** Forma cruda de la fila en la tabla `status_lists`. */
type StatusListRow = {
  id: string
  wallet_id: string
  vct: string
  bits: 1 | 2 | 4 | 8
  capacity: number
  compressed_bitstring: string
  next_index: number
  revoked_count: number
  last_updated_at: Date | null
  created_at: Date
  updated_at: Date
}

function toStatusListInfo(row: StatusListRow): StatusListInfo {
  return {
    id: row.id,
    walletId: row.wallet_id,
    vct: row.vct,
    bits: row.bits,
    capacity: row.capacity,
    compressedBitstring: row.compressed_bitstring,
    nextIndex: row.next_index,
    revokedCount: row.revoked_count,
    lastUpdatedAt: row.last_updated_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}