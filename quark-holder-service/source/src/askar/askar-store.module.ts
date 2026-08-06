// # Askar store
// Config Nest de la bóveda Askar (`ASKAR_STORE_OPTIONS`: id, key, `DATABASE_URL`, binding nativo).
// No es el KMS ni el adapter de records. Es lo que `main` pasa como `askarStore` al crear el agente root; Credo abre el store cifrado y luego `AskarKeyManagementService` / `AskarRecordStorage` operan sobre él.

import { Global, Module } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
/**
 * Importar `askar` desde identity-core (no desde askar-nodejs directo) para
 * registrar el nativo sobre la misma instancia de `askar-shared` que Credo,
 * y antes de que Nest cargue `AskarKeyManagementService` (binding ESM).
 */
import { askar, type QuarkAskarStoreOptions } from '@quarkid/identity-core'
import { ASKAR_STORE_OPTIONS } from './askar-store.tokens'

/**
 * Construye la config del store Askar desde envs Nest.
 *
 * Es el prerequisito compartido de {@link AskarKeyManagementService} y
 * {@link AskarRecordStorage}: ambos hablan con Credo/`AskarStoreManager` solo
 * después de que el agente registre este store (`askarStore` en createRoot*Agent).
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
 *
 * No instancia KMS ni records: solo la config que identity-core usa para montar
 * el `AskarModule` store-only y provisionar el store.
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
