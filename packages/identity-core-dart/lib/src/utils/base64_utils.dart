import 'dart:convert';
import 'dart:typed_data';

/// Codifica [bytes] en base64url sin padding (formato estándar para JWT y JWK).
String base64UrlEncode(Uint8List bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// Decodifica una cadena base64url (con o sin padding) a [Uint8List].
Uint8List base64UrlDecode(String input) {
  final normalized = base64.normalize(input);
  return base64Url.decode(normalized);
}
