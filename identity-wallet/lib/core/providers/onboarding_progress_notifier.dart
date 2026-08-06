import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/onboarding_progress_repository.dart';
import '../wallet_state.dart';
import 'wallet_notifier.dart';

/// Notifier Riverpod del progreso de onboarding.
///
/// Expone [OnboardingProgressData] de forma reactiva para pantallas y para
/// [GoRouter]. Delega la persistencia en [OnboardingProgressRepository].
///
/// **Invalidación automática**
/// Escucha [walletNotifierProvider] y se recarga cuando la wallet pasa de
/// inexistente a creada (o viceversa tras reset), de modo que [isComplete]
/// se reinterpreta con el flag correcto en disco.
///
/// **Escritura**
/// Usar los métodos públicos de mutación en lugar de escribir en el repositorio
/// directamente desde la UI, para mantener `state` y disco sincronizados.
class OnboardingProgressNotifier extends AsyncNotifier<OnboardingProgressData> {
  late OnboardingProgressRepository _repository;

  @override
  Future<OnboardingProgressData> build() async {
    ref.listen<AsyncValue<WalletState>>(walletNotifierProvider, (previous, next) {
      final prevWs = previous?.valueOrNull;
      final nextWs = next.valueOrNull;
      if (_walletExists(prevWs) != _walletExists(nextWs)) {
        ref.invalidateSelf();
      }
    });

    _repository = OnboardingProgressRepository();
    final walletState = ref.watch(walletNotifierProvider).valueOrNull;
    return _repository.load(walletExists: _walletExists(walletState));
  }

  /// Retorna `true` si el salt de la wallet ya está en almacenamiento seguro.
  bool _walletExists(WalletState? ws) {
    return ws is WalletLocked || ws is WalletUnlocked;
  }

  /// Persiste la aceptación de T&C y actualiza [OnboardingProgressData.termsAccepted].
  ///
  /// Llamar desde [OnboardingFlow] al continuar desde [SetupIntroScreen].
  Future<void> acceptTerms() async {
    await _repository.setTermsAccepted();
    final current = state.valueOrNull ?? const OnboardingProgressData();
    state = AsyncData(current.copyWith(termsAccepted: true));
  }

  /// Marca el paso de credencial como pendiente tras [WalletNotifier.create].
  ///
  /// Deja [OnboardingProgressData.isComplete] en `false` hasta que el usuario
  /// omita o complete [CredentialGenerationScreen].
  Future<void> markWalletCreated() async {
    await _repository.markWalletCreated();
    final current = state.valueOrNull ?? const OnboardingProgressData();
    state = AsyncData(current.copyWith(isComplete: false));
  }

  /// Cierra el onboarding y habilita la navegación normal a `/home`.
  ///
  /// Invocar al presionar "Omitir" o tras emitir la primera credencial por QR
  /// en [CredentialGenerationScreen].
  Future<void> markComplete() async {
    await _repository.markComplete();
    final current = state.valueOrNull ?? const OnboardingProgressData();
    state = AsyncData(current.copyWith(isComplete: true));
  }

  /// Borra progreso en disco y restablece el estado en memoria.
  ///
  /// Usado indirectamente vía [OnboardingProgressRepository.clear] durante
  /// [WalletNotifier.reset]; expuesto por si hiciera falta invalidar desde tests.
  Future<void> clear() async {
    await _repository.clear();
    state = const AsyncData(OnboardingProgressData());
  }
}

/// Provider principal del progreso de onboarding.
///
/// Lectura: `ref.watch(onboardingProgressNotifierProvider)`.
/// Escritura: `ref.read(onboardingProgressNotifierProvider.notifier)`.
final onboardingProgressNotifierProvider =
    AsyncNotifierProvider<OnboardingProgressNotifier, OnboardingProgressData>(
  OnboardingProgressNotifier.new,
);

/// Evalúa si el onboarding terminó para la lógica de redirect de [GoRouter].
///
/// Mientras [progress] está en carga o error, asume `true` (completo) para no
/// bloquear el acceso a `/home` en arranques fríos o ante fallos de lectura.
/// Solo cuando el valor en disco es explícitamente incompleto (`'false'`) y la
/// wallet existe, retorna `false`.
bool isOnboardingComplete(AsyncValue<OnboardingProgressData> progress) {
  return progress.valueOrNull?.isComplete ?? true;
}
