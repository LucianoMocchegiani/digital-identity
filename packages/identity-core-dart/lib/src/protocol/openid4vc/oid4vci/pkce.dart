import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Genera un `code_verifier` PKCE (43–128 caracteres, base64url).
String generateOid4VciCodeVerifier() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Calcula `code_challenge` con método S256.
String computeOid4VciCodeChallenge(String verifier) {
  final digest = sha256.convert(utf8.encode(verifier));
  return base64Url.encode(digest.bytes).replaceAll('=', '');
}

/// Genera un parámetro `state` OAuth aleatorio.
String generateOid4VciState() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}
