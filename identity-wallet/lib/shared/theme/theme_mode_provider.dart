import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kThemeModeKey = 'theme_mode';
const _storage = FlutterSecureStorage();

/// Preferencia de tema: solo claro / oscuro.
/// Default y fallback: **oscuro** (alineado a la web Kuatia).
final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _storage.read(key: _kThemeModeKey);
    // Solo 'light' explícito; cualquier otro valor (null, system, dark) → oscuro.
    state = raw == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setMode(ThemeMode mode) async {
    final next = mode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await _storage.write(
      key: _kThemeModeKey,
      value: next == ThemeMode.light ? 'light' : 'dark',
    );
  }
}
