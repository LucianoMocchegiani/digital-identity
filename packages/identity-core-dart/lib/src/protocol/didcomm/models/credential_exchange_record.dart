import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_exchange_record.freezed.dart';

/// Estado del intercambio de credenciales (RFC 0036 issue-credential).
enum CredentialExchangeState {
  offerReceived,
  requestSent,
  credentialReceived,
  done,
  error,
}

/// Registro en memoria del intercambio de credenciales DIDComm (RFC 0036).
@freezed
class CredentialExchangeRecord with _$CredentialExchangeRecord {
  const factory CredentialExchangeRecord({
    required String exchangeId,
    required String connectionId,
    required CredentialExchangeState state,
    required DateTime createdAt,
    Map<String, dynamic>? offerAttach,
    Map<String, dynamic>? credentialAttach,
    String? threadId,
    String? error,
  }) = _CredentialExchangeRecord;
}
