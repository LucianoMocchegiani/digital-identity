import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstrae el almacenamiento de secretos del wallet fuera de Isar.
///
/// Persiste el salt de derivación (`wallet_salt_<walletId>`) y el hash del PIN
/// (`wallet_pin_hash_<walletId>`) en Keychain/Keystore vía el adaptador concreto.
abstract class WalletSecureStorage {
  /// Lee el valor asociado a [key], o `null` si no existe.
  Future<String?> read({required String key});

  /// Persiste [value] bajo [key].
  Future<void> write({required String key, required String value});

  /// Elimina la entrada [key].
  Future<void> delete({required String key});
}

/// Recupera una lectura del salt cuando Android no puede descifrar esa entrada.
/// Solo se elimina el salt ilegible; otras claves y otros errores se conservan.
Future<String?> readWalletSaltWithRecovery({
  required Future<String?> Function() read,
  required Future<void> Function() delete,
}) async {
  try {
    return await read();
  } on PlatformException catch (error) {
    final message =
        '${error.code} ${error.message} ${error.details}'.toLowerCase();
    if (!message.contains('badpaddingexception') &&
        !message.contains('illegalblocksizeexception') &&
        !message.contains('bad_decrypt')) {
      rethrow;
    }
    await delete();
    return null;
  }
}

/// Implementación de [WalletSecureStorage] sobre [FlutterSecureStorage].
///
/// Es el backend por defecto de [WalletService] en apps Flutter.
class FlutterWalletSecureStorage implements WalletSecureStorage {
  /// [storage] permite inyectar una instancia configurada (p. ej. opciones iOS).
  FlutterWalletSecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) {
    final read = () => _storage.read(key: key);
    if (!key.startsWith('wallet_salt_')) return read();
    return readWalletSaltWithRecovery(
      read: read,
      delete: () => _storage.delete(key: key),
    );
  }

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}
