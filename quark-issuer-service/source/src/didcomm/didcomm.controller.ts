import { Controller, Post, Body, Param } from '@nestjs/common'
import { DidCommService } from './didcomm.service'
import { CreateDidCommOfferDto } from './didcomm-offer.dto'

@Controller('issuers/:walletId/didcomm')
export class DidCommController {
  constructor(private readonly didCommService: DidCommService) {}

  /**
   * Crea invitación OOB + pending offer en un solo paso (análogo a OID4VCI offer).
   *
   * El `offer-credential` se envía automáticamente al completar o reusar la conexión.
   *
   * @param walletId - ID de la wallet del issuer
   * @param body - Claims de la credencial; sin `connectionId` ni `holderDid`
   * @returns `{ invitation }` short URL `/oob/:pendingOfferId`, `pendingOfferId`, `expiresAt`
   */
  @Post('offer')
  async createOffer(
    @Param('walletId') walletId: string,
    @Body() body: CreateDidCommOfferDto,
  ) {
    return this.didCommService.createOffer(walletId, body)
  }
}
