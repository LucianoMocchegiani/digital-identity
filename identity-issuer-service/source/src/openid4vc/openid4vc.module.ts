import { Module } from '@nestjs/common'

import { OpenId4VcController } from './openid4vc.controller'
import { OpenId4VcService } from './openid4vc.service'
import { RevocationIssuerModule } from '../revocation/revocation.module'

/** Módulo OID4VCI del issuer para soporte de EUDI Wallet. */
@Module({
  controllers: [OpenId4VcController],
  providers: [OpenId4VcService],
  imports: [RevocationIssuerModule],
})
export class OpenId4VcModule {}
