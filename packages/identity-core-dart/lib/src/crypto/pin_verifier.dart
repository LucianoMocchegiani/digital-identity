import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Deriva claves y hashes del PIN del usuario con Argon2id (RFC 9106).
///
/// Separa dos usos criptográficos del mismo PIN:
///
/// 1. **Cifrado de campos** — [deriveEncryptionKey] alimenta [FieldCipher].
/// 2. **Verificación de PIN** — [derivePinHash] se persiste en secure storage
///    y se compara en [WalletService.unlock] sin depender de Isar.
///
/// El dominio `pin-verify:` en el hash evita reutilizar la misma derivación
/// que la clave AES de cifrado.
class PinVerifier {
  /// Crea el verificador con parámetros Argon2id por defecto (RFC 9106).
  ///
  /// [argon2id] permite inyectar una instancia distinta en tests.
  PinVerifier({Argon2id? argon2id})
      : _argon2id = argon2id ??
            Argon2id(
              parallelism: 4,
              memory: 64 * 1024,
              iterations: 8,
              hashLength: 32,
            );

  static const _verifyDomainPrefix = 'pin-verify:';

  final Argon2id _argon2id;

  /// Deriva la clave AES-256 (32 bytes) para cifrar campos sensibles en Isar.
  ///
  /// [pin] es el PIN ingresado por el usuario.
  /// [salt] es el salt aleatorio de 16 bytes persistido en secure storage.
  Future<Uint8List> deriveEncryptionKey({
    required String pin,
    required Uint8List salt,
  }) async {
    final derived = await _argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return Uint8List.fromList(await derived.extractBytes());
  }

  /// Deriva el hash de verificación del PIN para almacenar fuera de Isar.
  ///
  /// Usa un prefijo de dominio (`pin-verify:`) para que el resultado sea
  /// distinto de [deriveEncryptionKey] con el mismo [pin] y [salt].
  Future<Uint8List> derivePinHash({
    required String pin,
    required Uint8List salt,
  }) async {
    final derived = await _argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode('$_verifyDomainPrefix$pin')),
      nonce: salt,
    );
    return Uint8List.fromList(await derived.extractBytes());
  }

  /// Compara dos hashes en tiempo constante para mitigar timing attacks.
  ///
  /// Retorna `true` solo si [expected] y [actual] tienen la misma longitud
  /// y el mismo contenido byte a byte.
  bool verifyPinHash({
    required Uint8List expected,
    required Uint8List actual,
  }) {
    if (expected.length != actual.length) return false;
    var diff = 0;
    for (var i = 0; i < expected.length; i++) {
      diff |= expected[i] ^ actual[i];
    }
    return diff == 0;
  }
}
