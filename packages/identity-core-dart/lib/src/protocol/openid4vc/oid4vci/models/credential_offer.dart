import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_offer.freezed.dart';
part 'credential_offer.g.dart';

/// Offer de credencial recibido del issuer vía URI o QR.
@freezed
class CredentialOffer with _$CredentialOffer {
  const factory CredentialOffer({
    /// URL del credential issuer.
    @JsonKey(name: 'credential_issuer') required String credentialIssuer,

    /// IDs de las configuraciones de credencial ofrecidas.
    @JsonKey(name: 'credential_configuration_ids')
    required List<String> credentialConfigurationIds,

    /// Grants disponibles (pre-authorized, authorization code).
    GrantsContainer? grants,
  }) = _CredentialOffer;

  factory CredentialOffer.fromJson(Map<String, dynamic> json) =>
      _$CredentialOfferFromJson(json);
}

/// Contenedor de grants del offer.
@freezed
class GrantsContainer with _$GrantsContainer {
  const factory GrantsContainer({
    /// Grant pre-authorized_code.
    @JsonKey(name: 'urn:ietf:params:oauth:grant-type:pre-authorized_code')
    PreAuthorizedGrant? preAuthorized,

    /// Grant authorization_code.
    @JsonKey(name: 'authorization_code') AuthorizationCodeGrant? authCode,
  }) = _GrantsContainer;

  factory GrantsContainer.fromJson(Map<String, dynamic> json) =>
      _$GrantsContainerFromJson(json);
}

/// Grant de tipo pre-authorized_code.
@freezed
class PreAuthorizedGrant with _$PreAuthorizedGrant {
  const factory PreAuthorizedGrant({
    /// Código pre-autorizado de un solo uso.
    @JsonKey(name: 'pre-authorized_code') required String preAuthorizedCode,

    /// Información sobre el código de transacción requerido (e.g. PIN de 4 dígitos).
    @JsonKey(name: 'tx_code') TxCodeInfo? txCode,
  }) = _PreAuthorizedGrant;

  factory PreAuthorizedGrant.fromJson(Map<String, dynamic> json) =>
      _$PreAuthorizedGrantFromJson(json);
}

/// Metadatos del código de transacción (tx_code / PIN).
@freezed
class TxCodeInfo with _$TxCodeInfo {
  const factory TxCodeInfo({
    /// Longitud esperada del código.
    int? length,

    /// Modo de entrada: `'numeric'` o `'text'`.
    @JsonKey(name: 'input_mode') String? inputMode,

    /// Descripción para mostrar al usuario.
    String? description,
  }) = _TxCodeInfo;

  factory TxCodeInfo.fromJson(Map<String, dynamic> json) =>
      _$TxCodeInfoFromJson(json);
}

/// Grant de tipo authorization_code.
@freezed
class AuthorizationCodeGrant with _$AuthorizationCodeGrant {
  const factory AuthorizationCodeGrant({
    /// URL del issuer state para iniciar el flujo.
    @JsonKey(name: 'issuer_state') String? issuerState,

    /// Servidor de autorización que emitirá el token.
    @JsonKey(name: 'authorization_server') String? authorizationServer,
  }) = _AuthorizationCodeGrant;

  factory AuthorizationCodeGrant.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationCodeGrantFromJson(json);
}
