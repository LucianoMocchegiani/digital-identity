import { Type } from 'class-transformer'
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator'
import { MAX_RECORDS_PAGE_SIZE } from '@identity/core'

/**
 * Query params de `GET /:walletId/records`.
 *
 * Valida y transforma parámetros de listado paginado de records Credo.
 */
export class ListRecordsQueryDto {
  /**
   * Tipo de record: nombre de clase (`DidCommConnectionRecord`) o tipo en storage (`ConnectionRecord`).
   */
  @IsString()
  type!: string

  /**
   * Filtro JSON por tags, mismo formato que Credo `findByQuery`.
   * Ejemplo: `{"state":"completed"}`.
   */
  @IsOptional()
  @IsString()
  query?: string

  /** Página 1-based. Por defecto `1`. */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number

  /**
   * Cantidad de records por página.
   * Por defecto `20`; máximo {@link MAX_RECORDS_PAGE_SIZE} (`100`).
   */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_RECORDS_PAGE_SIZE)
  limit?: number
}
