import 'dart:math' show Random;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:uuid/uuid.dart';

import '../record/models/key_record.dart';
import '../utils/base64_utils.dart';
import 'kms_service.dart';

/// Implementación software de [KmsService].
///
/// Ed25519/X25519 usan el paquete `cryptography` (pure Dart, funciona en Android/iOS).
/// P-256 usa `pointycastle` porque `DartEcdsa` del paquete `cryptography` no implementa
/// ni `newKeyPair()` ni `sign()` en Android (lanza UnimplementedError).
class SoftwareKms implements KmsService {
  static const _uuid = Uuid();
  static final _ed25519 = Ed25519();
  static final _x25519 = X25519();

  @override
  Future<KeyRecord> generateKey(KeyType keyType) async {
    return switch (keyType) {
      KeyType.ed25519 => _generateEd25519(),
      KeyType.p256 => _generateP256(),
      KeyType.x25519 => _generateX25519(),
    };
  }

  @override
  Future<Uint8List> sign({
    required KeyRecord key,
    required Uint8List payload,
  }) async {
    if (key.isHardwareBacked) {
      throw UnsupportedError(
        'SoftwareKms no puede firmar con claves hardware-backed. '
        'Usar HardwareKmsService (Fase 8).',
      );
    }
    if (key.privateJwk == null) {
      throw ArgumentError('KeyRecord.privateJwk es null', 'key');
    }

    return switch (key.keyType) {
      KeyType.ed25519 => _signEd25519(key.privateJwk!, payload),
      KeyType.p256 => _signP256(key.privateJwk!, payload),
      KeyType.x25519 => throw UnsupportedError(
          'X25519 no soporta firma. Usar Ed25519 o P-256.',
        ),
    };
  }

  // — Ed25519 —

  Future<KeyRecord> _generateEd25519() async {
    final keyPair = await _ed25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateData = await keyPair.extract();

    final xBytes = Uint8List.fromList(publicKey.bytes);
    final dBytes = Uint8List.fromList(privateData.bytes);

    final publicJwk = <String, dynamic>{
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(xBytes),
    };
    final privateJwk = <String, dynamic>{
      ...publicJwk,
      'd': base64UrlEncode(dBytes),
    };

    return KeyRecord(
      keyId: _uuid.v4(),
      keyType: KeyType.ed25519,
      publicJwk: publicJwk,
      privateJwk: privateJwk,
      isHardwareBacked: false,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Future<Uint8List> _signEd25519(
    Map<String, dynamic> privateJwk,
    Uint8List payload,
  ) async {
    final keyPair = SimpleKeyPairData(
      base64UrlDecode(privateJwk['d'] as String).toList(),
      publicKey: SimplePublicKey(
        base64UrlDecode(privateJwk['x'] as String).toList(),
        type: KeyPairType.ed25519,
      ),
      type: KeyPairType.ed25519,
    );
    final signature = await _ed25519.sign(payload, keyPair: keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  // — X25519 —

  Future<KeyRecord> _generateX25519() async {
    final keyPair = await _x25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateData = await keyPair.extract();

    final xBytes = Uint8List.fromList(publicKey.bytes);
    final dBytes = Uint8List.fromList(privateData.bytes);

    final publicJwk = <String, dynamic>{
      'kty': 'OKP',
      'crv': 'X25519',
      'x': base64UrlEncode(xBytes),
    };
    final privateJwk = <String, dynamic>{
      ...publicJwk,
      'd': base64UrlEncode(dBytes),
    };

    return KeyRecord(
      keyId: _uuid.v4(),
      keyType: KeyType.x25519,
      publicJwk: publicJwk,
      privateJwk: privateJwk,
      isHardwareBacked: false,
      createdAt: DateTime.now().toUtc(),
    );
  }

  // — P-256 (pointycastle — DartEcdsa no implementado en Android) —

  Future<KeyRecord> _generateP256() async {
    final ecParams = pc.ECDomainParameters('prime256v1');

    final random = pc.FortunaRandom()
      ..seed(pc.KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => Random.secure().nextInt(256))),
      ));

    final keyGen = pc.ECKeyGenerator()
      ..init(pc.ParametersWithRandom(pc.ECKeyGeneratorParameters(ecParams), random));

    final pair = keyGen.generateKeyPair();
    final priv = pair.privateKey as pc.ECPrivateKey;
    final Q = (pair.publicKey as pc.ECPublicKey).Q!;

    final xBytes = _bigIntToBytes(Q.x!.toBigInteger()!, 32);
    final yBytes = _bigIntToBytes(Q.y!.toBigInteger()!, 32);
    final dBytes = _bigIntToBytes(priv.d!, 32);

    final publicJwk = <String, dynamic>{
      'kty': 'EC',
      'crv': 'P-256',
      'x': base64UrlEncode(xBytes),
      'y': base64UrlEncode(yBytes),
    };
    final privateJwk = <String, dynamic>{
      ...publicJwk,
      'd': base64UrlEncode(dBytes),
    };

    return KeyRecord(
      keyId: _uuid.v4(),
      keyType: KeyType.p256,
      publicJwk: publicJwk,
      privateJwk: privateJwk,
      isHardwareBacked: false,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Future<Uint8List> _signP256(
    Map<String, dynamic> privateJwk,
    Uint8List payload,
  ) async {
    final ecParams = pc.ECDomainParameters('prime256v1');
    final d = _bytesToBigInt(base64UrlDecode(privateJwk['d'] as String));
    final privateKey = pc.ECPrivateKey(d, ecParams);

    final random = pc.FortunaRandom()
      ..seed(pc.KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => Random.secure().nextInt(256))),
      ));

    final signer = pc.ECDSASigner(pc.SHA256Digest())
      ..init(
        true,
        pc.ParametersWithRandom(
          pc.PrivateKeyParameter<pc.ECPrivateKey>(privateKey),
          random,
        ),
      );

    final sig = signer.generateSignature(payload) as pc.ECSignature;

    // IEEE P1363: r||s, 32 bytes each
    final result = Uint8List(64);
    result.setRange(0, 32, _bigIntToBytes(sig.r, 32));
    result.setRange(32, 64, _bigIntToBytes(sig.s, 32));
    return result;
  }

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
}
