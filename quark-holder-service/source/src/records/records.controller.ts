import { Controller, Get, Param, Query } from '@nestjs/common'
import { ListRecordsQueryDto } from './list-records-query.dto'
import { RecordsService } from './records.service'

/**
 * Expone consulta de solo lectura sobre records Credo del tenant holder.
 *
 * Admin: `GET /v1/holders/:walletId/records/*` (gateway o directo :9005).
 */
@Controller('holders/:walletId/records')
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  /**
   * Lista tipos de record del holder con descripción (`GET /:walletId/records/types`).
   *
   * @returns `types[]` con `className`, `storageType`, `category`, `description`
   */
  @Get('types')
  listTypes() {
    return this.recordsService.getTypes()
  }

  /**
   * Lista records paginados del tenant filtrados por tipo Credo.
   *
   * Ruta HTTP: `GET /:walletId/records?type=...`
   *
   * @param walletId - ID lógico del holder (label del tenant)
   * @param query - `type` obligatorio; opcionales `query` (JSON), `page`, `limit`
   */
  @Get()
  list(@Param('walletId') walletId: string, @Query() query: ListRecordsQueryDto) {
    return this.recordsService.list(walletId, query.type, query.query, query.page, query.limit)
  }

  /**
   * Obtiene un record por tipo e ID.
   *
   * Ruta HTTP: `GET /:walletId/records/:recordType/:recordId`
   *
   * @param walletId - ID lógico del holder
   * @param recordType - Clase Credo o tipo en storage
   * @param recordId - ID del record
   */
  @Get(':recordType/:recordId')
  get(
    @Param('walletId') walletId: string,
    @Param('recordType') recordType: string,
    @Param('recordId') recordId: string,
  ) {
    return this.recordsService.get(walletId, recordType, recordId)
  }
}
