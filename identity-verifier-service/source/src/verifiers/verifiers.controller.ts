import { Body, Controller, Get, Post } from '@nestjs/common'
import { CreateVerifierDto } from './dto/create-verifier.dto'
import { VerifiersService } from './verifiers.service'

/**
 * Alta de verifiers en `GET|POST /v1/verifiers` (gateway :3000 o directo :9002).
 *
 * Prefijo global `v1` → `GET|POST /v1/verifiers`. Metadata OID4VP en `RecordsController`.
 *
 * Records Credo que materializa el POST (ver {@link VerifiersService.create}):
 * - Tenant (Credo Tenants)
 * - `DidRecord`, `StorageVersionRecord`
 * - `OpenId4VcVerifierRecord` si el body incluye `oid4vp`
 */
@Controller('verifiers')
export class VerifiersController {
  constructor(private readonly verifiersService: VerifiersService) {}

  /**
   * Lista verifiers disponibles para pruebas.
   *
   * Ruta HTTP: `GET /verifiers`
   */
  @Get()
  list() {
    return this.verifiersService.list()
  }

  /**
   * Da de alta un verifier (tenant + DID web + metadata OID4VP opcional).
   *
   * Ruta HTTP: `POST /verifiers`
   *
   * @param body - `verifierId` y opcionalmente `oid4vp` (`clientMetadata` inicial)
   * @returns `verifierId`, `tenantId`, `did`, `recordsCreated`
   * @throws {ConflictException} Si el `verifierId` ya está registrado
   */
  @Post()
  create(@Body() body: CreateVerifierDto) {
    return this.verifiersService.create(body)
  }
}
