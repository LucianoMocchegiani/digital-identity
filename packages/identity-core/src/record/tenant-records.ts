import {
  DidRecord,
  JsonTransformer,
  SdJwtVcRecord,
  StorageVersionRecord,
  W3cCredentialRecord,
  W3cV2CredentialRecord,
  type Agent,
  type BaseRecordConstructor,
} from '@credo-ts/core'
import type { QuarkWalletRecord } from './quark-wallet-record.types'
import { normalizeRecordsPageOptions, type RecordsPageMeta, type RecordsPageOptions } from './record-storage.types'
import { resolveRecordStorage } from './record-storage.resolve'

export {
  DEFAULT_RECORDS_PAGE_SIZE,
  MAX_RECORDS_PAGE_SIZE,
  buildRecordsPageMeta,
  normalizeRecordsPageOptions,
} from './record-storage.types'
export type { RecordsPageMeta, RecordsPageOptions } from './record-storage.types'
export {
  getRecordTypeDescriptors,
  findRecordTypeDescriptor,
  type QuarkAgentRole,
  type RecordTypeDescriptor,
  type RecordTypeCategory,
} from './record-type-catalog'

/**
 * Consulta de solo lectura de records Credo por tenant y rol de agente.
 *
 * Expone listado paginado y obtención por ID sobre el port {@link RecordStorage}.
 * Los tipos permitidos dependen del rol (`issuer`, `holder`, `verifier`) y se resuelven
 * por nombre de clase o por `type` en storage (ej. `ConnectionRecord`).
 * Ver catálogo documentado en `record-type-catalog.ts` y `README.md` de este directorio.
 *
 * @module record/tenant-records
 */
import {
  DidCommConnectionRecord,
  DidCommCredentialExchangeRecord,
  DidCommOutOfBandRecord,
  DidCommProofExchangeRecord,
} from '@credo-ts/didcomm'
import {
  OpenId4VcIssuanceSessionRecord,
  OpenId4VcIssuerRecord,
  OpenId4VcVerificationSessionRecord,
  OpenId4VcVerifierRecord,
} from '@credo-ts/openid4vc'

/** Constructor de un record persistido en Quark (instancia ∈ {@link QuarkWalletRecord}). */
export type QuarkRecordClass = BaseRecordConstructor<QuarkWalletRecord>

import type { QuarkAgentRole, RecordTypeDescriptor } from './record-type-catalog'
import { getRecordTypeDescriptors } from './record-type-catalog'

const COMMON_RECORDS: QuarkRecordClass[] = [StorageVersionRecord, DidRecord]

const ISSUER_RECORDS: QuarkRecordClass[] = [
  ...COMMON_RECORDS,
  DidCommConnectionRecord,
  DidCommCredentialExchangeRecord,
  DidCommOutOfBandRecord,
  OpenId4VcIssuerRecord,
  OpenId4VcIssuanceSessionRecord,
]

const HOLDER_RECORDS: QuarkRecordClass[] = [
  ...COMMON_RECORDS,
  SdJwtVcRecord,
  W3cCredentialRecord,
  W3cV2CredentialRecord,
  DidCommConnectionRecord,
  DidCommCredentialExchangeRecord,
  DidCommProofExchangeRecord,
  DidCommOutOfBandRecord,
]

const VERIFIER_RECORDS: QuarkRecordClass[] = [
  ...COMMON_RECORDS,
  DidCommConnectionRecord,
  DidCommProofExchangeRecord,
  DidCommOutOfBandRecord,
  OpenId4VcVerifierRecord,
  OpenId4VcVerificationSessionRecord,
]

const RECORDS_BY_ROLE: Record<QuarkAgentRole, QuarkRecordClass[]> = {
  issuer: ISSUER_RECORDS,
  holder: HOLDER_RECORDS,
  verifier: VERIFIER_RECORDS,
}

function buildRegistry(classes: QuarkRecordClass[]): Map<string, QuarkRecordClass> {
  const map = new Map<string, QuarkRecordClass>()
  for (const recordClass of classes) {
    map.set(recordClass.name, recordClass)
    const storageType = recordClass.type
    if (typeof storageType === 'string') {
      map.set(storageType, recordClass)
    }
  }
  return map
}

const REGISTRIES: Record<QuarkAgentRole, Map<string, QuarkRecordClass>> = {
  issuer: buildRegistry(ISSUER_RECORDS),
  holder: buildRegistry(HOLDER_RECORDS),
  verifier: buildRegistry(VERIFIER_RECORDS),
}

/**
 * Indica que el tipo de record solicitado no está en el registro del rol.
 *
 * @throws {UnknownRecordTypeError} Desde {@link listTenantRecords} y {@link getTenantRecord}
 */
