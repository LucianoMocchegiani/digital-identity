import type { Express } from 'express'
import type { WebSocketServer } from 'ws'
import {
  createRootIssuerAgent,
  buildCredoConfigFromEnv,
  ensureAskarStoreProvisioned,
  loadTenantMap,
  type ConnectionReadyPayload,
  type CredoLogger,
  type KeyManagementService,
  type QuarkAskarStoreOptions,
  type RecordStorage,
} from '@identity/core'
import { environmentConfig } from '../config'
import { setRootAgent } from './agent-store'

/**
 * Inicializa el agente root multi-tenant del issuer (DIDComm + OID4VCI).
 *
 * @param expressApp - App Express de Nest (inbound DIDComm HTTP + OID4VCI)
 * @param wss - WebSocketServer compartido con el HTTP server de Nest
 * @param recordStorage - Persistencia de records Credo (Askar en este producto)
 * @param keyManagementService - KMS primario (Askar)
 * @param logger - Logger estructurado del servicio
 * @param onConnectionReady - Dispara pending offers al `completed` / handshake-reuse
 * @param askarStore - Store Askar obligatorio
 * @param additionalKeyManagementServices - Sidecar BBS y otros backends
 */
export async function initializeRootIssuerAgent(
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
  const agent = await createRootIssuerAgent(config, {
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
