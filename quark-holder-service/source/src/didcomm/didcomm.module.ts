/** Módulo DIDComm del holder: receive-invitation (espejo del offer/request integrado). */
import { Module } from '@nestjs/common'
import { DidCommController } from './didcomm.controller'
import { DidCommService } from './didcomm.service'

@Module({
  controllers: [DidCommController],
  providers: [DidCommService],
  exports: [DidCommService],
})
export class DidCommModule {}
