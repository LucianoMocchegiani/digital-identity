import 'package:freezed_annotation/freezed_annotation.dart';

part 'did_record.freezed.dart';

/// Registro de un DID controlado por el wallet.
///
/// Almacena el DID, su documento y las referencias a las claves criptográficas
/// en [KeyRecordStore]. Soporta los métodos did:key, did:jwk, did:web y did:peer.
@freezed
class DidRecord with _$DidRecord {
  const factory DidRecord({
    /// El DID completo (ej. `'did:key:z6Mk...'`).
    required String did,

    /// Método DID (`'key'`, `'jwk'`, `'peer'`, `'web'`).
    required String method,

    /// DID Document completo en formato JSON.
    required Map<String, dynamic> document,

    /// IDs de las claves asociadas en [KeyRecordStore].
    required List<String> keyIds,

    /// Fecha de creación del DID.
    required DateTime createdAt,
  }) = _DidRecord;
}
