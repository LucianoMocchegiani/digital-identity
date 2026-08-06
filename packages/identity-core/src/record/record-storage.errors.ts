/**
 * El storage registrado en el agente no implementa el port {@link RecordStorage}
 * (falta paginación u operaciones CRUD requeridas).
 */
export class RecordStorageCapabilityError extends Error {
  readonly code = 'RECORD_STORAGE_CAPABILITY_MISSING'

  constructor(message: string) {
    super(message)
    this.name = 'RecordStorageCapabilityError'
  }
}

/**
 * Bootstrap sin {@link RecordStorage} inyectado en modo `internal`.
 */
export class RecordStorageBootstrapError extends Error {
  readonly code = 'RECORD_STORAGE_INJECTION_REQUIRED'

  constructor(message: string) {
    super(message)
    this.name = 'RecordStorageBootstrapError'
  }
}
