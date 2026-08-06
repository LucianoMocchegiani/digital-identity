/** Módulo DIDComm del issuer: offer integrado + short URL OOB. */
import { Module } from '@nestjs/common'
import { DidCommController } from './didcomm.controller'
import { DidCommService } from './didcomm.service'
import { OobShortUrlController } from './oob-short-url.controller'
import { PendingDidCommOfferStore } from './pending-didcomm-offer.store'

@Module({
  controllers: [OobShortUrlController, DidCommController],
  providers: [DidCommService, PendingDidCommOfferStore],
  exports: [DidCommService],
})
export class DidCommModule {}
