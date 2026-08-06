/// identity_core_dart — SDK Dart-nativo para wallets SSI (OID4VCI, OID4VP, DIDComm).
///
/// Exporta los modelos de dominio, stores de persistencia (isar cifrado) y
/// servicios KMS. Las capas de protocolo OID4VCI, OID4VP y DIDComm se
/// agregan en fases posteriores.
library;

// — Modelos de credencial —
export 'src/credential/models/credential_record.dart';
export 'src/credential/models/sd_jwt_vc_record.dart';
export 'src/credential/models/w3c_credential_record.dart';
export 'src/credential/models/mdoc_record.dart';

// — Modelos de visualización —
export 'src/credential/display/attribute_formatter.dart';
export 'src/credential/display/credential_for_display.dart';
export 'src/credential/display/labeled_claim.dart';
export 'src/credential/display/claim_display_resolver.dart';

// — Modelos de record —
export 'src/record/models/did_record.dart';
export 'src/record/models/key_record.dart';
export 'src/record/models/activity.dart';
export 'src/record/models/deferred_credential_record.dart';
export 'src/record/models/connection_record.dart';

// — Persistencia —
export 'src/record/record_service.dart';
export 'src/record/record_store.dart';
export 'src/record/credential_record_store.dart';
export 'src/record/did_record_store.dart';
export 'src/record/key_record_store.dart';
export 'src/record/activity_record_store.dart';
export 'src/record/deferred_credential_record_store.dart';
export 'src/record/connection_record_store.dart';

// — KMS —
export 'src/kms/kms_service.dart';
export 'src/kms/software_kms.dart';
export 'src/kms/hardware_kms.dart';
export 'src/kms/kms_backend_selector.dart';

// — DIDs —
export 'src/did/did_key.dart';
export 'src/did/did_jwk.dart';
export 'src/did/did_peer.dart';
export 'src/did/did_resolver.dart';
export 'src/did/did_service.dart';

// — Session store —
export 'src/record/session_record_store.dart';

// — OID4VCI modelos —
export 'src/protocol/openid4vc/oid4vci/models/credential_offer.dart';
export 'src/protocol/openid4vc/oid4vci/models/issuer_metadata.dart';
export 'src/protocol/openid4vc/oid4vci/models/token_response.dart';
export 'src/protocol/openid4vc/oid4vci/models/credential_response.dart';

// — OID4VCI servicio —
export 'src/protocol/openid4vc/oid4vci/credential_response_parser.dart';
export 'src/protocol/openid4vc/oid4vci/oid4vci_service.dart';

// — SD-JWT —
export 'src/sd_jwt/sd_jwt_parser.dart';
export 'src/sd_jwt/sd_jwt_selector.dart';
export 'src/sd_jwt/sd_jwt_pretty_claims.dart';
export 'src/sd_jwt/holder_binding.dart';

// — OID4VP modelos —
export 'src/protocol/openid4vc/oid4vp/models/authorization_request.dart';
export 'src/protocol/openid4vc/oid4vp/models/presentation_definition.dart';
export 'src/protocol/openid4vc/oid4vp/models/dcql_query.dart';
export 'src/protocol/openid4vc/oid4vp/models/credentials_for_request.dart';

// — OID4VP servicio —
export 'src/protocol/openid4vc/oid4vp/oid4vp_service.dart';

// — Invitation —
export 'src/invitation/models/invitation_type.dart';
export 'src/invitation/models/invitation_result.dart';
export 'src/invitation/invitation_parser.dart';
export 'src/invitation/invitation_resolver.dart';

// — Trust —
export 'src/trust/models/trust_mechanism.dart';
export 'src/trust/models/trusted_entity.dart';
export 'src/trust/trust_config.dart';
export 'src/trust/trust_detector.dart';
export 'src/trust/x509_trust.dart';
export 'src/trust/did_trust.dart';
export 'src/trust/eudi_rp_trust.dart';

// — DIDComm modelos —
export 'src/protocol/didcomm/models/didcomm_message.dart';
export 'src/protocol/didcomm/models/credential_exchange_record.dart';
export 'src/protocol/didcomm/models/proof_exchange_record.dart';
export 'src/protocol/didcomm/connection/connection_handshake_result.dart';
export 'src/protocol/didcomm/flow/didcomm_flow_event.dart';
export 'src/protocol/didcomm/flow/didcomm_flow_session.dart';

// — DIDComm servicios —
export 'src/protocol/didcomm/didcomm_service.dart';
export 'src/protocol/didcomm/connection/connection_service.dart';
export 'src/protocol/didcomm/credential/credential_exchange_service.dart';
export 'src/protocol/didcomm/credential/didcomm_credential_attach.dart';
export 'src/protocol/didcomm/proof/proof_exchange_service.dart';
export 'src/protocol/didcomm/proof/didcomm_proof_attach.dart';
export 'src/protocol/didcomm/proof/didcomm_presentation_builder.dart';
export 'src/protocol/didcomm/oob/oob_parser.dart';
export 'src/protocol/didcomm/oob/oob_resolver.dart';
export 'src/protocol/didcomm/transport/ws_transport.dart';

// — BBS+ (DIDComm selective disclosure) —
export 'src/credential/bbs/index.dart';

// — Wallet —
export 'src/crypto/field_cipher.dart';
export 'src/crypto/pin_verifier.dart';
export 'src/crypto/wallet_crypto_context.dart';
export 'src/wallet/wallet_exceptions.dart';
export 'src/wallet/wallet_secure_storage.dart';
export 'src/wallet/wallet_session.dart';
export 'src/wallet/wallet_service.dart';
