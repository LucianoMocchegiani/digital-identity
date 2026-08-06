import { LogLevel } from '@credo-ts/core'

import { QuarkCredoAgentLogger } from '../types/credo-agent-logger'
import type { CredoLogger } from '../types/logger.types'

/**
 * Opciones de inicialización del agente root compatibles con `InitConfig` de Credo.
 *
 * Si se pasa `appLogger` (p. ej. Nest `JsonLoggerService`), los logs internos de
 * Credo (DIDComm decrypt, timeouts, etc.) usan ese manejador JSON. Sin él,
 * se usa el mismo adapter sobre `console` (sigue siendo estructurable vía Nest
 * cuando el servicio lo inyecta en `createRoot*Agent`).
 */
export function buildRootAgentInitConfig(appLogger?: CredoLogger) {
  return {
    autoUpdateStorageOnStartup: true,
    allowInsecureHttpUrls: true,
    logger: new QuarkCredoAgentLogger(appLogger, LogLevel.Warn),
  }
}

/**
 * @deprecated Preferir {@link buildRootAgentInitConfig} con el logger del servicio.
 * Conservado para imports existentes; usa Console vía adapter sin Nest.
 */
export const ROOT_AGENT_INIT_CONFIG = buildRootAgentInitConfig()
