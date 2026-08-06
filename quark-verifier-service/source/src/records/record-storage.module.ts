import { Global, Module } from '@nestjs/common'
import { AskarRecordStorage, type RecordStorage } from '@quarkid/identity-core'
import { RECORD_STORAGE } from './record-storage.tokens'

/**
 * Adapter Credo de records del producto Quark: siempre {@link AskarRecordStorage}.
 *
 * Es el wiring del port `RecordStorage` que consume `createRoot*Agent`, distinto
 * de `RecordsModule` (API HTTP de consulta) que vive en esta misma carpeta.
 * Requiere `askarStore` en el agente (ver `askar/`); no posee el pool SQL.
 */
@Global()
@Module({
  providers: [
    {
      provide: RECORD_STORAGE,
      useFactory: (): RecordStorage => new AskarRecordStorage(),
    },
  ],
  exports: [RECORD_STORAGE],
})
export class RecordStorageModule {}
