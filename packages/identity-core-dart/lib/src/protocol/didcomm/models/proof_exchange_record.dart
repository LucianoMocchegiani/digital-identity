import 'package:freezed_annotation/freezed_annotation.dart';

part 'proof_exchange_record.freezed.dart';

/// Estado del intercambio de prueba (RFC 0037 present-proof).
enum ProofExchangeState {
  requestReceived,
  presentationSent,
  done,
  error,
}

/// Registro en memoria del intercambio de presentación DIDComm (RFC 0037).
@freezed
class ProofExchangeRecord with _$ProofExchangeRecord {
  const factory ProofExchangeRecord({
    required String exchangeId,
    required String connectionId,
    required ProofExchangeState state,
    required DateTime createdAt,
    Map<String, dynamic>? requestAttach,
    String? threadId,
    String? presentationId,
    String? error,
  }) = _ProofExchangeRecord;
}
