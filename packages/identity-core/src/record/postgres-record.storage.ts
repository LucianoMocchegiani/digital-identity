import type {
  AgentContext,
  BaseRecord,
  BaseRecordConstructor,
} from "@credo-ts/core";
import { JsonTransformer, StorageVersionRecord } from "@credo-ts/core";
import { Pool } from "pg";
import { withRetry } from "../utils/retry";
import type { RecordStorage } from "./record-storage.interface";
import {
  buildRecordsPageMeta,
  type PaginatedRecords,
  type RecordTagQuery,
  type RecordsPageOptions,
} from "./record-storage.types";
import { buildTagQuerySql } from "./record-query.sql";

/**
 * Tipo que representa los tags indexables de un record de Credo-TS.
 * Refleja el contrato de `BaseRecord.getTags()`.
 */
type TagsBase = Record<string, string | string[] | boolean | undefined | null>;

/**
 * Estructura persistida en la base de datos para cada record.
 * Separa la metadata de indexación (`tags`) de los datos propios del record (`data`).
 *
 * @template T - Forma de los datos específicos del record (resultado de `toJSON()`)
 */
interface StoredRecord<
  T extends Record<string, unknown> = Record<string, unknown>,
> {
  id: string;
  type?: string;
  createdAt?: string;
  updatedAt?: string;
  /** Tags computados via `getTags()` — usados exclusivamente por `matchesQuery` para filtrar. */
  tags: TagsBase;
  /** Datos serializados del record, pasados a `JsonTransformer.fromJSON` al leer. */
  data: T;
}

/**
 * Query de búsqueda compatible con el sistema de tags de Credo-TS.
 * @deprecated Usar {@link RecordTagQuery} desde `record-storage.types`.
 */
type RecordQuery = RecordTagQuery;

/**
 * Adapter Postgres para {@link RecordStorage}.
 *
 * El `Pool` lo crea y cierra el servicio Nest (issuer/holder); identity-core solo
 * ejecuta queries y migraciones ligeras de esquema al arrancar.
 */
export class PostgresRecordStorage implements RecordStorage {
  private readonly ready: Promise<void>;

  constructor(
    private readonly pool: Pool,
    private readonly walletId: string = 'default',
  ) {
    this.ready = withRetry(() => this.initialize(), {
      attempts: 10,
      baseDelayMs: 2_000,
      maxDelayMs: 15_000,
      label: "[PostgresRecordStorage]",
      shouldRetry: (err) => {
        const pgErr = err as { code?: string };
        return pgErr?.code !== "42P07" && pgErr?.code !== "23505";
      },
    }).catch((err) => {
      console.error(
        "[PostgresRecordStorage] initialization failed after all retries:",
        err?.message ?? err,
      );
    });
  }

  private async initialize(): Promise<void> {
    try {
      await this.pool.query(`
        CREATE TABLE IF NOT EXISTS records (
          type TEXT NOT NULL,
          id   TEXT NOT NULL,
          data TEXT NOT NULL,
          PRIMARY KEY (type, id)
        )
      `);
    } catch (err: unknown) {
      const pgErr = err as { code?: string };
      // 42P07 = duplicate_table, 23505 = unique_violation (race condition en pg_type)
      if (pgErr?.code === "42P07" || pgErr?.code === "23505") {
        console.warn(
          "[PostgresRecordStorage] table already exists (race condition) — continuing",
        );
      } else {
        throw err;
      }
    }
    await this.pool.query(`ALTER TABLE records ADD COLUMN IF NOT EXISTS wallet_id TEXT NOT NULL DEFAULT ''`);
    await this.pool.query(`CREATE INDEX IF NOT EXISTS records_wallet_id_idx ON records(wallet_id)`);
    await this.pool.query(
      `CREATE INDEX IF NOT EXISTS records_wallet_type_idx ON records(wallet_id, type)`,
    );
    await this.seedStorageVersionRecord();
  }

