import 'dart:ffi';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:sodium_libs/sodium_libs.dart' hide SodiumInit;
import 'package:sodium_libs/src/sodium_init.dart' as sodium_libs;

/// Utilidades libsodium para DIDComm v1 (Credo + Askar).
abstract final class LibsodiumEd25519 {
  static Sodium? _sodium;

  static Future<Sodium> sodium() async {
    _sodium ??= await sodium_libs.SodiumInit.init();
    return _sodium!;
  }

  /// Acceso FFI directo a libsodium (C20P IETF y conversiones Ed25519).
  static Future<LibSodiumFFI> ffi() async {
    final sodiumApi = await sodium();
    if (sodiumApi is! SodiumFFI) {
      throw UnsupportedError(
        'libsodium FFI no disponible en esta plataforma',
      );
    }
    return sodiumApi.sodium;
  }

  /// Convierte clave secreta Ed25519 (seed+pub) a X25519 Montgomery.
  static Future<Uint8List> secretKeyToCurve25519({
    required Uint8List ed25519SecretKey,
    required Uint8List ed25519PublicKey,
  }) async {
    final expanded = ed25519SecretKey.length == 64
        ? ed25519SecretKey
        : Uint8List.fromList([...ed25519SecretKey, ...ed25519PublicKey]);
    final libSodium = await LibsodiumEd25519.ffi();
    final outPtr = SodiumPointer<UnsignedChar>.alloc(libSodium, count: 32);
    final inPtr = SodiumPointer<UnsignedChar>.alloc(libSodium, count: 64)
      ..fill(expanded);
    try {
      final rc = libSodium.crypto_sign_ed25519_sk_to_curve25519(
        outPtr.ptr,
        inPtr.ptr,
      );
      if (rc != 0) {
        throw StateError('libsodium rechazó la clave secreta Ed25519 (rc=$rc)');
      }
      return Uint8List.fromList(outPtr.asListView());
    } finally {
      outPtr.dispose();
      inPtr.dispose();
    }
  }

  /// Convierte una clave pública Ed25519 (32 bytes) a X25519 Montgomery.
  static Future<Uint8List> publicKeyToCurve25519(Uint8List ed25519Pk) async {
    if (ed25519Pk.length != 32) {
      throw ArgumentError('Se esperan 32 bytes de clave Ed25519');
    }
    final libSodium = await LibsodiumEd25519.ffi();
    final outPtr = SodiumPointer<UnsignedChar>.alloc(libSodium, count: 32);
    final inPtr = SodiumPointer<UnsignedChar>.alloc(libSodium, count: 32)
      ..fill(ed25519Pk);
    try {
      final rc = libSodium.crypto_sign_ed25519_pk_to_curve25519(
        outPtr.ptr,
        inPtr.ptr,
      );
      if (rc != 0) {
        throw StateError('libsodium rechazó la clave Ed25519 (rc=$rc)');
      }
      return Uint8List.fromList(outPtr.asListView());
    } finally {
      outPtr.dispose();
      inPtr.dispose();
    }
  }
}
