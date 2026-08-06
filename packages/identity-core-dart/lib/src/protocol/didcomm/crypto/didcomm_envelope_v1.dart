import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

import '../../../utils/base64_utils.dart';
import '../../../utils/multibase.dart';
import 'libsodium_c20p.dart';
import 'libsodium_ed25519.dart';

/// Empaqueta y desempaqueta mensajes DIDComm v1 (Aries RFC 0019 / Credo).
///
/// El wrap de CEK y del campo `sender` sigue Askar (`CryptoBox.seal` /
/// `sealOpen` y `crypto_box` autenticado), compatible con el KMS Askar del
/// backend Quark 2.
abstract final class DidCommEnvelopeV1 {
  static final _secureRandom = Random.secure();

  static Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }

  /// Libsodium sealed box hacia [recipientX25519PublicKey] (Askar Anoncrypt / sender).
  static Uint8List _seal({
    required Uint8List message,
    required Uint8List recipientX25519PublicKey,
    required Sodium sodium,
  }) {
    return sodium.crypto.box.seal(
      message: message,
      publicKey: recipientX25519PublicKey,
    );
  }

  /// Abre un sealed box con el par X25519 del receptor.
  static Uint8List _sealOpen({
    required Uint8List cipherText,
    required Uint8List recipientX25519PublicKey,
    required SecureKey recipientX25519SecretKey,
    required Sodium sodium,
  }) {
    return sodium.crypto.box.sealOpen(
      cipherText: cipherText,
      publicKey: recipientX25519PublicKey,
      secretKey: recipientX25519SecretKey,
    );
  }

  /// Extrae los 32 bytes de clave pública Ed25519 desde un `did:key` multibase.
  static Uint8List? ed25519PublicKeyBytesFromDid(String did) {
    if (!did.startsWith('did:key:z')) return null;
    try {
      final multibaseKey = did.substring('did:key:'.length);
      final decoded = decodeBase58Btc(multibaseKey.substring(1));
      if (decoded.length >= 3 && decoded[0] == 0xed && decoded[1] == 0x01) {
        return Uint8List.fromList(decoded.sublist(2));
      }
    } catch (_) {}
    return null;
  }

  /// Empaqueta [message] como envelope Authcrypt V1 (Credo holder / issuer).
  static Future<Map<String, dynamic>> packAuthcrypt({
    required Map<String, dynamic> message,
    required Uint8List recipientEd25519PublicKey,
    required Map<String, dynamic> senderEd25519PrivateJwk,
    required Map<String, dynamic> senderEd25519PublicJwk,
  }) async {
    final sodium = await LibsodiumEd25519.sodium();
    final cek = _randomBytes(32);

    final senderEd25519Pk =
        base64UrlDecode(senderEd25519PublicJwk['x'] as String);
    final senderEd25519Sk =
        base64UrlDecode(senderEd25519PrivateJwk['d'] as String);
    final senderX25519Secret = await LibsodiumEd25519.secretKeyToCurve25519(
      ed25519SecretKey: senderEd25519Sk,
      ed25519PublicKey: senderEd25519Pk,
    );
    final senderX25519Key = SecureKey.fromList(sodium, senderX25519Secret);

    final recipientX25519 = await LibsodiumEd25519.publicKeyToCurve25519(
      recipientEd25519PublicKey,
    );

    try {
      final senderKid = encodeBase58Btc(senderEd25519Pk);
      final senderHeader = base64UrlEncode(
        _seal(
          message: Uint8List.fromList(utf8.encode(senderKid)),
          recipientX25519PublicKey: recipientX25519,
          sodium: sodium,
        ),
      );

      final cekNonce = _randomBytes(24);
      final boxedCek = sodium.crypto.box.easy(
        message: cek,
        nonce: cekNonce,
        publicKey: recipientX25519,
        secretKey: senderX25519Key,
      );

      final kid = encodeBase58Btc(recipientEd25519PublicKey);
      final recipients = [
        {
          'encrypted_key': base64UrlEncode(boxedCek),
          'header': {
            'kid': kid,
            'iv': base64UrlEncode(cekNonce),
            'sender': senderHeader,
          },
        },
      ];

      final protectedPayload = <String, dynamic>{
        'enc': 'xchacha20poly1305_ietf',
        'typ': 'JWM/1.0',
        'alg': 'Authcrypt',
        'recipients': recipients,
      };
      final protectedString = base64UrlEncode(
        Uint8List.fromList(utf8.encode(jsonEncode(protectedPayload))),
      );

      final nonce = _randomBytes(12);
      final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(message)));
      final aad = Uint8List.fromList(utf8.encode(protectedString));
      final encrypted = await LibsodiumC20p.encryptDetached(
        plaintext: plaintext,
        key: cek,
        nonce: nonce,
        additionalData: aad,
      );

      return {
        'protected': protectedString,
        'iv': base64UrlEncode(nonce),
        'ciphertext': base64UrlEncode(encrypted.cipherText),
        'tag': base64UrlEncode(encrypted.tag),
      };
    } finally {
      senderX25519Key.dispose();
    }
  }

  /// Empaqueta [message] como envelope Anoncrypt V1 para [recipientEd25519PublicKey].
  static Future<Map<String, dynamic>> packAnoncrypt({
    required Map<String, dynamic> message,
    required Uint8List recipientEd25519PublicKey,
  }) async {
    final sodium = await LibsodiumEd25519.sodium();
    final cek = _randomBytes(32);

    final recipientX25519 = await LibsodiumEd25519.publicKeyToCurve25519(
      recipientEd25519PublicKey,
    );
    final encryptedKey = _seal(
      message: cek,
      recipientX25519PublicKey: recipientX25519,
      sodium: sodium,
    );

    final kid = encodeBase58Btc(recipientEd25519PublicKey);
    final recipients = [
      {
        'encrypted_key': base64UrlEncode(encryptedKey),
        'header': {'kid': kid},
      },
    ];

    final protectedPayload = <String, dynamic>{
      'enc': 'xchacha20poly1305_ietf',
      'typ': 'JWM/1.0',
      'alg': 'Anoncrypt',
      'recipients': recipients,
    };
    final protectedString = base64UrlEncode(
      Uint8List.fromList(utf8.encode(jsonEncode(protectedPayload))),
    );

    final nonce = _randomBytes(12);
    final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(message)));
    final aad = Uint8List.fromList(utf8.encode(protectedString));
    final encrypted = await LibsodiumC20p.encryptDetached(
      plaintext: plaintext,
      key: cek,
      nonce: nonce,
      additionalData: aad,
    );

    return {
      'protected': protectedString,
      'iv': base64UrlEncode(nonce),
      'ciphertext': base64UrlEncode(encrypted.cipherText),
      'tag': base64UrlEncode(encrypted.tag),
    };
  }

  /// Desempaqueta un envelope V1 cifrado para la clave Ed25519 del wallet.
  static Future<Map<String, dynamic>> unpack({
    required Map<String, dynamic> envelope,
    required Map<String, dynamic> recipientEd25519PrivateJwk,
    required Map<String, dynamic> recipientEd25519PublicJwk,
  }) async {
    final protectedString = envelope['protected'] as String;
    final protectedJson = jsonDecode(
      utf8.decode(base64UrlDecode(protectedString)),
    ) as Map<String, dynamic>;
    final alg = protectedJson['alg'] as String;
    if (alg != 'Anoncrypt' && alg != 'Authcrypt') {
      throw UnsupportedError('alg no soportado: $alg');
    }

    final ed25519Pk = base64UrlDecode(recipientEd25519PublicJwk['x'] as String);
    final walletKid = encodeBase58Btc(ed25519Pk);
    final recipients = (protectedJson['recipients'] as List).cast<dynamic>();
    final recipient = recipients
        .map((r) => Map<String, dynamic>.from(r as Map))
        .where(
          (r) => (r['header'] as Map<String, dynamic>)['kid'] == walletKid,
        )
        .firstOrNull;
    if (recipient == null) {
      throw StateError('No hay recipient con kid del wallet ($walletKid)');
    }

    final ed25519Sk = base64UrlDecode(recipientEd25519PrivateJwk['d'] as String);
    final x25519Secret = await LibsodiumEd25519.secretKeyToCurve25519(
      ed25519SecretKey: ed25519Sk,
      ed25519PublicKey: ed25519Pk,
    );
    final x25519Public = await LibsodiumEd25519.publicKeyToCurve25519(ed25519Pk);
    final sodium = await LibsodiumEd25519.sodium();
    final x25519Key = SecureKey.fromList(sodium, x25519Secret);
    try {
      final cek = await _unwrapCek(
        alg: alg,
        recipient: recipient,
        x25519PublicKey: x25519Public,
        x25519SecretKey: x25519Key,
        sodium: sodium,
      );
      final plaintext = await LibsodiumC20p.decryptDetached(
        cipherText: base64UrlDecode(envelope['ciphertext'] as String),
        tag: base64UrlDecode(envelope['tag'] as String),
        key: cek,
        nonce: base64UrlDecode(envelope['iv'] as String),
        additionalData: Uint8List.fromList(utf8.encode(protectedString)),
      );
      return jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
    } finally {
      x25519Key.dispose();
    }
  }

  static Future<Uint8List> _unwrapCek({
    required String alg,
    required Map<String, dynamic> recipient,
    required Uint8List x25519PublicKey,
    required SecureKey x25519SecretKey,
    required Sodium sodium,
  }) async {
    final header = Map<String, dynamic>.from(recipient['header'] as Map);
    final encryptedKey = base64UrlDecode(recipient['encrypted_key'] as String);

    if (alg == 'Anoncrypt') {
      if (encryptedKey.length <= sodium.crypto.box.sealBytes) {
        throw StateError('encrypted_key demasiado corto para anoncrypt seal');
      }
      return _sealOpen(
        cipherText: encryptedKey,
        recipientX25519PublicKey: x25519PublicKey,
        recipientX25519SecretKey: x25519SecretKey,
        sodium: sodium,
      );
    }

    final senderB58 = _openSenderKey(
      header: header,
      x25519PublicKey: x25519PublicKey,
      x25519SecretKey: x25519SecretKey,
      sodium: sodium,
    );
    final senderEd25519 = Uint8List.fromList(decodeBase58Btc(senderB58));
    final senderX25519 = await LibsodiumEd25519.publicKeyToCurve25519(
      senderEd25519,
    );
    final ivB64 = header['iv'] as String?;
    if (ivB64 == null) {
      throw StateError('Authcrypt requiere iv en recipient header');
    }
    return sodium.crypto.box.openEasy(
      cipherText: encryptedKey,
      nonce: base64UrlDecode(ivB64),
      publicKey: senderX25519,
      secretKey: x25519SecretKey,
    );
  }

  static String _openSenderKey({
    required Map<String, dynamic> header,
    required Uint8List x25519PublicKey,
    required SecureKey x25519SecretKey,
    required Sodium sodium,
  }) {
    final senderB64 = header['sender'] as String?;
    if (senderB64 == null || senderB64.isEmpty) {
      throw StateError('Authcrypt requiere sender en recipient header');
    }
    final sealed = base64UrlDecode(senderB64);
    if (sealed.length <= sodium.crypto.box.sealBytes) {
      throw StateError('sender demasiado corto para seal');
    }
    final senderBytes = _sealOpen(
      cipherText: sealed,
      recipientX25519PublicKey: x25519PublicKey,
      recipientX25519SecretKey: x25519SecretKey,
      sodium: sodium,
    );
    return utf8.decode(senderBytes);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
