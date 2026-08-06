import type { DependencyManager } from '@credo-ts/core'
import type { AskarModule } from '@credo-ts/askar'

import type { RootAgentOptions } from './create-agent-options.types'
import { buildAskarStoreOnlyModule } from './askar.module'
import { buildKeyManagementModule, registerKmsConfig } from './kms.module'
import { registerRecordConfig } from './record.module'

/**
 * Registra record storage y KMS (primario + adicionales) inyectados por Nest.
 */
export function registerInjectedStorageAndKms(
  dependencyManager: DependencyManager,
  options: RootAgentOptions,
): void {
  registerRecordConfig(dependencyManager, options.recordStorage)
  registerKmsConfig(
    dependencyManager,
    options.keyManagementService,
    options.additionalKeyManagementServices,
  )
}

/**
 * Módulo Askar store-only si el integrador pasó `askarStore`; si no, objeto vacío.
 */
export function buildOptionalAskarModule(
  options: RootAgentOptions,
): { askar: AskarModule } | Record<string, never> {
  if (!options.askarStore) {
    return {}
  }
  return { askar: buildAskarStoreOnlyModule(options.askarStore) }
}

/**
 * Módulo Credo `keyManagement` con backends primario (+ adicionales opcionales).
 */
export function buildInjectedKeyManagementModule(options: RootAgentOptions) {
  return buildKeyManagementModule(
    options.keyManagementService,
    options.additionalKeyManagementServices,
  )
}
