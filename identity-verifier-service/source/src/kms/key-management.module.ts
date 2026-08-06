import { Global, Module } from '@nestjs/common'
import { Pool } from 'pg'
import {
  AskarDomainKeyManagementService,
  AskarKeyManagementService,
  BbsKeyManagementService,
  type KeyManagementService,
} from '@identity/core'
import { DATABASE_POOL } from '../database/database.tokens'
import {
  ADDITIONAL_KEY_MANAGEMENT_SERVICES,
  KEY_MANAGEMENT_SERVICE,
} from './key-management.tokens'

/**
 * Composición KMS del verifier: Askar primario + domain-key + sidecar BBS.
 *
 * Orden Credo: Askar → domain-key (x5c) → BBS. Domain-key y Askar primario
 * requieren `askarStore`; BBS usa {@link DATABASE_POOL}.
 */
@Global()
@Module({
  providers: [
    {
      provide: KEY_MANAGEMENT_SERVICE,
      useFactory: (): KeyManagementService => new AskarKeyManagementService(),
    },
    {
      provide: ADDITIONAL_KEY_MANAGEMENT_SERVICES,
      inject: [DATABASE_POOL],
      useFactory: (pool: Pool): KeyManagementService[] => [
        new AskarDomainKeyManagementService(),
        new BbsKeyManagementService(pool),
      ],
    },
  ],
  exports: [KEY_MANAGEMENT_SERVICE, ADDITIONAL_KEY_MANAGEMENT_SERVICES],
})
export class KeyManagementModule {}
