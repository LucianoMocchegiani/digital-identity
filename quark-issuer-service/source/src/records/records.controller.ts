import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common'
import { PatchIssuerMetadataDto } from './dto/patch-issuer-metadata.dto'
import { ListRecordsQueryDto } from './list-records-query.dto'
import { RecordsService } from './records.service'

/**
 * Consulta y actualización de records Credo del tenant issuer.
 *
 * Admin: `GET|PATCH /v1/issuers/:walletId/records/*` (gateway o directo :9001).
 */
@Controller('issuers/:walletId/records')
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  /**
   * Lista los tipos de record consultables para el rol issuer con descripción funcional.
   *
   * Ruta HTTP: `GET /v1/issuers/:walletId/records/types`
   *
   * @returns `role` y `types[]` con `className`, `storageType`, `category`, `description`
   * (catálogo en `@quarkid/identity-core` → `record-type-catalog.ts`)
   */
  @Get('types')
  listTypes() {
    return this.recordsService.getTypes()
  }

  /**
   * Lista records paginados del tenant filtrados por tipo Credo.
   *
   * Ruta HTTP: `GET /v1/issuers/:walletId/records?type=ConnectionRecord&page=1&limit=20`
   *
   * @param walletId - ID lógico del issuer (label del tenant en Credo)
   * @param query - `type` obligatorio; opcionales `query` (JSON por tags), `page`, `limit`
   */
  @Get()
  list(@Param('walletId') walletId: string, @Query() query: ListRecordsQueryDto) {
    return this.recordsService.list(walletId, query.type, query.query, query.page, query.limit)
  }

  /**
   * Fusiona metadata OID4VCI en el `OpenId4VcIssuerRecord` del tenant.
   *
   * Ruta HTTP: `PATCH /v1/issuers/:walletId/records/metadata`
   */
  @Patch('metadata')
  patchMetadata(@Param('walletId') walletId: string, @Body() body: PatchIssuerMetadataDto) {
    return this.recordsService.patchMetadata(walletId, body)
  }

  /**
   * Obtiene un record por tipo e ID dentro del storage del tenant.
   *
   * Ruta HTTP: `GET /v1/issuers/:walletId/records/:recordType/:recordId`
   *
   * @param walletId - ID lógico del issuer
   * @param recordType - Nombre de clase (`DidCommConnectionRecord`) o tipo en storage (`ConnectionRecord`)
   * @param recordId - UUID del record en Credo
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