  /**
   * Inserta el `StorageVersionRecord` requerido por Credo-TS para validar
   * la versión del schema de storage. Se ejecuta una sola vez al inicializar.
   */
  private async seedStorageVersionRecord(): Promise<void> {
    const SVR = StorageVersionRecord as unknown as {
      type: string
      storageVersionRecordId: string
      frameworkStorageVersion: string
    }
    const type = SVR.type ?? 'StorageVersionRecord'
    const id = SVR.storageVersionRecordId ?? 'STORAGE_VERSION_RECORD_ID'
    const version = SVR.frameworkStorageVersion ?? '1'

    const stored: StoredRecord = {
      id: id,
      type: type,
      createdAt: new Date().toISOString(),
      tags: {},
      data: {
        id: id,
        createdAt: new Date().toISOString(),
        storageVersion: version,
        type: type,
      },
    };
    await this.pool.query(
      'INSERT INTO records (type, id, wallet_id, data) VALUES ($1, $2, $3, $4) ON CONFLICT (type, id) DO NOTHING',
      [type, id, this.walletId, JSON.stringify(stored)]
    )
  }

  /**
   * Garantiza que la instancia retornada por `JsonTransformer.fromJSON` sea
   * una instancia real de la clase (con el método `clone` disponible).
   * Necesario porque `fromJSON` puede retornar un objeto plano en algunos contextos.
   */
  private ensureRecordInstance<T>(
    instance: T | null,
    recordClass: BaseRecordConstructor<T>,
  ): T | null {
    if (!instance) return null;
    if (typeof (instance as Record<string, unknown>).clone === "function")
      return instance;
    return JsonTransformer.fromJSON(
      JsonTransformer.toJSON(instance),
      recordClass,
      { validate: false },
    ) as T;
  }

  /**
   * Construye el `StoredRecord` a partir de un record Credo-TS.
   * Llama a `getTags()` para capturar los tags computados que se usarán en queries,
   * y a `toJSON()` para obtener los datos serializables.
   *
   * @param record - Record Credo-TS a serializar (cualquier subtipo de `BaseRecord`)
   */
  private buildStoredRecord(record: BaseRecord): StoredRecord {
    const type = (record.constructor as { type?: string }).type ?? "record";
    const rawData = record.toJSON();
    return {
      id: record.id,
      type,
      createdAt: rawData.createdAt as string | undefined,
      updatedAt: rawData.updatedAt as string | undefined,
      tags: record.getTags() as TagsBase,
      data: rawData as Record<string, unknown>,
    };
  }

  /**
   * Persiste un nuevo record en la base de datos.
   * Si ya existe un record con el mismo `(type, id)`, lo reemplaza.
   *
   * @param record - Record Credo-TS a guardar (cualquier subtipo de `QuarkWalletRecord`)
   */
  async save(ctx: AgentContext, record: BaseRecord): Promise<void> {
    await this.ready;
    const stored = this.buildStoredRecord(record);
    await this.pool.query(
      "INSERT INTO records (type, id, wallet_id, data) VALUES ($1, $2, $3, $4) ON CONFLICT (type, id) DO UPDATE SET data = EXCLUDED.data",
      [stored.type ?? "record", stored.id, ctx.contextCorrelationId, JSON.stringify(stored)],
    );
  }

  /**
   * Actualiza un record existente en la base de datos.
   * Re-computa los tags via `getTags()` para mantener el índice actualizado.
   *
   * @param record - Record Credo-TS con los datos actualizados (cualquier subtipo de `QuarkWalletRecord`)
   */
  async update(ctx: AgentContext, record: BaseRecord): Promise<void> {
    await this.ready;
    const stored = this.buildStoredRecord(record);
    await this.pool.query(
      "UPDATE records SET data = $1 WHERE type = $2 AND id = $3 AND wallet_id = $4",
      [JSON.stringify(stored), stored.type ?? "record", stored.id, ctx.contextCorrelationId],
    );
  }

