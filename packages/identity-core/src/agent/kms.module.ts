import type { DependencyManager } from '@credo-ts/core'
import { Kms } from '@credo-ts/core'
import { KeyManagementBootstrapError } from '../kms/key-management.errors'
import type { KeyManagementService } from '../kms/key-management.interface'

/**
 * Registra el/los {@link KeyManagementService} inyectados en el DI de Credo.
 *
 * El primario define `defaultBackend`. Los adicionales (BBS, domain-key, …)
 * se agregan a `backends` en el orden dado para operaciones que el primario
 * no resuelve.
 */
export function registerKmsConfig(
  dependencyManager: DependencyManager,
  keyManagementService: KeyManagementService | undefined,
  additionalKeyManagementServices?: KeyManagementService[],
): void {
  if (!keyManagementService) {
    throw new KeyManagementBootstrapError(
      'keyManagementService es obligatorio: inyectar AskarKeyManagementService, PostgresKeyManagementService u otro adapter desde Nest.',
    )
  }

  const backends = collectKmsBackends(
    keyManagementService,
    additionalKeyManagementServices,
  )

  dependencyManager.registerInstance(
    Kms.KeyManagementModuleConfig,
    new Kms.KeyManagementModuleConfig({
      backends,
      defaultBackend: keyManagementService.backend,
    }),
  )
}

/**
 * Construye el módulo Credo `keyManagement` a partir del port Quark inyectado.
 */
export function buildKeyManagementModule(
  keyManagementService: KeyManagementService,
  additionalKeyManagementServices?: KeyManagementService[],
): Kms.KeyManagementModule {
  if (!keyManagementService) {
    throw new KeyManagementBootstrapError(
      'keyManagementService es obligatorio: inyectar desde Nest.',
    )
  }

  return new Kms.KeyManagementModule({
    backends: collectKmsBackends(
      keyManagementService,
      additionalKeyManagementServices,
    ),
    defaultBackend: keyManagementService.backend,
  })
}

/**
 * Arma la lista de backends sin duplicar instancias.
 *
 * @param primary - Backend default
 * @param additional - Backends secundarios (BBS, domain-key, …)
 */
export function collectKmsBackends(
  primary: KeyManagementService,
  additional?: KeyManagementService[],
): KeyManagementService[] {
  if (!additional?.length) {
    return [primary]
  }

  const backends: KeyManagementService[] = [primary]
  for (const service of additional) {
    if (service && service !== primary && !backends.includes(service)) {
      backends.push(service)
    }
  }
  return backends
}
