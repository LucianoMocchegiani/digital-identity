import type { Express } from 'express'
import type { WebSocketServer } from 'ws'
import {
  createRootVerifierAgent,
  buildCredoConfigFromEnv,
  ensureAskarStoreProvisioned,
  loadTenantMap,
  type ConnectionReadyPayload,
  type CredoLogger,
  type KeyManagementService,
  type QuarkAskarStoreOptions,
  type RecordStorage,
} from '@quarkid/identity-core'
import { environmentConfig } from '../config'
import { setRootAgent } from './agent-store'

/**
 * Crea el agente root multi-tenant del verifier, carga el mapa de tenants existentes
 * y lo registra en el store global.
 */
export async function initializeRootVerifierAgent(
  expressApp: Express | undefined,
  wss: WebSocketServer | undefined,
  recordStorage: RecordStorage,
  keyManagementService: KeyManagementService,
  logger?: CredoLogger,
  onConnectionReady?: (payload: ConnectionReadyPayload) => void | Promise<void>,
  askarStore?: QuarkAskarStoreOptions,
  additionalKeyManagementServices?: KeyManagementService[],
): Promise<void> {
  if (askarStore) {
    await ensureAskarStoreProvisioned(askarStore)
  }
  const config = buildCredoConfigFromEnv(environmentConfig())
  const agent = await createRootVerifierAgent(config, {
    expressApp,
    wsServer: wss,
    logger,
    recordStorage,
    keyManagementService,
    additionalKeyManagementServices,
    askarStore,
    onConnectionReady,
  })
  const map = await loadTenantMap(agent)
  setRootAgent(agent, map)
}
