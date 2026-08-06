import 'dart:typed_data';

import 'field_cipher.dart';

/// Material criptográfico de una sesión de wallet desbloqueada.
///
/// Se crea en [WalletService.unlock] o [WalletService.create] y vive solo en
/// memoria hasta que la sesión se bloquea. Nunca se escribe en disco.
///
/// Los record stores usan [encryptionKey] y [cipher] para cifrar campos como
/// `privateJwkJson`, JWTs de credenciales y tokens OID4VCI antes de `put()` en Isar.
class WalletCryptoContext {
  /// [encryptionKey] clave AES-256 derivada del PIN (32 bytes).
  ///
  /// [cipher] instancia reutilizable; por defecto [FieldCipher].
  WalletCryptoContext({
    required this.encryptionKey,
    FieldCipher? cipher,
  })  : assert(encryptionKey.length == 32),
        cipher = cipher ?? FieldCipher();

  /// Clave AES-256 derivada con Argon2id a partir del PIN y el salt del wallet.
  final Uint8List encryptionKey;

  /// Cifrador de campos usado por los stores de persistencia.
  final FieldCipher cipher;

  /// Cifra [plaintext] si no es null; de lo contrario retorna null.
  Future<String?> protectField(String? plaintext) async {
    if (plaintext == null) return null;
    return cipher.encrypt(encryptionKey, plaintext);
  }

  /// Cifra [plaintext] (no nullable).
  Future<String> protectFieldRequired(String plaintext) =>
      cipher.encrypt(encryptionKey, plaintext);

  /// Descifra [stored] si no es null; valores sin prefijo `enc:v1:` se devuelven tal cual.
  Future<String?> revealField(String? stored) async {
    if (stored == null) return null;
    return cipher.decrypt(encryptionKey, stored);
  }
}
