/** Tamaño de página por defecto al listar records. */
export const DEFAULT_RECORDS_PAGE_SIZE = 20

/** Límite máximo de registros por página en listados HTTP. */
export const MAX_RECORDS_PAGE_SIZE = 100

/** Parámetros de paginación normalizados (página 1-based). */
export type RecordsPageOptions = {
  page: number
  limit: number
}

/** Metadatos de paginación devueltos en listados de records. */
export type RecordsPageMeta = {
  page: number
  limit: number
  total: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
}

/** Resultado paginado de records Credo. */
export type PaginatedRecords<T> = {
  items: T[]
  pagination: RecordsPageMeta
}

/**
 * Filtro por tags Credo (`findByQuery`).
 * Soporta comparaciones escalares, arrays y cláusula `$or`.
 */
export type RecordTagQuery = {
  $or?: Array<Record<string, unknown>>
  [key: string]: unknown
}

/**
 * Normaliza `page` y `limit` de query params HTTP.
 */
export function normalizeRecordsPageOptions(
  page?: number,
  limit?: number,
): RecordsPageOptions {
  const safePage = Math.max(1, Math.floor(page ?? 1))
  const rawLimit = Math.floor(limit ?? DEFAULT_RECORDS_PAGE_SIZE)
  const safeLimit = Math.min(MAX_RECORDS_PAGE_SIZE, Math.max(1, rawLimit))
  return { page: safePage, limit: safeLimit }
}

/**
 * Calcula metadatos de paginación a partir del total de ítems.
 */
export function buildRecordsPageMeta(
  total: number,
  page: number,
  limit: number,
): RecordsPageMeta {
  const totalPages = total === 0 ? 0 : Math.ceil(total / limit)
  return {
    page,
    limit,
    total,
    totalPages,
    hasNextPage: totalPages > 0 && page < totalPages,
    hasPreviousPage: page > 1 && total > 0,
  }
}
