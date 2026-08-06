import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../kms/kms_service.dart';
import '../record/models/key_record.dart';
import '../utils/base64_utils.dart';

/// Construye Key Binding JWTs (kb+jwt) para OID4VP con SD-JWT.
///
/// El kb-JWT prueba que el presentador controla la clave indicada en el claim
/// `cnf` del SD-JWT emisor. Se agrega al final del SD-JWT presentado.
class HolderBinding {
  static final _sha256 = Sha256();

  /// Construye y firma el kb-JWT para una presentación SD-JWT.
  ///
  /// [audience] es el `client_id` del verifier.
  /// [nonce] viene del authorization request del verifier.
  /// [sdJwtPresented] es el SD-JWT construido (sin kb-JWT, con `~` final).
  ///
  /// El claim `sd_hash` es el SHA-256 de [sdJwtPresented] en base64url,
  /// comprometiendo el presentador a los disclosures seleccionados.
  static Future<String> buildKeyBindingJwt({
    required String audience,
    required String nonce,
    required String sdJwtPresented,
    required KmsService kms,
    required KeyRecord signingKey,
    required String verificationMethodId,
  }) async {
    final sdHash = await _computeSdHash(sdJwtPresented);
    final alg = _algorithmForKey(signingKey.keyType);

    final header = <String, dynamic>{
      'alg': alg,
      'typ': 'kb+jwt',
      if (signingKey.keyType == KeyType.p256) 'jwk': signingKey.publicJwk,
    };

    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final payload = <String, dynamic>{
      'iat': now,
      'aud': audience,
      'nonce': nonce,
      'sd_hash': sdHash,
    };

    return _buildSignedJwt(header: header, payload: payload, key: signingKey, kms: kms);
  }

  /// Comprueba si un [SdJwtToken] requiere holder binding (tiene claim `cnf`).
  static bool requiresHolderBinding(Map<String, dynamic> payload) {
    return payload.containsKey('cnf');
  }

  // — helpers privados —

  static Future<String> _computeSdHash(String sdJwtPresented) async {
    final inputBytes = Uint8List.fromList(utf8.encode(sdJwtPresented));
    final hash = await _sha256.hash(inputBytes);
    return base64UrlEncode(Uint8List.fromList(hash.bytes));
  }

  static Future<String> _buildSignedJwt({
    required Map<String, dynamic> header,
    required Map<String, dynamic> payload,
    required KeyRecord key,
    required KmsService kms,
  }) async {
    final headerB64 = base64UrlEncode(
      Uint8List.fromList(utf8.encode(jsonEncode(header))),
    );
    final payloadB64 = base64UrlEncode(
      Uint8List.fromList(utf8.encode(jsonEncode(payload))),
    );

    final signingInput = '$headerB64.$payloadB64';
    final signature = await kms.sign(
      key: key,
      payload: Uint8List.fromList(utf8.encode(signingInput)),
    );

    return '$signingInput.${base64UrlEncode(signature)}';
  }

  static String _algorithmForKey(KeyType keyType) {
    return switch (keyType) {
      KeyType.p256 => 'ES256',
      KeyType.ed25519 => 'EdDSA',
      KeyType.x25519 => throw UnsupportedError('x25519 cannot be used for signing'),
    };
  }
}
