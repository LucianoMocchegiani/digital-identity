// # KMS
// Wiring Nest del KMS del agente: Askar primario + `BbsKeyManagementService` (Postgres).
// Depende de `AskarStoreModule` (vía `askarStore` en bootstrap) y de `DatabaseModule` (pool para BBS).

import { Global, Module } from '@nestjs/common'
import { Pool } from 'pg'
import {
  AskarKeyManagementService,
  BbsKeyManagementService,
  type KeyManagementService,
} from '@quarkid/identity-core'
import { DATABASE_POOL } from '../database/database.tokens'
import {
  ADDITIONAL_KEY_MANAGEMENT_SERVICES,
  KEY_MANAGEMENT_SERVICE,
} from './key-management.tokens'

/**
 * Composición KMS del holder: Askar primario + sidecar {@link BbsKeyManagementService}.
 *
 * Askar KMS requiere que el agente haya recibido `askarStore` ({@link AskarStoreModule}).
 * El sidecar BBS usa {@link DATABASE_POOL}, no el store Askar.
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
        new BbsKeyManagementService(pool),
      ],
    },
  ],
  exports: [KEY_MANAGEMENT_SERVICE, ADDITIONAL_KEY_MANAGEMENT_SERVICES],
})
export class KeyManagementModule {}
