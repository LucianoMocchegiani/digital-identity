import type { RecordStorage } from './record-storage.interface'

/**
 * Comprueba si un objeto expone el port {@link RecordStorage} de Quark.
 */
export function isRecordStorage(storage: unknown): storage is RecordStorage {
  if (typeof storage !== 'object' || storage === null) return false
  const candidate = storage as RecordStorage
  return (
    typeof candidate.getById === 'function' &&
    typeof candidate.getAllPaginated === 'function' &&
    typeof candidate.findByQueryPaginated === 'function'
  )
}
