import 'dart:convert';

import '../../../utils/base64_utils.dart';

/// Utilidades para adjuntos de presentación en mensajes DIDComm v2 (RFC 0037).
abstract final class DidCommProofAttach {
  /// Lee adjuntos `request_presentations~attach` de un `request-presentation`.
  static List<Map<String, dynamic>> listFromMessage(
    Map<String, dynamic> message,
  ) {
    final raw = message['request_presentations~attach'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  /// Decodifica el payload JSON de un adjunto DIDComm.
  static Map<String, dynamic>? jsonFromAttach(Map<String, dynamic>? attach) {
    if (attach == null) return null;

    final data = attach['data'];
    if (data is! Map) return null;

    final json = data['json'];
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);

    final encoded = data['base64'] as String?;
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = utf8.decode(base64UrlDecode(encoded));
      final parsed = jsonDecode(decoded);
      return parsed is Map<String, dynamic>
          ? parsed
          : parsed is Map
              ? Map<String, dynamic>.from(parsed)
              : null;
    } catch (_) {
      try {
        final decoded = utf8.decode(base64.decode(encoded));
        final parsed = jsonDecode(decoded);
        return parsed is Map<String, dynamic>
            ? parsed
            : parsed is Map
                ? Map<String, dynamic>.from(parsed)
                : null;
      } catch (_) {
        return null;
      }
    }
  }

  /// Extrae la Presentation Definition del primer adjunto del request.
  static Map<String, dynamic>? presentationDefinitionFromMessage(
    Map<String, dynamic> message,
  ) {
    final attaches = listFromMessage(message);
    if (attaches.isEmpty) return null;
    final payload = jsonFromAttach(attaches.first);
    if (payload == null) return null;

    final pd = payload['presentation_definition'];
    if (pd is Map<String, dynamic>) return pd;
    if (pd is Map) return Map<String, dynamic>.from(pd);

    final pex = payload['presentationExchange'] as Map?;
    if (pex != null) {
      final nested = pex['presentation_definition'];
      if (nested is Map<String, dynamic>) return nested;
      if (nested is Map) return Map<String, dynamic>.from(nested);
    }

    return null;
  }

  /// Challenge del verifier (requerido para LDP `authentication`).
  static String? challengeFromMessage(Map<String, dynamic> message) {
    final attaches = listFromMessage(message);
    if (attaches.isEmpty) return null;
    final payload = jsonFromAttach(attaches.first);
    if (payload == null) return null;

    final options = payload['options'];
    if (options is Map) {
      final challenge = options['challenge'];
      if (challenge is String && challenge.isNotEmpty) return challenge;
    }

    final pex = payload['presentationExchange'] as Map?;
    final pexOptions = pex?['options'];
    if (pexOptions is Map) {
      final challenge = pexOptions['challenge'];
      if (challenge is String && challenge.isNotEmpty) return challenge;
    }

    return null;
  }
}