export class UnknownRecordTypeError extends Error {
  /**
   * @param recordType - Valor recibido en la API (clase o tipo en storage)
   * @param role - Rol del agente que rechazó el tipo
   * @param allowed - Tipos válidos para ese rol
   */
  constructor(
    readonly recordType: string,
    readonly role: QuarkAgentRole,
    readonly allowed: RecordTypeDescriptor[],
  ) {
    const names = allowed.map((d) => `${d.className} (${d.storageType})`).join(', ')
    super(`Tipo de record desconocido '${recordType}' para rol '${role}'. Permitidos: ${names}`)
    this.name = 'UnknownRecordTypeError'
  }
}

function resolveRecordClass(role: QuarkAgentRole, recordType: string): QuarkRecordClass {
  const recordClass = REGISTRIES[role].get(recordType)
  if (!recordClass) {
    throw new UnknownRecordTypeError(recordType, role, getRecordTypeDescriptors(role))
  }
  return recordClass
}

function serializeRecord(record: QuarkWalletRecord): Record<string, unknown> {
  return JsonTransformer.toJSON(record) as Record<string, unknown>
}


/** Opciones para listar records de un tenant. */
export type ListTenantRecordsOptions = {
  /** Filtro por tags Credo (`findByQuery`); objeto vacío u omitido lista sin filtrar. */
  query?: Record<string, unknown>
  /** Página 1-based; se normaliza con {@link normalizeRecordsPageOptions}. */
  page?: number
  /** Tamaño de página; máximo {@link MAX_RECORDS_PAGE_SIZE}. */
  limit?: number
}

/** Respuesta paginada de {@link listTenantRecords}. */
export type ListTenantRecordsResult = {
  /** Tipo en storage del record listado (ej. `ConnectionRecord`). */
  type: string
  /** Metadatos de paginación (`page`, `total`, `hasNextPage`, etc.). */
  pagination: RecordsPageMeta
  /** Records serializados con `JsonTransformer.toJSON`. */
  records: Record<string, unknown>[]
}

/** Resultado de {@link getTenantRecord} cuando el record existe. */
export type TenantRecordResult = {
  type: string
  id: string
  record: Record<string, unknown>
}

/**
 * Lista records del tenant para el tipo indicado con paginación.
 *
 * @param agent - Agente del tenant (contexto aislado vía `withTenant`)
 * @param role - Rol del servicio que invoca la consulta
 * @param recordType - Nombre de clase (`DidCommConnectionRecord`) o tipo en storage (`ConnectionRecord`)
 * @param options - Filtro por tags y paginación (`page` 1-based, `limit` máx. 100)
 * @returns Listado paginado; sin `query` pagina en SQL, con `query` pagina en memoria tras filtrar
 * @throws {UnknownRecordTypeError} Si `recordType` no está permitido para el rol
 */
export async function listTenantRecords(
  agent: Agent,
  role: QuarkAgentRole,
  recordType: string,
  options: ListTenantRecordsOptions = {},
): Promise<ListTenantRecordsResult> {
  const recordClass = resolveRecordClass(role, recordType)
  const storage = resolveRecordStorage(agent)
  const ctx = agent.context
  const tagQuery = options.query ?? {}
  const pageOptions: RecordsPageOptions = normalizeRecordsPageOptions(options.page, options.limit)

  const hasQuery = Object.keys(tagQuery).length > 0
  const paginated = hasQuery
    ? await storage.findByQueryPaginated(ctx, recordClass, tagQuery, pageOptions)
    : await storage.getAllPaginated(ctx, recordClass, pageOptions)

  return {
    type: recordClass.type,
    pagination: paginated.pagination,
    records: paginated.items.map(serializeRecord),
  }
}

/**
 * Obtiene un record del tenant por tipo e ID.
 *
 * @param agent - Agente del tenant
 * @param role - Rol del servicio
 * @param recordType - Nombre de clase o tipo en storage
 * @param recordId - ID del record
 * @returns Record serializado o `null` si no existe en el tenant
 * @throws {UnknownRecordTypeError} Si `recordType` no está permitido para el rol
 */
export async function getTenantRecord(
  agent: Agent,
  role: QuarkAgentRole,
  recordType: string,
  recordId: string,
): Promise<TenantRecordResult | null> {
  const recordClass = resolveRecordClass(role, recordType)
  const storage = resolveRecordStorage(agent)
  const ctx = agent.context

  const record = await storage.getById(ctx, recordClass, recordId)
  if (!record) return null

  return {
    type: recordClass.type,
    id: recordId,
    record: serializeRecord(record),
  }
}
