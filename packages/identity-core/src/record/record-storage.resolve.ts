import { InjectionSymbols, type Agent } from '@credo-ts/core'

import type { RecordStorage } from './record-storage.interface'
import { RecordStorageCapabilityError } from './record-storage.errors'
import { isRecordStorage } from './record-storage.guards'

export { isRecordStorage } from './record-storage.guards'

/**
 * Resuelve el storage del agente como {@link RecordStorage}.
 *
 * @throws {RecordStorageCapabilityError} Si el backend no implementa paginación (p. ej. `external` legacy)
 */
export function resolveRecordStorage(agent: Agent): RecordStorage {
  const storage = agent.dependencyManager.resolve(InjectionSymbols.StorageService)
  if (!isRecordStorage(storage)) {
    throw new RecordStorageCapabilityError(
      'El storage del agente no implementa RecordStorage (getAllPaginated / findByQueryPaginated). ' +
        'Usá un adapter Postgres o inyectá recordStorage en el bootstrap del agente.',
    )
  }
  return storage
}
