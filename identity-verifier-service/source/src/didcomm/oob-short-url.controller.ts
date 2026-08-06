import {
  Controller,
  Get,
  Header,
  NotFoundException,
  Param,
} from '@nestjs/common'
import { DidCommService } from './didcomm.service'

/**
 * Short URL pública de invitaciones OOB (Aries RFC 0434 § URL Shortening).
 *
 * Fuera del prefijo `/v1`: `GET /oob/:invitationId` con `Accept: application/json`
 * devuelve el mensaje OOB. Vigencia = TTL del pending request (no burn-on-GET).
 */
@Controller('oob')
export class OobShortUrlController {
  constructor(private readonly didCommService: DidCommService) {}

  /**
   * Resuelve una short URL al mensaje Out-of-Band en JSON.
   *
   * @param invitationId - `pendingRequestId` del create request
   * @returns Mensaje OOB Credo
   * @throws {NotFoundException} Si el id no existe o el TTL expiró
   */
  @Get(':invitationId')
  @Header('Content-Type', 'application/json; charset=utf-8')
  getInvitation(@Param('invitationId') invitationId: string) {
    const invitation = this.didCommService.getShortInvitation(invitationId)
    if (!invitation) {
      throw new NotFoundException(
        `Invitación OOB '${invitationId}' no encontrada o expirada`,
      )
    }
    return invitation
  }
}
