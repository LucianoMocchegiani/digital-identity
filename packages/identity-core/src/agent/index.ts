export { buildDidsModule } from './dids.module'
export { registerRecordConfig } from './record.module'
export { registerKmsConfig, buildKeyManagementModule } from './kms.module'
export {
  buildAskarStoreOnlyModule,
  buildAskarPostgresDatabase,
  parsePostgresUrlForAskar,
} from './askar.module'
export type { QuarkAskarStoreOptions } from './askar.module'
export { ensureAskarStoreProvisioned } from './askar-store-ensure'
export { buildRootAgentInitConfig, ROOT_AGENT_INIT_CONFIG } from './credo-init-config'
export { createIssuerAgent, createRootIssuerAgent } from './issuer.agent'
export { createHolderAgent, createRootHolderAgent } from './holder.agent'
export { createVerifierAgent, createRootVerifierAgent } from './verifier.agent'
export { ensureTenant, withTenant, loadTenantMap } from './tenant'
export {
  createIssuerWallet,
  createVerifierWallet,
  createHolderWallet,
  getTenantWebDid,
  getTenantKeyDid,
} from './wallet'
export { ROOT_STORAGE_SCOPE, DOMAIN_KEY_SCOPE } from '../constants'
export type {
  CreateAgentOptions,
  RootAgentOptions,
  CreateIssuerAgentOptions,
  CreateRootIssuerAgentOptions,
  CreateHolderAgentOptions,
  CreateRootHolderAgentOptions,
  CreateVerifierAgentOptions,
  CreateRootVerifierAgentOptions,
  IssuerOid4vcOptions,
  VerifierOid4vcOptions,
} from './create-agent-options.types'
