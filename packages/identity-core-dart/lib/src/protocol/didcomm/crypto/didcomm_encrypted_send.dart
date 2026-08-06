import 'dart:convert';

import '../../../record/models/key_record.dart';
import '../transport/http_transport.dart';
import '../transport/ws_transport.dart';
import 'didcomm_envelope_v1.dart';

/// Envía mensajes DIDComm cifrados (Authcrypt V1) al agente remoto.
abstract final class DidCommEncryptedSend {
  /// Empaqueta [message] y lo envía cifrado para [recipientKeyDid].
  ///
  /// Si [deliverViaWebSocket] es `true` y [webSocket] está activo, envía por WS
  /// (Credo asocia la sesión inbound para mensajes posteriores).
  /// Si no, usa HTTP POST a [endpoint].
  static Future<String?> send({
    required Map<String, dynamic> message,
    required String recipientKeyDid,
    required String endpoint,
    required KeyRecord senderKey,
    required HttpTransport transport,
    WsConnection? webSocket,
    bool deliverViaWebSocket = false,
  }) async {
    final envelope = await _packEnvelope(
      message: message,
      recipientKeyDid: recipientKeyDid,
      senderKey: senderKey,
    );

    if (deliverViaWebSocket && webSocket != null && webSocket.isOpen) {
      try {
        await webSocket.send(jsonEncode(envelope));
        return null;
      } catch (_) {
        // WS caído a mitad de flujo: reintentar por HTTP.
      }
    }

    return transport.sendEncrypted(endpoint: endpoint, envelope: envelope);
  }

  static Future<Map<String, dynamic>> _packEnvelope({
    required Map<String, dynamic> message,
    required String recipientKeyDid,
    required KeyRecord senderKey,
  }) async {
    final recipientEd25519 =
        DidCommEnvelopeV1.ed25519PublicKeyBytesFromDid(recipientKeyDid);
    if (recipientEd25519 == null) {
      throw StateError(
        'No se pudo extraer clave Ed25519 del recipientKey: $recipientKeyDid',
      );
    }

    return DidCommEnvelopeV1.packAuthcrypt(
      message: message,
      recipientEd25519PublicKey: recipientEd25519,
      senderEd25519PrivateJwk: senderKey.privateJwk!,
      senderEd25519PublicJwk: senderKey.publicJwk,
    );
  }
}
