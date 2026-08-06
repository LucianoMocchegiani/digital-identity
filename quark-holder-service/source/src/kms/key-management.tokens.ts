/** Token Nest del port Quark `KeyManagementService` (primario Askar). */
export const KEY_MANAGEMENT_SERVICE = Symbol('KeyManagementService')

/**
 * Token Nest de backends KMS adicionales (sidecar BBS, …).
 * Array de `KeyManagementService` en el orden de resolución Credo.
 */
export const ADDITIONAL_KEY_MANAGEMENT_SERVICES = Symbol(
  'AdditionalKeyManagementServices',
)
