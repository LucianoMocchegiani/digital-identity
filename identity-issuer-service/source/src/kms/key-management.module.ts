import { Global, Module } from '@nestjs/common'
import {
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
 * Composición KMS del issuer: Askar primario + sidecar {@link BbsKeyManagementService}.
 *
 * Askar KMS requiere `askarStore` ({@link AskarStoreModule}).
 * El sidecar BBS usa {@link DATABASE_POOL}.
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
      useFactory: (
        pool: ConstructorParameters<typeof BbsKeyManagementService>[0],
      ): KeyManagementService[] => [new BbsKeyManagementService(pool)],
    },
  ],
  exports: [KEY_MANAGEMENT_SERVICE, ADDITIONAL_KEY_MANAGEMENT_SERVICES],
})
export class KeyManagementModule {}
