import 'dart:convert';

import '../../did/did_peer.dart';
import '../../utils/base64_utils.dart';

/// Extrae el DID Document del emisor desde un `didexchange/response`.
abstract final class DidExchangeResponseParser {
  /// Resuelve el documento DID del issuer a partir del mensaje de respuesta.
  static Map<String, dynamic>? resolveDidDocument(Map<String, dynamic> message) {
    final fromAttach = _didDocFromAttachment(message);
    if (fromAttach != null) return fromAttach;

    final theirDid = message['did'] as String?;
    if (theirDid != null && theirDid.startsWith('did:peer:')) {
      try {
        return DidPeer.resolve(theirDid);
      } catch (_) {}
    }

    return null;
  }

  static Map<String, dynamic>? _didDocFromAttachment(
    Map<String, dynamic> message,
  ) {
    final attach = message['did_doc~attach'] ?? message['didDoc'];
    if (attach is! Map<String, dynamic>) return null;

    final data = attach['data'] as Map<String, dynamic>?;
    if (data == null) return null;

    final json = data['json'];
    if (json is Map<String, dynamic>) return json;

    final encoded = data['base64'] as String?;
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = utf8.decode(base64UrlDecode(encoded));
      final parsed = jsonDecode(decoded);
      return parsed is Map<String, dynamic> ? parsed : null;
    } catch (_) {
      try {
        final decoded = utf8.decode(base64.decode(encoded));
        final parsed = jsonDecode(decoded);
        return parsed is Map<String, dynamic> ? parsed : null;
      } catch (_) {
        return null;
      }
    }
  }
}
