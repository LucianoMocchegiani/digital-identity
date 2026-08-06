import { Body, Controller, Get, Post } from '@nestjs/common'
import { CreateHolderDto } from './dto/create-holder.dto'
import { HoldersService } from './holders.service'

/**
 * Alta de holders en `GET|POST /v1/holders` (gateway :3000 o directo :9005). Mismo patrón que issuer y verifier.
 *
 * Prefijo global `v1` → `GET|POST /v1/holders`. El holder no expone metadata OID4VCI/OID4VP;
 * el POST solo crea tenant + DID `did:key`.
 *
 * Records Credo materializados (ver {@link HoldersService.create}):
 * - Tenant (Credo Tenants)
 * - `DidRecord` (`did:key` Ed25519), `StorageVersionRecord`
 */
@Controller('holders')
export class HoldersController {
  constructor(private readonly holdersService: HoldersService) {}

  /**
   * Lista holders disponibles para pruebas.
   *
   * Ruta HTTP: `GET /holders`
   */
  @Get()
  list() {
    return this.holdersService.list()
  }

  /**
   * Da de alta un holder (tenant + DID key).
   *
   * Ruta HTTP: `POST /holders`
   *
   * @param body - `holderId` del nuevo tenant
   * @returns `holderId`, `tenantId`, `did`, `recordsCreated`
   * @throws {ConflictException} Si el `holderId` ya existe en el mapa del proceso
   */
  @Post()
  create(@Body() body: CreateHolderDto) {
    return this.holdersService.create(body)
  }
}
