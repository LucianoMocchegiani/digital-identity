import { Global, Module } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
/**
 * Importar `askar` desde identity-core (no desde askar-nodejs directo) para
 * registrar el nativo sobre la misma instancia de `askar-shared` que Credo,
 * y antes de que Nest cargue `AskarKeyManagementService` (binding ESM).
 */
import { askar, type QuarkAskarStoreOptions } from '@identity/core'
import { ASKAR_STORE_OPTIONS } from './askar-store.tokens'

/**
 * Construye la config del store Askar desde envs Nest.
 *
 * Prerequisito de {@link AskarKeyManagementService}, {@link AskarRecordStorage}
 * y {@link AskarDomainKeyManagementService}.
 *
 * @throws Si faltan `ASKAR_STORE_KEY` o `DATABASE_URL`, o no se puede derivar el id
 */
export function resolveAskarStoreOptions(
  config: ConfigService,
): QuarkAskarStoreOptions {
  const key = config.get<string>('askarStoreKey')
  const databaseUrl = config.get<string>('databaseUrl')
  if (!key || !databaseUrl) {
    throw new Error(
      'Composición Askar requiere ASKAR_STORE_KEY y DATABASE_URL',
    )
  }

  const id =
    config.get<string>('askarStoreId') ||
    (() => {
      try {
        return new URL(databaseUrl).pathname.replace(/^\//, '').split('/')[0]
      } catch {
        return ''
      }
    })()

  if (!id) {
    throw new Error(
      'ASKAR_STORE_ID es obligatorio (o debe venir en el path de DATABASE_URL)',
    )
  }

  return { askar, id, key, databaseUrl }
}

/**
 * Provee `ASKAR_STORE_OPTIONS` (bóveda cifrada Askar sobre Postgres).
 */
@Global()
@Module({
  providers: [
    {
      provide: ASKAR_STORE_OPTIONS,
      inject: [ConfigService],
      useFactory: (config: ConfigService): QuarkAskarStoreOptions =>
        resolveAskarStoreOptions(config),
    },
  ],
  exports: [ASKAR_STORE_OPTIONS],
})
export class AskarStoreModule {}
