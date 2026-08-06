import 'package:freezed_annotation/freezed_annotation.dart';

part 'deferred_credential_record.freezed.dart';

/// Registro de una credencial diferida (respuesta `transaction_id` del credential endpoint).
///
/// El issuer devuelve un `transaction_id` cuando la credencial no está disponible
/// de inmediato. El wallet debe reintentar con [Oid4VciService.retryDeferred]
/// hasta que el issuer la emita o la request expire.
///
/// Espeja `PARADYM_OID4VCI_DEFERRED_CREDENTIAL_RECORD` del paradym-wallet SDK.
@freezed
class DeferredCredentialRecord with _$DeferredCredentialRecord {
  const factory DeferredCredentialRecord({
    /// Identificador único del registro (UUID v4).
    required String id,

    /// Fecha de creación del registro.
    required DateTime createdAt,

    /// Última vez que se consultó el deferred credential endpoint.
    required DateTime lastCheckedAt,

    /// Última vez que ocurrió un error al consultar el endpoint.
    DateTime? lastErroredAt,

    /// Respuesta original del credential endpoint con el `transaction_id`.
    required Map<String, dynamic> response,

    /// Metadata del issuer necesaria para construir la URL de deferred credential.
    required Map<String, dynamic> issuerMetadata,

    /// Access token para autenticar la request de deferred credential.
    required Map<String, dynamic> accessToken,
  }) = _DeferredCredentialRecord;
}
