import type {
  DidRecord,
  SdJwtVcRecord,
  StorageVersionRecord,
  W3cCredentialRecord,
  W3cV2CredentialRecord,
} from '@credo-ts/core'
import type {
  DidCommConnectionRecord,
  DidCommCredentialExchangeRecord,
  DidCommMessageRecord,
  DidCommOutOfBandRecord,
  DidCommProofExchangeRecord,
} from '@credo-ts/didcomm'
import type {
  OpenId4VcIssuanceSessionRecord,
  OpenId4VcIssuerRecord,
  OpenId4VcVerificationSessionRecord,
  OpenId4VcVerifierRecord,
} from '@credo-ts/openid4vc'

/**
 * Unión de todos los tipos de record concretos que QuarkID almacena en la wallet.
 *
 * Cada agente (issuer/holder/verifier) persiste un subconjunto:
 * - **Todos**: `StorageVersionRecord`, `DidRecord`
 * - **Holder**: credenciales SD-JWT/W3C, conexiones y exchanges DIDComm
 * - **Issuer**: conexiones DIDComm, `OpenId4VcIssuerRecord`, `OpenId4VcIssuanceSessionRecord`
 * - **Verifier**: conexiones DIDComm, `OpenId4VcVerifierRecord`, `OpenId4VcVerificationSessionRecord`
 */
export type QuarkWalletRecord =
  | StorageVersionRecord
  | DidRecord
  | SdJwtVcRecord
  | W3cCredentialRecord
  | W3cV2CredentialRecord
  | DidCommConnectionRecord
  | DidCommCredentialExchangeRecord
  | DidCommProofExchangeRecord
  | DidCommOutOfBandRecord
  | DidCommMessageRecord
  | OpenId4VcIssuerRecord
  | OpenId4VcIssuanceSessionRecord
  | OpenId4VcVerifierRecord
  | OpenId4VcVerificationSessionRecord
