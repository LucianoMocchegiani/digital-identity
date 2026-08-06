import 'dart:async';
import 'dart:convert';

import '../../../record/models/connection_record.dart';
import '../../../record/models/key_record.dart';
import '../crypto/didcomm_envelope_v1.dart';
import '../transport/ws_transport.dart';
import 'didcomm_flow_event.dart';
import 'didcomm_message_router.dart';

/// Sesión DIDComm activa: mantiene el WebSocket abierto y emite mensajes
/// desencriptados mientras dura un flujo de emisión o verificación.
///
/// Crear vía [DidCommService.startFlowSession] o
/// [DidCommService.acceptInvitationWithFlowSession]. Cerrar siempre con
/// [dispose] al terminar el flujo o al abandonar la pantalla.
class DidCommFlowSession {
  DidCommFlowSession({
    required ConnectionRecord connection,
    required WsConnection webSocket,
    required KeyRecord ed25519Key,
    this.serviceEndpoint,
  })  : _connection = connection,
        _webSocket = webSocket,
        _ed25519Key = ed25519Key {
    _subscription = _webSocket.messages.listen(
      _onRawMessage,
      onError: (Object error, _) => _emit(DidCommFlowError(error)),
      onDone: () => _emit(DidCommFlowClosed()),
    );
  }

  final ConnectionRecord _connection;
  final WsConnection _webSocket;
  final KeyRecord _ed25519Key;

  final _events = StreamController<DidCommFlowEvent>.broadcast();
  StreamSubscription<String>? _subscription;
  var _disposed = false;

  /// Conexión DIDComm asociada a esta sesión.
  ConnectionRecord get connection => _connection;

  /// WebSocket activo hacia el agente remoto.
  WsConnection get webSocket => _webSocket;

  /// Endpoint HTTP DIDComm del emisor (del OOB).
  final String? serviceEndpoint;

  /// Eventos de protocolo desencriptados (offer, request-presentation, etc.).
  Stream<DidCommFlowEvent> get events => _events.stream;

  Future<void> _onRawMessage(String encryptedJson) async {
    if (_disposed) return;
    try {
      final envelope = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final message = await DidCommEnvelopeV1.unpack(
        envelope: envelope,
        recipientEd25519PrivateJwk: _ed25519Key.privateJwk!,
        recipientEd25519PublicJwk: _ed25519Key.publicJwk,
      );
      _emit(DidCommMessageRouter.toEvent(message));
    } catch (e) {
      _emit(DidCommFlowError(e));
    }
  }

  void _emit(DidCommFlowEvent event) {
    if (_disposed || _events.isClosed) return;
    _events.add(event);
  }

  /// Cierra el WebSocket y el stream de eventos.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    await _webSocket.close();
    if (!_events.isClosed) {
      await _events.close();
    }
  }
}
