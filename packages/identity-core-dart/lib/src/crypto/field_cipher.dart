import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Indica que un valor persistido no pudo descifrarse.
///
/// Suele deberse a una clave AES distinta a la usada al cifrar (PIN incorrecto
/// tras migración) o a un payload corrupto en disco.
class FieldCipherError implements Exception {
  /// Crea el error con un [message] opcional para diagnóstico.
  const FieldCipherError([this.message = 'No se pudo descifrar el campo.']);

  /// Detalle legible del fallo de descifrado.
  final String message;

  @override
  String toString() => 'FieldCipherError: $message';
}

/// Cifra y descifra strings sensibles antes de persistirlos en Isar.
///
/// Usa AES-256-GCM (`package:cryptography`). Cada cifrado genera un nonce
/// aleatorio; el resultado en disco sigue el formato:
///
/// `enc:v1:` + base64(nonce de 12 B ‖ ciphertext ‖ mac de 16 B)
///
/// Los stores de credenciales y claves invocan esta clase con la clave derivada
/// del PIN que expone [WalletCryptoContext].
class FieldCipher {
  /// [algorithm] permite inyectar un [AesGcm] distinto en tests.
  FieldCipher({AesGcm? algorithm})
      : _algorithm = algorithm ?? AesGcm.with256bits();

  /// Prefijo que identifica valores cifrados por esta implementación.
  static const String prefix = 'enc:v1:';

  final AesGcm _algorithm;

  /// Retorna `true` si [value] comienza con [prefix].
  ///
  /// Valores sin prefijo se tratan como texto plano legacy (pre-migración).
  bool isEncrypted(String? value) =>
      value != null && value.startsWith(prefix);

  /// Cifra [plaintext] con [key] y retorna el string con prefijo `enc:v1:`.
  ///
  /// [key] debe ser exactamente 32 bytes (AES-256), típicamente la salida de
  /// [PinVerifier.deriveEncryptionKey].
  ///
  /// Lanza [ArgumentError] si [key] no tiene longitud 32.
  Future<String> encrypt(Uint8List key, String plaintext) async {
    if (key.length != 32) {
      throw ArgumentError.value(key.length, 'key', 'debe ser de 32 bytes');
    }
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(key),
      nonce: nonce,
    );
    final payload = Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    return '$prefix${base64Encode(payload)}';
  }

  /// Descifra [encrypted] con [key] y retorna el texto original.
  ///
  /// Si [encrypted] no tiene prefijo `enc:v1:`, lo devuelve sin modificar para
  /// permitir leer registros legacy en claro hasta que corra la migración.
  ///
  /// Lanza [ArgumentError] si [key] no tiene longitud 32.
  /// Lanza [FieldCipherError] si la MAC no valida (clave incorrecta o dato corrupto).
  Future<String> decrypt(Uint8List key, String encrypted) async {
    if (!isEncrypted(encrypted)) return encrypted;
    if (key.length != 32) {
      throw ArgumentError.value(key.length, 'key', 'debe ser de 32 bytes');
    }

    final raw = base64Decode(encrypted.substring(prefix.length));
    const nonceLength = 12;
    const macLength = 16;
    if (raw.length < nonceLength + macLength) {
      throw const FieldCipherError('payload demasiado corto');
    }

    final nonce = raw.sublist(0, nonceLength);
    final macBytes = raw.sublist(raw.length - macLength);
    final cipherText = raw.sublist(nonceLength, raw.length - macLength);

    try {
      final clear = await _algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes)),
        secretKey: SecretKey(key),
      );
      return utf8.decode(clear);
    } on SecretBoxAuthenticationError {
      throw const FieldCipherError();
    }
  }
}
