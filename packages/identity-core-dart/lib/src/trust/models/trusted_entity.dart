import 'package:freezed_annotation/freezed_annotation.dart';

import 'trust_mechanism.dart';

part 'trusted_entity.freezed.dart';

/// Información del verifier/issuer extraída del mecanismo de confianza.
@freezed
class TrustedEntity with _$TrustedEntity {
  const factory TrustedEntity({
    required TrustMechanismType trustMechanism,
    required RelyingParty relyingParty,

    /// `true` si la cadena de confianza fue verificada correctamente.
    required bool isVerified,

    /// Cadena de certificados X.509 en base64 DER (solo para [TrustMechanismType.x509]).
    List<String>? certificateChain,

    /// DID del verifier (solo para [TrustMechanismType.did]).
    String? did,
  }) = _TrustedEntity;
}

/// Información del relying party (verifier) extraída del mecanismo de confianza.
@freezed
class RelyingParty with _$RelyingParty {
  const factory RelyingParty({
    /// Identificador de la entidad — `client_id` del authorization request.
    required String entityId,

    /// Nombre de la organización, extraído del Subject DN (X.509) o `client_metadata`.
    String? organizationName,

    /// URI del logo del verifier.
    String? logoUri,

    /// URI de la entidad (extraído de SAN URI o `client_metadata`).
    String? uri,

    /// Dominio del verifier (extraído de SAN DNS del certificado leaf).
    String? domain,
  }) = _RelyingParty;
}
