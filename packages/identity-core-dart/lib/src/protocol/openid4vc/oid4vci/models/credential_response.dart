import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_response.freezed.dart';
part 'credential_response.g.dart';

/// Respuesta del credential endpoint de OID4VCI.
///
/// Si [credential] está presente la credencial fue emitida de inmediato.
/// Si [transactionId] está presente la credencial es diferida.
@freezed
class CredentialResponse with _$CredentialResponse {
  const factory CredentialResponse({
    /// Credencial emitida de forma inmediata (JWT, SD-JWT o base64url CBOR).
    String? credential,

    /// ID de transacción para polling de credencial diferida.
    @JsonKey(name: 'transaction_id') String? transactionId,

    /// Nonce fresco para el siguiente credential request.
    @JsonKey(name: 'c_nonce') String? cNonce,

    /// Segundos hasta la expiración del nuevo c_nonce.
    @JsonKey(name: 'c_nonce_expires_in') int? cNonceExpiresIn,

    /// ID de notificación para el notification endpoint (opcional).
    @JsonKey(name: 'notification_id') String? notificationId,
  }) = _CredentialResponse;

  factory CredentialResponse.fromJson(Map<String, dynamic> json) =>
      _$CredentialResponseFromJson(json);
}
