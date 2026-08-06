import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_record.freezed.dart';

enum ConnectionState { invited, requested, responded, complete }

/// Registro de una conexión DIDComm con otro agente.
@freezed
class ConnectionRecord with _$ConnectionRecord {
  const factory ConnectionRecord({
    /// UUID de la conexión.
    required String connectionId,

    /// DID local generado para esta conexión (normalmente `did:peer:2`).
    required String myDid,

    /// DID del par remoto.
    required String theirDid,

    /// Estado actual del protocolo de conexión.
    required ConnectionState state,

    required DateTime createdAt,

    /// Nombre legible del par (del campo `label` de la invitación).
    String? label,

    /// Código de objetivo de la invitación (p.ej. `issue-vc`).
    String? goalCode,

    /// DID Document del par, almacenado al completar el handshake.
    Map<String, dynamic>? theirDidDoc,
  }) = _ConnectionRecord;
}
