import { Global, Module } from '@nestjs/common'
import { Pool } from 'pg'
import {
  PostgresStatusListStorage,
  type StatusListStorage,
} from '@identity/core'
import { DATABASE_POOL } from '../database/database.tokens'
import { STATUS_LIST_STORAGE } from './status-list-storage.tokens'

/**
 * Persistencia SQL de Token Status List ({@link StatusListStorage}).
 *
 * Vive en `revocation/` porque es dominio de revocación; el pool lo aporta
 * {@link DatabaseModule}.
 */
@Global()
@Module({
  providers: [
    {
      provide: STATUS_LIST_STORAGE,
      inject: [DATABASE_POOL],
      useFactory: (pool: Pool): StatusListStorage =>
        new PostgresStatusListStorage(pool),
    },
  ],
  exports: [STATUS_LIST_STORAGE],
})
export class StatusListStorageModule {}
