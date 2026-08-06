import 'dart:ffi';
import 'dart:typed_data';

import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';

import 'libsodium_ed25519.dart';

/// C20P IETF (nonce 12 bytes) — Credo usa `crypto_aead_chacha20poly1305_ietf`,
/// no el ChaCha20-Poly1305 original de 8 bytes expuesto en `aeadChaCha20Poly1305`.
abstract final class LibsodiumC20p {
  static Future<({Uint8List cipherText, Uint8List tag})> encryptDetached({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List additionalData,
  }) async {
    if (key.length != 32) {
      throw ArgumentError('C20P requiere clave de 32 bytes');
    }
    if (nonce.length != 12) {
      throw ArgumentError('C20P IETF requiere nonce de 12 bytes');
    }

    final sodium = await LibsodiumEd25519.ffi();
    final macLen = sodium.crypto_aead_chacha20poly1305_ietf_abytes();

    final cipherPtr = SodiumPointer<UnsignedChar>.alloc(
      sodium,
      count: plaintext.length,
    );
    final macPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: macLen);
    final msgPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: plaintext.length)
      ..fill(plaintext);
    final noncePtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: nonce.length)
      ..fill(nonce);
    final keyPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: key.length)
      ..fill(key);
    final adPtr = SodiumPointer<UnsignedChar>.alloc(
      sodium,
      count: additionalData.length,
    )..fill(additionalData);
    final macLenPtr = SodiumPointer<UnsignedLongLong>.alloc(sodium, count: 1)
      ..fill([macLen]);

    try {
      final rc = sodium.crypto_aead_chacha20poly1305_ietf_encrypt_detached(
        cipherPtr.ptr,
        macPtr.ptr,
        macLenPtr.ptr,
        msgPtr.ptr,
        msgPtr.count,
        adPtr.ptr,
        adPtr.count,
        nullptr,
        noncePtr.ptr,
        keyPtr.ptr,
      );
      if (rc != 0) {
        throw StateError(
          'crypto_aead_chacha20poly1305_ietf_encrypt_detached rc=$rc',
        );
      }

      return (
        cipherText: Uint8List.fromList(cipherPtr.asListView()),
        tag: Uint8List.fromList(macPtr.asListView()),
      );
    } finally {
      cipherPtr.dispose();
      macPtr.dispose();
      msgPtr.dispose();
      noncePtr.dispose();
      keyPtr.dispose();
      adPtr.dispose();
      macLenPtr.dispose();
    }
  }

  static Future<Uint8List> decryptDetached({
    required Uint8List cipherText,
    required Uint8List tag,
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List additionalData,
  }) async {
    if (key.length != 32) {
      throw ArgumentError('C20P requiere clave de 32 bytes');
    }
    if (nonce.length != 12) {
      throw ArgumentError('C20P IETF requiere nonce de 12 bytes');
    }

    final sodium = await LibsodiumEd25519.ffi();
    final msgLen = cipherText.length;
    final msgPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: msgLen);
    final macPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: tag.length)
      ..fill(tag);
    final cipherPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: msgLen)
      ..fill(cipherText);
    final noncePtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: nonce.length)
      ..fill(nonce);
    final keyPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: key.length)
      ..fill(key);
    final adPtr = SodiumPointer<UnsignedChar>.alloc(
      sodium,
      count: additionalData.length,
    )..fill(additionalData);

    try {
      final rc = sodium.crypto_aead_chacha20poly1305_ietf_decrypt_detached(
        msgPtr.ptr,
        nullptr,
        cipherPtr.ptr,
        msgLen,
        macPtr.ptr,
        adPtr.ptr,
        adPtr.count,
        noncePtr.ptr,
        keyPtr.ptr,
      );
      if (rc != 0) {
        throw StateError(
          'crypto_aead_chacha20poly1305_ietf_decrypt_detached rc=$rc',
        );
      }
      return Uint8List.fromList(msgPtr.asListView());
    } finally {
      msgPtr.dispose();
      macPtr.dispose();
      cipherPtr.dispose();
      noncePtr.dispose();
      keyPtr.dispose();
      adPtr.dispose();
    }
  }
}