  async delete(ctx: AgentContext, record: BaseRecord): Promise<void> {
    await this.ready;
    const type = (record.constructor as { type?: string }).type ?? "record";
    await this.pool.query("DELETE FROM records WHERE type = $1 AND id = $2 AND wallet_id = $3", [
      type,
      record.id,
      ctx.contextCorrelationId,
    ]);
  }

  async deleteById<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    id: string,
  ): Promise<void> {
    await this.ready;
    await this.pool.query("DELETE FROM records WHERE type = $1 AND id = $2 AND wallet_id = $3", [
      recordClass.type,
      id,
      ctx.contextCorrelationId,
    ]);
  }

  async getById<T>(ctx: AgentContext, recordClass: BaseRecordConstructor<T>, id: string): Promise<T | null> {
    await this.ready
    const { rows } = await this.pool.query<{ data: string }>('SELECT data FROM records WHERE type = $1 AND id = $2 AND wallet_id = $3', [recordClass.type, id, ctx.contextCorrelationId])
    if (!rows.length) return null
    const stored = JSON.parse(rows[0].data) as StoredRecord
    return this.ensureRecordInstance(JsonTransformer.fromJSON(stored.data, recordClass, { validate: false }), recordClass)
  }

  async getAll<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
  ): Promise<T[]> {
    await this.ready;
    const { rows } = await this.pool.query<{ data: string }>(
      "SELECT data FROM records WHERE type = $1 AND wallet_id = $2",
      [recordClass.type, ctx.contextCorrelationId],
    );
    return rows
      .map((row) => {
        const stored = JSON.parse(row.data) as StoredRecord;
        return this.ensureRecordInstance(
          JsonTransformer.fromJSON(stored.data, recordClass, { validate: false }),
          recordClass,
        );
      })
      .filter((r): r is T => r !== null);
  }

  /**
   * Lista records del tipo indicado con paginación en PostgreSQL.
   *
   * Orden: `createdAt` descendente, luego `id` ascendente.
   *
   * @param ctx - Contexto del tenant (`contextCorrelationId` = scope en `wallet_id`)
   * @param recordClass - Clase Credo que define el `type` en la tabla `records`
   * @param options - Página y límite normalizados
   */
  async getAllPaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    options: RecordsPageOptions,
  ): Promise<PaginatedRecords<T>> {
    await this.ready;
    const { rows: countRows } = await this.pool.query<{ count: string }>(
      "SELECT COUNT(*)::text AS count FROM records WHERE type = $1 AND wallet_id = $2",
      [recordClass.type, ctx.contextCorrelationId],
    );
    const total = Number.parseInt(countRows[0]?.count ?? "0", 10);
    const offset = (options.page - 1) * options.limit;

    const { rows } = await this.pool.query<{ data: string }>(
      `SELECT data FROM records WHERE type = $1 AND wallet_id = $2
       ORDER BY (data::jsonb->>'createdAt') DESC NULLS LAST, id ASC
       LIMIT $3 OFFSET $4`,
      [recordClass.type, ctx.contextCorrelationId, options.limit, offset],
    );

    const items = rows
      .map((row) => {
        const stored = JSON.parse(row.data) as StoredRecord;
        return this.ensureRecordInstance(
          JsonTransformer.fromJSON(stored.data, recordClass, { validate: false }),
          recordClass,
        );
      })
      .filter((r): r is T => r !== null);

    return {
      items,
      pagination: buildRecordsPageMeta(total, options.page, options.limit),
    };
  }

  /**
   * Selecciona records persistidos filtrando por tags en PostgreSQL.
   * Con `pagination`, aplica LIMIT/OFFSET en la query.
   */
  private async selectStoredByTagQuery(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<unknown>,
    query: RecordQuery,
    pagination?: RecordsPageOptions,
  ): Promise<{ items: StoredRecord[]; total: number }> {
    await this.ready;
    const tagSql = buildTagQuerySql(query, 3);
    const where = `type = $1 AND wallet_id = $2 AND (${tagSql.clause})`;
    const baseParams: unknown[] = [
      recordClass.type,
      ctx.contextCorrelationId,
      ...tagSql.params,
    ];

    const { rows: countRows } = await this.pool.query<{ count: string }>(
      `SELECT COUNT(*)::text AS count FROM records WHERE ${where}`,
      baseParams,
    );
    const total = Number.parseInt(countRows[0]?.count ?? "0", 10);

    let selectParams = baseParams;
    let limitClause = "";
    if (pagination) {
      const limitIdx = baseParams.length + 1;
      const offsetIdx = baseParams.length + 2;
      const offset = (pagination.page - 1) * pagination.limit;
      limitClause = ` LIMIT $${limitIdx} OFFSET $${offsetIdx}`;
      selectParams = [...baseParams, pagination.limit, offset];
    }

    const { rows } = await this.pool.query<{ data: string }>(
      `SELECT data FROM records WHERE ${where}
       ORDER BY (data::jsonb->>'createdAt') DESC NULLS LAST, id ASC${limitClause}`,
      selectParams,
    );

    const items = rows.map((row) => JSON.parse(row.data) as StoredRecord);
    return { items, total };
  }

  private applyOutOfBandRecipientDedup(
    recordClass: BaseRecordConstructor<unknown>,
    query: RecordQuery,
    items: StoredRecord[],
  ): StoredRecord[] {
    const isOobRecipientQuery =
      recordClass.type === "OutOfBandRecord" &&
      Array.isArray(query.$or) &&
      query.$or.some(
        (s) =>
          s?.recipientKeyFingerprints != null ||
          s?.recipientRoutingKeyFingerprint != null,
      );

    if (!isOobRecipientQuery || items.length <= 1) return items;

    return items
      .sort(
        (a, b) => this.parseDate(b.createdAt) - this.parseDate(a.createdAt),
      )
      .slice(0, 1);
  }

  private parseDate(v: string | undefined): number {
    if (!v) return 0;
    const ms = Date.parse(v);
    return isNaN(ms) ? 0 : ms;
  }

  /**
   * Busca todos los records del tipo dado que satisfacen la query.
   *
   * Incluye lógica especial para `OutOfBandRecord` con queries de fingerprint:
   * cuando múltiples registros coinciden, retorna solo el más reciente para evitar
   * ambigüedad en el routing de mensajes DIDComm.
   *
   * @param recordClass - Constructor del record Credo-TS (determina el tipo en la DB)
   * @param query - Query con campos y valores; soporta `$or` y arrays
   */
  async findByQuery<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    query: RecordQuery,
  ): Promise<T[]> {
    const storedItems = await this.findAllByQueryUnpaginated(ctx, recordClass, query);
    return storedItems
      .map((stored) =>
        this.ensureRecordInstance(
          JsonTransformer.fromJSON(stored.data, recordClass, { validate: false }),
          recordClass,
        ),
      )
      .filter((r): r is T => r !== null);
  }

  private async findAllByQueryUnpaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    query: RecordQuery,
  ): Promise<StoredRecord[]> {
    const { items } = await this.selectStoredByTagQuery(ctx, recordClass, query);
    return this.applyOutOfBandRecipientDedup(recordClass, query, items);
  }

  /**
   * Busca records por tags con paginación en PostgreSQL.
   *
   * @param ctx - Contexto del tenant
   * @param recordClass - Clase Credo del record
   * @param query - Filtro por tags (formato Credo `findByQuery`)
   * @param options - Página y límite
   */
  async findByQueryPaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    query: RecordQuery,
    options: RecordsPageOptions,
  ): Promise<PaginatedRecords<T>> {
    const { items: pageStored, total } = await this.selectStoredByTagQuery(
      ctx,
      recordClass,
      query,
      options,
    );

    const items = pageStored
      .map((stored) =>
        this.ensureRecordInstance(
          JsonTransformer.fromJSON(stored.data, recordClass, { validate: false }),
          recordClass,
        ),
      )
      .filter((r): r is T => r !== null);

    return {
      items,
      pagination: buildRecordsPageMeta(total, options.page, options.limit),
    };
  }
}
