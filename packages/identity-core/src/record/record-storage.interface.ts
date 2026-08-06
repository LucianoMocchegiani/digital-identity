import type { AgentContext, BaseRecord, BaseRecordConstructor } from '@credo-ts/core'

import type {
  PaginatedRecords,
  RecordTagQuery,
  RecordsPageOptions,
} from './record-storage.types'

/**
 * Port de persistencia de records Credo para QuarkID.
 *
 * Los servicios (issuer / verifier / holder) proveen una implementación concreta
 * (Postgres, Mongo, SQLite, etc.). `identity-core` usa solo este contrato en
 * `tenant-records` y APIs de consulta.
 *
 * Listados: solo métodos paginados. No forman parte del port `getAll` ni `findByQuery`
 * sin paginar (pueden existir en el adapter Credo para protocolo interno).
 */
export interface RecordStorage {
  save(ctx: AgentContext, record: BaseRecord): Promise<void>
  update(ctx: AgentContext, record: BaseRecord): Promise<void>
  delete(ctx: AgentContext, record: BaseRecord): Promise<void>
  deleteById<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    id: string,
  ): Promise<void>
  getById<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    id: string,
  ): Promise<T | null>
  getAllPaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    options: RecordsPageOptions,
  ): Promise<PaginatedRecords<T>>
  findByQueryPaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    query: RecordTagQuery,
    options: RecordsPageOptions,
  ): Promise<PaginatedRecords<T>>
}
