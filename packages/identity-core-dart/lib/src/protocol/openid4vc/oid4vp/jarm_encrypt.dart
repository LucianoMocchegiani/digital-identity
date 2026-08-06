import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart' as pc;

import '../../../utils/base64_utils.dart';

/// Cifrado JARM (OID4VP §8.3) para `response_mode: direct_post.jwt`.
abstract final class JarmEncrypt {
  static final _aesGcm128 = AesGcm.with128bits();
  static final _sha256 = Sha256();

  /// Primera JWK de cifrado compatible (prioriza P-256 + ECDH-ES).
  static Map<String, dynamic>? pickEncryptionJwk(
    Map<String, dynamic>? clientMetadata,
  ) {
    final jwks = clientMetadata?['jwks'];
    if (jwks is! Map) return null;

    final keys = jwks['keys'];
    if (keys is! List) return null;

    Map<String, dynamic>? fallback;
    for (final key in keys) {
      if (key is! Map) continue;
      final map = Map<String, dynamic>.from(key);
      final use = map['use'] as String?;
      final alg = map['alg'] as String?;
      final crv = map['crv'] as String?;
      if (use != null && use != 'enc') continue;
      if (alg != null && alg != 'ECDH-ES') continue;
      if (crv == 'P-256') return map;
      fallback ??= map;
    }
    return fallback;
  }

  /// Cifra [payload] como JWE compacto para el parámetro `response`.
  static Future<String> encryptAuthorizationResponse({
    required Map<String, dynamic> payload,
    required Map<String, dynamic> recipientJwk,
    String enc = 'A128GCM',
    String? apv,
  }) async {
    if (enc != 'A128GCM') {
      throw UnsupportedError('Solo se soporta enc=A128GCM ($enc).');
    }
    if (recipientJwk['crv'] != 'P-256') {
      throw UnsupportedError(
        'Solo se soporta crv=P-256 para JARM (${recipientJwk['crv']}).',
      );
    }

    final ephemeral = _generateEphemeralP256();
    final sharedSecret = _ecdhP256(
      ephemeralPrivateJwk: ephemeral.privateJwk,
      recipientPublicJwk: recipientJwk,
    );

    final apu = Uint8List(0);
    final apvBytes =
        apv != null ? Uint8List.fromList(utf8.encode(apv)) : Uint8List(0);
    final cek = await _concatKdf(
      sharedSecret: sharedSecret,
      algorithm: enc,
      apu: apu,
      apv: apvBytes,
      keydatalen: 128,
    );

    final header = <String, dynamic>{
      'alg': 'ECDH-ES',
      'enc': enc,
      if (recipientJwk['kid'] != null) 'kid': recipientJwk['kid'],
      'epk': <String, dynamic>{
        'kty': 'EC',
        'crv': 'P-256',
        'x': ephemeral.publicJwk['x'],
        'y': ephemeral.publicJwk['y'],
      },
      if (apv != null) 'apv': base64UrlEncode(apvBytes),
    };

    final protectedB64 = base64UrlEncode(
      Uint8List.fromList(utf8.encode(jsonEncode(header))),
    );
    final aad = Uint8List.fromList(ascii.encode(protectedB64));

    final iv = _randomBytes(12);
    final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    final secretBox = await _aesGcm128.encrypt(
      plaintext,
      secretKey: SecretKeyData(cek),
      nonce: iv,
      aad: aad,
    );

    return [
      protectedB64,
      '',
      base64UrlEncode(iv),
      base64UrlEncode(Uint8List.fromList(secretBox.cipherText)),
      base64UrlEncode(Uint8List.fromList(secretBox.mac.bytes)),
    ].join('.');
  }

  static _EphemeralKeyPair _generateEphemeralP256() {
    final ecParams = pc.ECDomainParameters('prime256v1');
    final random = pc.FortunaRandom()
      ..seed(
        pc.KeyParameter(
          Uint8List.fromList(
            List.generate(32, (_) => Random.secure().nextInt(256)),
          ),
        ),
      );

    final keyGen = pc.ECKeyGenerator()
      ..init(
        pc.ParametersWithRandom(pc.ECKeyGeneratorParameters(ecParams), random),
      );

    final pair = keyGen.generateKeyPair();
    final priv = pair.privateKey as pc.ECPrivateKey;
    final q = (pair.publicKey as pc.ECPublicKey).Q!;

    final publicJwk = <String, dynamic>{
      'kty': 'EC',
      'crv': 'P-256',
      'x': base64UrlEncode(_bigIntToBytes(q.x!.toBigInteger()!, 32)),
      'y': base64UrlEncode(_bigIntToBytes(q.y!.toBigInteger()!, 32)),
    };
    return _EphemeralKeyPair(
      publicJwk: publicJwk,
      privateJwk: <String, dynamic>{
        ...publicJwk,
        'd': base64UrlEncode(_bigIntToBytes(priv.d!, 32)),
      },
    );
  }

  static Uint8List _ecdhP256({
    required Map<String, dynamic> ephemeralPrivateJwk,
    required Map<String, dynamic> recipientPublicJwk,
  }) {
    final ecParams = pc.ECDomainParameters('prime256v1');
    final d = _bytesToBigInt(
      base64UrlDecode(ephemeralPrivateJwk['d'] as String),
    );
    final ephemeralPrivate = pc.ECPrivateKey(d, ecParams);

    final rx = _bytesToBigInt(base64UrlDecode(recipientPublicJwk['x'] as String));
    final ry = _bytesToBigInt(base64UrlDecode(recipientPublicJwk['y'] as String));
    final recipientPublic = pc.ECPublicKey(
      ecParams.curve.createPoint(rx, ry),
      ecParams,
    );

    final agreement = pc.ECDHBasicAgreement()..init(ephemeralPrivate);
    return _bigIntToBytes(agreement.calculateAgreement(recipientPublic), 32);
  }

  static Future<Uint8List> _concatKdf({
    required Uint8List sharedSecret,
    required String algorithm,
    required Uint8List apu,
    required Uint8List apv,
    required int keydatalen,
  }) async {
    final algBytes = utf8.encode(algorithm);
    final input = <int>[
      0, 0, 0, 1,
      ...sharedSecret,
      ..._uint32Be(algBytes.length), ...algBytes,
      ..._uint32Be(apu.length), ...apu,
      ..._uint32Be(apv.length), ...apv,
      ..._uint32Be(keydatalen),
    ];
    final hash = await _sha256.hash(input);
    return Uint8List.fromList(hash.bytes.sublist(0, keydatalen ~/ 8));
  }

  static List<int> _uint32Be(int value) => [
        (value >> 24) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ];

  static Uint8List _bigIntToBytes(BigInt n, int length) {
    final bytes = Uint8List(length);
    var temp = n;
    for (var i = length - 1; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final b in bytes) {
      result = (result << 8) | BigInt.from(b);
    }
    return result;
  }

  static Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List.generate(length, (_) => Random.secure().nextInt(256)),
    );
  }
}

class _EphemeralKeyPair {
  const _EphemeralKeyPair({required this.publicJwk, required this.privateJwk});

  final Map<String, dynamic> publicJwk;
  final Map<String, dynamic> privateJwk;
}
