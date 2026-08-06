/** Módulo DIDComm del verifier: request integrado + short URL OOB. */
import { Module } from '@nestjs/common'
import { DidCommController } from './didcomm.controller'
import { DidCommService } from './didcomm.service'
import { OobShortUrlController } from './oob-short-url.controller'
import { PendingDidCommProofStore } from './pending-didcomm-proof.store'

@Module({
  controllers: [OobShortUrlController, DidCommController],
  providers: [DidCommService, PendingDidCommProofStore],
  exports: [DidCommService],
})
export class DidCommModule {}
