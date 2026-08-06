/**
 * @quarkid/identity-core — Agentes, identidades, credenciales y protocolos para QuarkID 2.0.
 */

// CRITICAL: NativeAskar.register antes de cualquier import de @credo-ts/askar (ESM).
import './askar-native'
export { askar } from './askar-native'

// Agent bootstrap
export * from './agent'

// DID Management
export * from './did/web-did'
export * from './did/key-did'
export * from './did/did'
export * from './did/registrar/web.registrar'
export * from './did/registrar/quark.registrar'
export * from './did/resolver/quark.resolver'
export * from './did/resolver/quarkid.resolver'
export * from './did/resolver/web-http.resolver'
export * from './did/resolver/web.factory'

// KMS
export type { KeyManagementService } from './kms/key-management.interface'
export { KeyManagementBootstrapError } from './kms/key-management.errors'
export * from './kms/postgres-key-management.service'
export * from './kms/bbs-key-management.service'
export * from './kms/askar-domain-key-management.service'
export * from './kms/bbs-kms'
export * from './kms/domain-key'
export { AskarKeyManagementService } from '@credo-ts/askar'

// Record (RMS)
export * from './record/record-storage.types'
export * from './record/record-storage.interface'
export * from './record/record-storage.errors'
export * from './record/record-storage.resolve'
export * from './record/postgres-record.storage'
export * from './record/askar-record.storage'
export * from './record/quark-wallet-record.types'
export * from './record/tenant-records'
export * from './record/record-type-catalog'

// Credential Management (CMS)
export * from './credential/credential.builder'
export * from './credential/bbs'

// Protocol — DIDComm
export * from './protocol/didcomm/issuance'
export * from './protocol/didcomm/presentation'
export * from './protocol/didcomm/invitation'
export * from './protocol/didcomm/transport'
export { QuarkJsonLdCredentialFormatService } from './protocol/didcomm/quark-jsonld-credential-format.service'
export { QuarkDifPresentationExchangeProofFormatService } from './protocol/didcomm/quark-dif-pex-proof-format.service'

// Protocol — OpenID4VC
export * from './protocol/openid4vc/issuer.oid4vc'
export * from './protocol/openid4vc/issuer.oid4vc.listener'
export * from './protocol/openid4vc/holder.oid4vc'
export * from './protocol/openid4vc/verifier.oid4vc'
export * from './protocol/openid4vc/verifier.oid4vc.listener'
export * from './protocol/openid4vc/binding.resolver'

// Types & config
export * from './types/config.types'
export type { CredoLogger } from './types/logger.types'
export { QuarkCredoAgentLogger } from './types/credo-agent-logger'
export { buildCredoConfigFromEnv } from './agent/config'
export type { CredoEnvConfig } from './agent/config'

// Credo-TS re-exports
export {
  DidsApi,
  JsonTransformer,
  KeyDidResolver,
  JwkDidResolver,
} from '@credo-ts/core'
export { TenantsApi } from '@credo-ts/tenants'
export type { Agent } from '@credo-ts/core'
export type {
  AgentContext,
  DidDocument,
  DidRecord,
  DidResolver,
  SdJwtVcHolderBinding,
  SdJwtVcRecord,
  W3cCredentialRecord,
  W3cV2CredentialRecord,
} from '@credo-ts/core'
export type {
  DidCommConnectionRecord,
  DidCommCredentialExchangeRecord,
  DidCommOutOfBandRecord,
  DidCommProofExchangeRecord,
} from '@credo-ts/didcomm'

export type { ConnectionReadyPayload } from './protocol/didcomm/shared.listener'
export type {
  VerifiedOpenId4VcCredentialHolderBinding,
  OpenId4VciCredentialRequestToCredentialMapperOptions,
  OpenId4VcIssuanceSessionRecord,
  OpenId4VcIssuerRecord,
  OpenId4VcVerificationSessionRecord,
  OpenId4VcVerifierRecord,
} from '@credo-ts/openid4vc'

// Utils
export * from './utils/retry'

// Revocation (Token Status List) — superficie pública controlada
export { RevocationService } from './revocation/revocation.service';
export { RevocationIssuer } from './revocation/revocation.issuer';
export { createRevocationIssuer } from './revocation/revocation.factory';
export type { RevocationIssuerDeps } from './revocation/revocation.factory';
export type { SignerProvider, StatusListUriBuilder } from './revocation/ports';
export type {
  SignerOptions,
  SignerMetadata,
  StatusType,
  BitsPerStatus,
} from './revocation/status-list.types';
export { SIGNER_PROVIDER, STATUS_LIST_URI_BUILDER } from './revocation/ports';
export { StatusListService } from './revocation/status-list.service';
export { PostgresStatusListStorage } from './revocation/postgres-status-list.storage';
export type { StatusListStorage } from './revocation/status-list-storage.interface';
export { MESSAGING_SERVICE } from './revocation/messaging.interface';
export type { MessagingService } from './revocation/messaging.interface';
// Derivación de SignerMetadata (helper reusable para consumers con agente Credo)
export { resolveSignerFromAgent, pickDidRecordKey, deriveAlgFromKms } from './revocation/signer.derivation';
export type { SignerDerivationOptions, DidRecordKey } from './revocation/signer.derivation';
export {
  CredentialAlreadyRevokedError,
  StatusListNotFoundError,
  NoFreeIndexError,
  IndexOutOfBoundsError,
  InvalidStatusListJwtError,
} from './revocation/revocation.errors';
