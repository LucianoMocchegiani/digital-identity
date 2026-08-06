import 'dart:convert';

import '../../../utils/base64_utils.dart';

/// Parsea invitaciones OOB DIDComm desde URLs o JSON directo.
///
/// Soporta:
/// - `?oob=base64url(json)` — formato DIDComm OOB estándar (RFC 0434).
/// - `?c_i=base64url(json)` — formato legacy Aries connect invitation.
/// - `didcomm://` sin params — intenta parsear el path como base64url.
/// - JSON directo (si [url] comienza con `{`).
abstract final class OobParser {
  /// Parsea [url] y retorna el payload JSON de la invitación, o `null` si no
  /// se puede extraer un payload reconocible.
  static Map<String, dynamic>? parse(String url) {
    final trimmed = url.trim();

    // JSON directo
    if (trimmed.startsWith('{')) {
      try {
        return jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {}
    }

    final Uri parsed;
    try {
      parsed = Uri.parse(
        trimmed.replaceFirst('didcomm://', 'https://didcomm/'),
      );
    } on FormatException {
      return null;
    }

    final params = parsed.queryParameters;

    if (params.containsKey('oob')) {
      final result = _decodeBase64Json(params['oob']!);
      if (result != null) return result;
    }

    if (params.containsKey('c_i')) {
      final result = _decodeBase64Json(params['c_i']!);
      if (result != null) return result;
    }

    return null;
  }

  /// Extrae la URL del service endpoint del payload de la invitación.
  static String? extractServiceEndpoint(Map<String, dynamic> invitation) {
    final services = invitation['services'] as List?;
    if (services != null && services.isNotEmpty) {
      final service = services.first as Map<String, dynamic>?;
      return service?['serviceEndpoint'] as String?;
    }
    return null;
  }

  /// Extrae las claves de destinatario (did:key / did:peer) de la invitación.
  ///
  /// Usadas para encriptar la respuesta al invitador.
  static List<String> extractRecipientKeys(Map<String, dynamic> invitation) {
    final services = invitation['services'] as List?;
    if (services != null && services.isNotEmpty) {
      final service = services.first as Map<String, dynamic>?;
      final keys = service?['recipientKeys'] as List?;
      if (keys != null) return keys.cast<String>();
    }
    final from = invitation['from'] as String?;
    if (from != null) return [from];
    return [];
  }

  static Map<String, dynamic>? _decodeBase64Json(String b64) {
    try {
      final decoded = utf8.decode(base64UrlDecode(b64));
      final json = jsonDecode(decoded);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }
}
