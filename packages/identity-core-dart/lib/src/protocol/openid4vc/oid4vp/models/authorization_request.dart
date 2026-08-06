import 'package:freezed_annotation/freezed_annotation.dart';

part 'authorization_request.freezed.dart';
part 'authorization_request.g.dart';

/// Authorization Request de OID4VP recibido del verifier.
@freezed
class AuthorizationRequest with _$AuthorizationRequest {
  const factory AuthorizationRequest({
    /// Tipo de respuesta esperado. Normalmente `'vp_token'`.
    @JsonKey(name: 'response_type') required String responseType,

    /// Identificador del cliente (verifier).
    @JsonKey(name: 'client_id') required String clientId,

    /// Modo de respuesta. Normalmente `'direct_post'`.
    @JsonKey(name: 'response_mode') String? responseMode,

    /// URI a la que el wallet envía la respuesta via POST.
    @JsonKey(name: 'response_uri') String? responseUri,

    /// Nonce para prevenir replay attacks. Incluido en el kb-JWT y VP JWT.
    String? nonce,

    /// Estado opaco del verifier, devuelto en la respuesta.
    String? state,

    /// Presentation Definition (PEX) en formato crudo.
    @JsonKey(name: 'presentation_definition') Map<String, dynamic>? presentationDefinition,

    /// Referencia URI a una Presentation Definition externa.
    @JsonKey(name: 'presentation_definition_uri') String? presentationDefinitionUri,

    /// DCQL query para selección de credenciales.
    @JsonKey(name: 'dcql_query') Map<String, dynamic>? dcqlQuery,

    /// Metadatos del cliente verifier (nombre, logo, políticas).
    @JsonKey(name: 'client_metadata') Map<String, dynamic>? clientMetadata,

    /// Scope adicional.
    String? scope,

    /// Algoritmo JWE (`direct_post.jwt`). Normalmente `ECDH-ES`.
    @JsonKey(name: 'authorization_encrypted_response_alg')
    String? authorizationEncryptedResponseAlg,

    /// Cifrado de contenido JWE. Normalmente `A128GCM`.
    @JsonKey(name: 'authorization_encrypted_response_enc')
    String? authorizationEncryptedResponseEnc,
  }) = _AuthorizationRequest;

  factory AuthorizationRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationRequestFromJson(json);
}
