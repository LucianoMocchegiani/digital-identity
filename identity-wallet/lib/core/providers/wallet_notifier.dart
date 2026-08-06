import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:path_provider/path_provider.dart';

import '../persistence/onboarding_progress_repository.dart';
import '../persistence/wallet_ux_paths.dart';
import '../persistence/wallet_ux_repository.dart';
import '../trust/eudi_trust_config_loader.dart';
import '../wallet_constants.dart';
import '../wallet_state.dart';

const _kSaltKey = 'wallet_salt_$kWalletId';

/// Estado global del ciclo de vida de la wallet (Riverpod).
///
/// Expone [WalletState] vía [walletNotifierProvider]: si falta configuración,
/// si está bloqueada o desbloqueada, y errores de carga. Las pantallas leen este
/// estado para mostrar mensajes (por ejemplo PIN incorrecto en [WalletLocked.error]);
/// no sustituye a snackbars ni toasts.
///
/// [RouterNotifier] escucha los cambios y dispara refresco de [GoRouter] para
/// redirecciones (onboarding, autenticación, home).

class WalletNotifier extends AsyncNotifier<WalletState> {
  static const _storage = FlutterSecureStorage();
  late String _directory;
  late final WalletService _service;
  TrustConfig? _trustConfig;

  WalletNotifier() {
    _service = WalletService();
  }

  /// Determina el estado inicial según almacenamiento seguro (salt de la wallet).
  ///
  /// Sin salt en disco → [WalletNotConfigured]. Con salt → [WalletLocked]
  /// hasta que el usuario desbloquee con PIN.

  @override
  Future<WalletState> build() async {
    final appDir = await getApplicationDocumentsDirectory();
    _directory = appDir.path;
    _trustConfig = await EudiTrustConfigLoader.load();
    final salt = await _storage.read(key: _kSaltKey);
    return salt != null ? const WalletLocked() : const WalletNotConfigured();
  }

  /// Crea la wallet con [pin] y deja [WalletUnlocked] con sesión activa.

  Future<void> create(String pin) async {
    if (state is AsyncLoading) return;
    state = const AsyncLoading();
    try {
      final session = await _service.create(
        walletId: kWalletId,
        pin: pin,
        directory: _directory,
        trustConfig: _trustConfig,
      );
      state = AsyncData(WalletUnlocked(session));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Desbloquea con [pin]. En PIN incorrecto conserva [WalletLocked] con [WalletLocked.error].

  Future<void> unlock(String pin) async {
    if (state is AsyncLoading) return;
    state = const AsyncLoading();
    try {
      final session = await _service.unlock(
        walletId: kWalletId,
        pin: pin,
        directory: _directory,
        trustConfig: _trustConfig,
      );
      state = AsyncData(WalletUnlocked(session));
    } on WrongPinError {
      state = const AsyncData(WalletLocked(error: 'PIN incorrecto. Intentá de nuevo.'));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Bloquea la sesión en disco y pasa a [WalletLocked] sin mensaje de error.

  Future<void> lock() async {
    final current = state.valueOrNull;
    if (current is WalletUnlocked) await current.session.lock();
    state = const AsyncData(WalletLocked());
  }

  /// Elimina datos de la wallet y vuelve a [WalletNotConfigured].
  ///
  /// Borra el archivo Isar del SDK y el JSON de preferencias locales
  /// (`{walletId}_ux.json`) vía [WalletUxRepository.clear].

  Future<void> reset() async {
    state = const AsyncLoading();
    await _service.reset(walletId: kWalletId, directory: _directory);
    await WalletUxRepository.clear(WalletUxPaths(directory: _directory));
    await OnboardingProgressRepository().clear();
    state = const AsyncData(WalletNotConfigured());
  }

  /// Sesión activa solo si el estado actual es [WalletUnlocked].
  ///
  /// Lanza [WalletLockedError] en cualquier otro caso.

  WalletSession get session {
    final s = state.valueOrNull;
    if (s is WalletUnlocked) return s.session;
    throw const WalletLockedError();
  }
}

/// Provider del [WalletNotifier] para toda la app.

final walletNotifierProvider =
    AsyncNotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
