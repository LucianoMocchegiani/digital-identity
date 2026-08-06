import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common'
import { PatchVerifierMetadataDto } from './dto/patch-verifier-metadata.dto'
import { ListRecordsQueryDto } from './list-records-query.dto'
import { RecordsService } from './records.service'

/**
 * Consulta y actualización de records Credo del tenant verifier.
 *
 * Admin: `GET|PATCH /v1/verifiers/:walletId/records/*` (gateway o directo :9002).
 */
@Controller('verifiers/:walletId/records')
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  /**
   * Lista tipos de record del verifier con descripción (`GET /:walletId/records/types`).
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
   * @param walletId - ID lógico del verifier (label del tenant)
   * @param query - `type` obligatorio; opcionales `query` (JSON), `page`, `limit`
   */
  @Get()
  list(@Param('walletId') walletId: string, @Query() query: ListRecordsQueryDto) {
    return this.recordsService.list(walletId, query.type, query.query, query.page, query.limit)
  }

  /**
   * Fusiona metadata OID4VP en el `OpenId4VcVerifierRecord` del tenant.
   *
   * Ruta HTTP: `PATCH /v1/verifiers/:walletId/records/metadata`
   */
  @Patch('metadata')
  patchMetadata(@Param('walletId') walletId: string, @Body() body: PatchVerifierMetadataDto) {
    return this.recordsService.patchMetadata(walletId, body)
  }

  /**
   * Obtiene un record por tipo e ID.
   *
   * Ruta HTTP: `GET /:walletId/records/:recordType/:recordId`
   *
   * @param walletId - ID lógico del verifier
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
