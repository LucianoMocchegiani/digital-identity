import 'dart:convert';
import 'dart:typed_data';

import '../../../kms/kms_service.dart';
import '../../../record/models/key_record.dart';
import '../../../utils/base64_utils.dart';

/// Construye un JWT de proof of possession (holder binding) para el credential request.
///
/// El JWT sigue el formato definido en OID4VCI. Para issuers EUDI (ES256 / P-256)
/// el JWK público va en el **header** del proof; en otros casos se usa `kid` + `iss`.
Future<String> buildCredentialProof({
  required String holderDid,
  required String verificationMethodId,
  required KeyRecord signingKey,
  required KmsService kms,
  required String issuerUrl,
  required String cNonce,
}) async {
  final alg = _algorithmForKey(signingKey.keyType);
  final useJwkInHeader = signingKey.keyType == KeyType.p256;

  final header = <String, dynamic>{
    'alg': alg,
    'typ': 'openid4vci-proof+jwt',
    if (useJwkInHeader) 'jwk': signingKey.publicJwk else 'kid': verificationMethodId,
  };

  final normalizedAud = issuerUrl.replaceAll(RegExp(r'/+$'), '');
  final payload = <String, dynamic>{
    'aud': normalizedAud,
    'iat': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    if (!useJwkInHeader) 'iss': holderDid,
    if (cNonce.isNotEmpty) 'nonce': cNonce,
  };

  return _signJwt(header: header, payload: payload, key: signingKey, kms: kms);
}

/// Construye y firma un JWT con [kms] usando la clave [key].
///
/// El signing input es `base64url(header).base64url(payload)`.
/// La firma se codifica en base64url sin padding.
Future<String> _signJwt({
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

  final sigB64 = base64UrlEncode(signature);
  return '$signingInput.$sigB64';
}

/// Retorna el identificador de algoritmo JWT para [keyType].
String _algorithmForKey(KeyType keyType) {
  return switch (keyType) {
    KeyType.p256 => 'ES256',
    KeyType.ed25519 => 'EdDSA',
    KeyType.x25519 => throw UnsupportedError('x25519 cannot be used for signing'),
  };
}
