import 'dart:typed_data';

import 'package:pointycastle/export.dart' as pc;

import '../utils/base64_utils.dart';
import '../utils/multibase.dart';

/// Soporte para el método DID `did:key`.
///
/// Genera y resuelve DIDs a partir de claves criptográficas sin acceso a red.
/// - Ed25519 → `did:key:z6Mk...`
/// - P-256   → `did:key:zDn...`
///
/// Codificación: multicodec varint + raw key bytes → base58btc → prefijo `z`.
class DidKey {
  /// Prefijo multicodec varint para ed25519-pub (0xed en varint = 0xed, 0x01).
  static const _ed25519Prefix = [0xed, 0x01];

  /// Prefijo multicodec varint para p256-pub (0x1200 en varint = 0x80, 0x24).
  static const _p256Prefix = [0x80, 0x24];

  /// Genera un `did:key` a partir de un JWK de clave pública.
  ///
  /// Soporta `kty=OKP crv=Ed25519` y `kty=EC crv=P-256`.
  /// Lanza [UnsupportedError] para otros tipos.
  static String fromPublicJwk(Map<String, dynamic> publicJwk) {
    final kty = publicJwk['kty'] as String;
    final crv = publicJwk['crv'] as String?;

    if (kty == 'OKP' && crv == 'Ed25519') return _fromEd25519(publicJwk);
    if (kty == 'EC' && crv == 'P-256') return _fromP256(publicJwk);

    throw UnsupportedError('did:key no soportado para kty=$kty crv=$crv');
  }

  /// Resuelve un `did:key` a su DID Document sin acceso a red.
  ///
  /// Lanza [FormatException] si [did] no es un `did:key` válido.
  static Map<String, dynamic> resolve(String did) {
    if (!did.startsWith('did:key:z')) {
      throw FormatException('did:key inválido: $did');
    }

    final multibaseKey = did.substring('did:key:'.length);
    final decoded = decodeBase58Btc(multibaseKey.substring(1)); // quitar 'z'

    if (decoded[0] == 0xed && decoded[1] == 0x01) {
      return _resolveEd25519(did, multibaseKey, decoded.sublist(2));
    }
    if (decoded[0] == 0x80 && decoded[1] == 0x24) {
      return _resolveP256(did, multibaseKey, decoded.sublist(2));
    }

    throw UnsupportedError('Prefijo multicodec desconocido en did:key: ${decoded[0]}, ${decoded[1]}');
  }

  // — generación —

  static String _fromEd25519(Map<String, dynamic> jwk) {
    final xBytes = base64UrlDecode(jwk['x'] as String);
    final prefixed = Uint8List.fromList([..._ed25519Prefix, ...xBytes]);
    return 'did:key:z${encodeBase58Btc(prefixed)}';
  }

  static String _fromP256(Map<String, dynamic> jwk) {
    final xBytes = base64UrlDecode(jwk['x'] as String);
    final yBytes = base64UrlDecode(jwk['y'] as String);
    // punto comprimido: 0x02 si y es par, 0x03 si y es impar
    final prefix = (yBytes.last & 1) == 0 ? 0x02 : 0x03;
    final compressed = Uint8List.fromList([prefix, ...xBytes]);
    final prefixed = Uint8List.fromList([..._p256Prefix, ...compressed]);
    return 'did:key:z${encodeBase58Btc(prefixed)}';
  }

  // — resolución —

  static Map<String, dynamic> _resolveEd25519(
    String did,
    String multibaseKey,
    Uint8List rawKey,
  ) {
    final vmId = '$did#$multibaseKey';
    return _buildDocument(
      did: did,
      vmId: vmId,
      publicKeyJwk: {
        'kty': 'OKP',
        'crv': 'Ed25519',
        'x': base64UrlEncode(rawKey),
      },
    );
  }

  static Map<String, dynamic> _resolveP256(
    String did,
    String multibaseKey,
    Uint8List compressedKey,
  ) {
    final vmId = '$did#$multibaseKey';

    // Descomprimir el punto P-256 usando pointycastle para recuperar x e y.
    final domain = pc.ECDomainParameters('prime256v1');
    final point = domain.curve.decodePoint(compressedKey.toList())!;
    final xBytes = _bigIntToFixed32(point.x!.toBigInteger()!);
    final yBytes = _bigIntToFixed32(point.y!.toBigInteger()!);

    return _buildDocument(
      did: did,
      vmId: vmId,
      publicKeyJwk: {
        'kty': 'EC',
        'crv': 'P-256',
        'x': base64UrlEncode(xBytes),
        'y': base64UrlEncode(yBytes),
      },
    );
  }

  static Map<String, dynamic> _buildDocument({
    required String did,
    required String vmId,
    required Map<String, dynamic> publicKeyJwk,
  }) {
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
          'publicKeyJwk': publicKeyJwk,
        },
      ],
      'authentication': [vmId],
      'assertionMethod': [vmId],
      'capabilityInvocation': [vmId],
      'capabilityDelegation': [vmId],
    };
  }

  /// Convierte un [BigInt] a un buffer big-endian de exactamente 32 bytes.
  static Uint8List _bigIntToFixed32(BigInt value) {
    final hex = value.toRadixString(16).padLeft(64, '0');
    final result = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}
