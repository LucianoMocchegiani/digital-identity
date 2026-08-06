import type { Kms } from '@credo-ts/core'

/**
 * Port Quark de gestión de claves del agente (paridad con `RecordStorage` / `StatusListStorage`).
 *
 * Los servicios Nest inyectan una implementación concreta
 * (`PostgresKeyManagementService`, `AskarKeyManagementService`, …).
 * identity-core registra la instancia en el agente Credo sin bifurcar por mode.
 */
export type KeyManagementService = Kms.KeyManagementService
