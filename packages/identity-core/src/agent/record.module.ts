import { DependencyManager, InjectionSymbols } from '@credo-ts/core'
import { RecordStorageBootstrapError } from '../record/record-storage.errors'
import type { RecordStorage } from '../record/record-storage.interface'

/**
 * Registra el storage de records inyectado por el servicio Nest.
 */
export function registerRecordConfig(
  dependencyManager: DependencyManager,
  recordStorage: RecordStorage | undefined,
): void {
  if (!recordStorage) {
    throw new RecordStorageBootstrapError(
      'recordStorage es obligatorio: inyectar AskarRecordStorage o PostgresRecordStorage desde Nest.',
    )
  }

  dependencyManager.registerInstance(InjectionSymbols.StorageService, recordStorage)
}
