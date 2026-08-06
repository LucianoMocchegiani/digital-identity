import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response.freezed.dart';
part 'token_response.g.dart';

/// Respuesta del token endpoint de OID4VCI.
@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    /// Access token para autorizar requests al credential endpoint.
    @JsonKey(name: 'access_token') required String accessToken,

    /// Tipo de token, normalmente `'Bearer'`.
    @JsonKey(name: 'token_type') required String tokenType,

    /// Segundos hasta la expiración del token.
    @JsonKey(name: 'expires_in') int? expiresIn,

    /// Nonce para incluir en el proof JWT del credential request.
    @JsonKey(name: 'c_nonce') String? cNonce,

    /// Segundos hasta la expiración del c_nonce.
    @JsonKey(name: 'c_nonce_expires_in') int? cNonceExpiresIn,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}
