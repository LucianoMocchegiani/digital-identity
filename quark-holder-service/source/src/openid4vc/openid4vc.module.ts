import { Module } from '@nestjs/common'

import { OpenId4VcController } from './openid4vc.controller'
import { OpenId4VcService } from './openid4vc.service'

/** Módulo OID4VCI/OID4VP del holder para soporte de EUDI Wallet. */
@Module({
  controllers: [OpenId4VcController],
  providers: [OpenId4VcService],
})
export class OpenId4VcModule {}
