import { Body, Controller, Get, Post } from '@nestjs/common'
import { CreateIssuerDto } from './dto/create-issuer.dto'
import { IssuersService } from './issuers.service'

/**
 * Alta y listado de issuers bajo `/v1/issuers` (gateway :3000 o directo :9001).
 *
 * Metadata OID4VCI y consulta de records viven en `RecordsController` (`/v1/issuers/:id/records/*`).
 *
 * Records Credo que materializa el POST (ver {@link IssuersService.create}):
 * - Tenant (Credo Tenants, fuera de `GET /records`)
 * - `DidRecord`, `StorageVersionRecord`
 * - `OpenId4VcIssuerRecord` si el body incluye `oid4vc`
 */
@Controller('issuers')
export class IssuersController {
  constructor(private readonly issuersService: IssuersService) {}

  /**
   * Lista issuers disponibles para pruebas en este proceso.
   *
   * Ruta HTTP: `GET /v1/issuers`
   */
  @Get()
  list() {
    return this.issuersService.list()
  }

  /**
   * Da de alta un issuer (tenant multi-tenant + DID web + metadata OID4VCI opcional).
   *
   * Ruta HTTP: `POST /v1/issuers`
   */
  @Post()
  create(@Body() body: CreateIssuerDto) {
    return this.issuersService.create(body)
  }
}
