import type { Express } from 'express'
import type { WebSocketServer } from 'ws'
import {
  createRootHolderAgent,
  buildCredoConfigFromEnv,
  ensureAskarStoreProvisioned,
  loadTenantMap,
  type CredoLogger,
  type KeyManagementService,
  type QuarkAskarStoreOptions,
  type RecordStorage,
} from '@identity/core'
import { environmentConfig } from '../config'
import { setRootAgent } from './agent-store'

/**
 * Inicializa el agente root multi-tenant del holder.
 */
export async function initializeRootHolderAgent(
  expressApp: Express | undefined,
  wss: WebSocketServer | undefined,
  recordStorage: RecordStorage,
  keyManagementService: KeyManagementService,
  logger?: CredoLogger,
  askarStore?: QuarkAskarStoreOptions,
  additionalKeyManagementServices?: KeyManagementService[],
): Promise<void> {
  if (askarStore) {
    await ensureAskarStoreProvisioned(askarStore)
  }
  const config = buildCredoConfigFromEnv(environmentConfig())
  const agent = await createRootHolderAgent(config, {
    expressApp,
    wsServer: wss,
    logger,
    recordStorage,
    keyManagementService,
    additionalKeyManagementServices,
    askarStore,
  })
  const map = await loadTenantMap(agent)
  setRootAgent(agent, map)
}
