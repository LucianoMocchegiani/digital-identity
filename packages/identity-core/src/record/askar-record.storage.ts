import '../askar-native'
import type {
  AgentContext,
  BaseRecord,
  BaseRecordConstructor,
  Query,
} from '@credo-ts/core'
import { RecordNotFoundError } from '@credo-ts/core'
import { AskarStorageService, AskarStoreManager } from '@credo-ts/askar'

import type { RecordStorage } from './record-storage.interface'
import {
  buildRecordsPageMeta,
  type PaginatedRecords,
  type RecordTagQuery,
  type RecordsPageOptions,
} from './record-storage.types'

/**
 * Adapter Askar para {@link RecordStorage}.
 *
 * Delega en {@link AskarStorageService} resolviendo {@link AskarStoreManager}
 * desde el `AgentContext` (Nest instancia este adapter antes de que exista el agente).
 * La paginación Quark se aplica en memoria.
 */
export class AskarRecordStorage implements RecordStorage {
  /**
   * Resuelve el storage Credo Askar ligado al store del contexto actual.
   */
  private askar(ctx: AgentContext): AskarStorageService<BaseRecord> {
    const storeManager = ctx.dependencyManager.resolve(AskarStoreManager)
    return new AskarStorageService(storeManager)
  }

  async save(ctx: AgentContext, record: BaseRecord): Promise<void> {
    await this.askar(ctx).save(ctx, record)
  }

  async update(ctx: AgentContext, record: BaseRecord): Promise<void> {
    await this.askar(ctx).update(ctx, record)
  }

  async delete(ctx: AgentContext, record: BaseRecord): Promise<void> {
    await this.askar(ctx).delete(ctx, record)
  }

  async deleteById<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    id: string,
  ): Promise<void> {
    await this.askar(ctx).deleteById(
      ctx,
      recordClass as BaseRecordConstructor<BaseRecord>,
      id,
    )
  }

  async getById<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    id: string,
  ): Promise<T | null> {
    try {
      const record = await this.askar(ctx).getById(
        ctx,
        recordClass as BaseRecordConstructor<BaseRecord>,
        id,
      )
      return record as T
    } catch (error) {
      if (error instanceof RecordNotFoundError) {
        return null
      }
      throw error
    }
  }

  /**
   * Lista sin paginar (contrato Credo `StorageService`).
   */
  async getAll<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
  ): Promise<T[]> {
    const records = await this.askar(ctx).getAll(
      ctx,
      recordClass as BaseRecordConstructor<BaseRecord>,
    )
    return records as T[]
  }

  async getAllPaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    options: RecordsPageOptions,
  ): Promise<PaginatedRecords<T>> {
    const all = await this.getAll(ctx, recordClass)
    const offset = (options.page - 1) * options.limit
    const items = all.slice(offset, offset + options.limit)
    return {
      items,
      pagination: buildRecordsPageMeta(all.length, options.page, options.limit),
    }
  }

  /**
   * Busca por tags (contrato Credo `StorageService`).
   *
   * Aplica dedup de `OutOfBandRecord` por fingerprint (mismo criterio que Postgres).
   */
  async findByQuery<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    query: RecordTagQuery,
  ): Promise<T[]> {
    const items = (await this.askar(ctx).findByQuery(
      ctx,
      recordClass as BaseRecordConstructor<BaseRecord>,
      query as Query<BaseRecord>,
    )) as T[]
    return this.applyOutOfBandRecipientDedup(recordClass, query, items)
  }

  async findByQueryPaginated<T>(
    ctx: AgentContext,
    recordClass: BaseRecordConstructor<T>,
    query: RecordTagQuery,
    options: RecordsPageOptions,
  ): Promise<PaginatedRecords<T>> {
    const all = await this.findByQuery(ctx, recordClass, query)
    const offset = (options.page - 1) * options.limit
    const items = all.slice(offset, offset + options.limit)
    return {
      items,
      pagination: buildRecordsPageMeta(all.length, options.page, options.limit),
    }
  }

  private applyOutOfBandRecipientDedup<T>(
    recordClass: BaseRecordConstructor<T>,
    query: RecordTagQuery,
    items: T[],
  ): T[] {
    const isOobRecipientQuery =
      recordClass.type === 'OutOfBandRecord' &&
      Array.isArray(query.$or) &&
      query.$or.some(
        (clause) =>
          clause?.recipientKeyFingerprints != null ||
          clause?.recipientRoutingKeyFingerprint != null,
      )

    if (!isOobRecipientQuery || items.length <= 1) {
      return items
    }

    return [...items]
      .sort((a, b) => {
        const left = a as { createdAt?: Date | string }
        const right = b as { createdAt?: Date | string }
        return this.parseDate(right.createdAt) - this.parseDate(left.createdAt)
      })
      .slice(0, 1)
  }

  private parseDate(value: Date | string | undefined): number {
    if (!value) return 0
    if (value instanceof Date) return value.getTime()
    const ms = Date.parse(value)
    return Number.isNaN(ms) ? 0 : ms
  }
}
