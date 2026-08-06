import 'package:identity_core_dart/identity_core.dart';

/// Almacenamiento en memoria para tests de [WalletService].
class MemoryWalletSecureStorage implements WalletSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }
}
