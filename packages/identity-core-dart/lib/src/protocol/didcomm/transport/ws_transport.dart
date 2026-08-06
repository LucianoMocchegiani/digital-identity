import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Conexión WebSocket DIDComm v1 activa hacia el endpoint del agente remoto.
///
/// Mantiene el canal abierto para recibir varios mensajes envelope durante un
/// flujo (emisión o verificación). Cerrar con [close] al terminar el flujo.
class WsConnection {
  WsConnection._({
    required WebSocketChannel channel,
    required StreamController<String> controller,
  })  : _channel = channel,
        _controller = controller;

  final WebSocketChannel _channel;
  final StreamController<String> _controller;
  var _closed = false;

  /// Stream de mensajes envelope JSON (texto) recibidos por el socket.
  Stream<String> get messages => _controller.stream;

  /// Abre WebSocket contra [httpEndpoint] (HTTP(S) del OOB → WS equivalente).
  static Future<WsConnection> connect(String httpEndpoint) async {
    final channel = WebSocketChannel.connect(
      WsTransport.httpEndpointToWs(httpEndpoint),
    );
    final controller = StreamController<String>.broadcast();
    final connection = WsConnection._(channel: channel, controller: controller);

    channel.stream.listen(
      (event) {
        final text = WsTransport.normalizeMessage(event);
        if (text != null && text.isNotEmpty) {
          controller.add(text);
        }
      },
      onError: (Object error, _) {
        connection._markClosed();
        if (!controller.isClosed) controller.addError(error);
      },
      onDone: () {
        connection._markClosed();
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return connection;
  }

  /// Marca la conexión como cerrada (remoto o local) sin cerrar el sink dos veces.
  void _markClosed() {
    _closed = true;
  }

  /// Espera el primer mensaje o retorna `null` si vence [timeout] o el socket cierra.
  Future<String?> receiveFirst({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      return await messages.first.timeout(timeout);
    } on TimeoutException {
      return null;
    } on StateError {
      // Stream cerrado sin emitir ningún frame (WS sin mensajes inbound).
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Envía un frame texto (envelope JSON) al agente remoto.
  Future<void> send(String message) async {
    if (_closed) {
      throw StateError('WebSocket cerrado.');
    }
    _channel.sink.add(message);
  }

  /// Indica si el socket sigue usable para envío.
  bool get isOpen => !_closed;

  /// Cierra el socket y el stream de mensajes.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _channel.sink.close();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

/// Cliente WebSocket DIDComm v1 (mensajes JSON envelope).
class WsTransport {
  const WsTransport();

  /// Convierte endpoint HTTP(S) del OOB a URI WebSocket equivalente.
  static Uri httpEndpointToWs(String httpEndpoint) {
    final uri = Uri.parse(httpEndpoint);
    final scheme = switch (uri.scheme) {
      'https' => 'wss',
      'http' => 'ws',
      'wss' || 'ws' => uri.scheme,
      _ => throw ArgumentError('Esquema no soportado: ${uri.scheme}'),
    };
    return uri.replace(scheme: scheme);
  }

  /// Normaliza un frame WebSocket a texto envelope JSON.
  static String? normalizeMessage(Object? message) {
    if (message is String) {
      return message.isEmpty ? null : message;
    }
    if (message is List<int>) {
      final text = utf8.decode(message);
      return text.isEmpty ? null : text;
    }
    final text = message?.toString();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  /// Abre WS, escucha el primer mensaje y cierra (handshake legacy).
  Future<String?> receiveFirstMessage({
    required String httpEndpoint,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final connection = await WsConnection.connect(httpEndpoint);
    try {
      return await connection.receiveFirst(timeout: timeout);
    } finally {
      await connection.close();
    }
  }
}
