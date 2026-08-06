import { Global, Inject, Module, OnModuleDestroy } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { Pool } from 'pg'
import { DATABASE_POOL } from './database.tokens'

/**
 * Pool Postgres compartido del servicio (`DATABASE_URL`).
 *
 * Infra SQL reutilizada por KMS/BBS y StatusList. El store Askar abre su propia
 * conexión vía `askarStore.databaseUrl`.
 */
@Global()
@Module({
  providers: [
    {
      provide: DATABASE_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService): Pool => {
        const databaseUrl = config.get<string>('databaseUrl')
        if (!databaseUrl) {
          throw new Error('DATABASE_URL es obligatorio')
        }
        return new Pool({ connectionString: databaseUrl })
      },
    },
  ],
  exports: [DATABASE_POOL],
})
export class DatabaseModule implements OnModuleDestroy {
  constructor(@Inject(DATABASE_POOL) private readonly pool: Pool) {}

  async onModuleDestroy(): Promise<void> {
    await this.pool.end()
  }
}
