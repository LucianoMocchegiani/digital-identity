import { Body, Controller, Param, Post } from '@nestjs/common'
import { ReceiveInvitationDto } from './didcomm-receive-invitation.dto'
import { DidCommService } from './didcomm.service'

@Controller('holders/:walletId/didcomm')
export class DidCommController {
  constructor(private readonly didCommService: DidCommService) {}

  /**
   * Recibe invitación OOB del issuer/verifier (análogo a escanear QR en wallet).
   *
   * Tras aceptar, Credo + listeners de identity-core completan conexión,
   * offer/credential o request/presentation sin pasos HTTP adicionales.
   *
   * @param walletId - ID de la wallet del holder
   * @param body - `{ invitationUrl }` (short URL `/oob/:id` o OOB con `oob=`)
   * @returns `{ ok, outOfBandRecordId }`
   */
  @Post('receive-invitation')
  async receive(
    @Param('walletId') walletId: string,
    @Body() body: ReceiveInvitationDto,
  ) {
    const outOfBandRecord = await this.didCommService.receiveInvitation(
      walletId,
      body.invitationUrl,
    )
    return {
      ok: true,
      outOfBandRecordId: (outOfBandRecord as { id?: string })?.id ?? null,
    }
  }
}
