import '../../../record/models/connection_record.dart';
import '../transport/ws_transport.dart';

/// Resultado del handshake DID Exchange contra una invitación OOB.
class ConnectionHandshakeResult {
  const ConnectionHandshakeResult({
    required this.connection,
    this.webSocket,
    required this.serviceEndpoint,
    required this.recipientKeyDid,
  });

  /// Conexión persistida tras el intercambio (estado `complete` si hubo endpoint).
  final ConnectionRecord connection;

  /// Socket activo cuando el caller pidió mantenerlo abierto para el flujo.
  final WsConnection? webSocket;

  /// Endpoint HTTP DIDComm del invitador (del OOB).
  final String? serviceEndpoint;

  /// `did:key` del receptor usado para cifrar mensajes salientes.
  final String? recipientKeyDid;
}
