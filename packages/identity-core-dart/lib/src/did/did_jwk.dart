import 'dart:convert';
import 'dart:typed_data';

import '../utils/base64_utils.dart';

/// Soporte para el método DID `did:jwk`.
///
/// El DID se construye codificando el JWK público en base64url sin padding:
/// `did:jwk:<base64url(JSON(publicJwk))>`
///
/// La resolución es local: se decodifica el identificador y se construye
/// el DID Document directamente sin acceso a red.
class DidJwk {
  /// Genera un `did:jwk` a partir de un JWK de clave pública.
  static String fromPublicJwk(Map<String, dynamic> publicJwk) {
    final jsonBytes = utf8.encode(jsonEncode(publicJwk));
    final encoded = base64UrlEncode(Uint8List.fromList(jsonBytes));
    return 'did:jwk:$encoded';
  }

  /// Resuelve un `did:jwk` a su DID Document sin acceso a red.
  ///
  /// Lanza [FormatException] si [did] no tiene el prefijo `did:jwk:`.
  static Map<String, dynamic> resolve(String did) {
    if (!did.startsWith('did:jwk:')) {
      throw FormatException('did:jwk inválido: $did');
    }

    final encoded = did.substring('did:jwk:'.length);
    final jsonBytes = base64UrlDecode(encoded);
    final publicJwk = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;

    const vmFragment = '#0';
    final vmId = '$did$vmFragment';

    return {
      '@context': [
        'https://www.w3.org/ns/did/v1',
        'https://w3id.org/security/suites/jws-2020/v1',
      ],
      'id': did,
      'verificationMethod': [
        {
          'id': vmId,
          'type': 'JsonWebKey2020',
          'controller': did,
          'publicKeyJwk': publicJwk,
        },
      ],
      'authentication': [vmId],
      'assertionMethod': [vmId],
      'capabilityInvocation': [vmId],
      'capabilityDelegation': [vmId],
    };
  }
}
