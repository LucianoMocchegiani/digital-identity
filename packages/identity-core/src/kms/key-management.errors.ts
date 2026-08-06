/**
 * Errores de bootstrap / capacidad del port {@link KeyManagementService}.
 */

/**
 * Bootstrap sin {@link KeyManagementService} inyectado desde Nest.
 */
export class KeyManagementBootstrapError extends Error {
  readonly code = 'KEY_MANAGEMENT_INJECTION_REQUIRED'

  constructor(message: string) {
    super(message)
    this.name = 'KeyManagementBootstrapError'
  }
}
