import 'package:freezed_annotation/freezed_annotation.dart';

part 'issuer_metadata.freezed.dart';
part 'issuer_metadata.g.dart';

/// Metadatos del credential issuer.
///
/// Obtenidos de `{credentialIssuer}/.well-known/openid-credential-issuer`.
@freezed
class IssuerMetadata with _$IssuerMetadata {
  const factory IssuerMetadata({
    /// URL base del issuer.
    @JsonKey(name: 'credential_issuer') required String credentialIssuer,

    /// Endpoint para solicitar credenciales.
    @JsonKey(name: 'credential_endpoint') required String credentialEndpoint,

    /// Endpoint para obtener el access token.
    ///
    /// Puede estar en el authorization server metadata; se permite nulo
    /// si se obtiene por separado.
    @JsonKey(name: 'token_endpoint') String? tokenEndpoint,

    /// Map de configuraciones de credencial soportadas, indexadas por ID.
    @JsonKey(name: 'credential_configurations_supported')
    required Map<String, dynamic> credentialConfigurationsSupported,

    /// Metadatos de display del issuer (nombre, logo, etc.).
    List<Map<String, dynamic>>? display,

    /// Servidor de autorización asociado (puede diferir del issuer).
    @JsonKey(name: 'authorization_servers') List<String>? authorizationServers,
  }) = _IssuerMetadata;

  factory IssuerMetadata.fromJson(Map<String, dynamic> json) =>
      _$IssuerMetadataFromJson(json);
}
