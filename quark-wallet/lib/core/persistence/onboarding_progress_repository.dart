import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../wallet_constants.dart';

/// Snapshot inmutable del progreso de onboarding leído desde disco.
///
/// Vive en [FlutterSecureStorage] **antes y después** de que exista la wallet.
/// No almacena el PIN en texto plano; solo consentimientos y flags de avance.
///
/// Consumido por [OnboardingProgressNotifier] y [OnboardingFlow] para decidir
/// en qué pantalla reanudar el flujo tras un cierre inesperado de la app.
class OnboardingProgressData {
  const OnboardingProgressData({
    this.termsAccepted = false,
    this.isComplete = true,
  });

  /// Indica si el usuario marcó el checkbox de T&C en [SetupIntroScreen].
  ///
  /// Cuando es `true` y la wallet aún no existe ([WalletNotConfigured]),
  /// [OnboardingFlow] salta slides e intro y arranca en creación de PIN.
  final bool termsAccepted;

  /// Indica si el usuario terminó el onboarding por completo.
  ///
  /// Pasa a `false` al crear la wallet (paso opcional de credencial pendiente)
  /// y vuelve a `true` al omitir o completar [CredentialGenerationScreen].
  /// Mientras sea `false` con wallet desbloqueada, [GoRouter] mantiene la ruta
  /// `/onboarding` en lugar de redirigir a `/home`.
  final bool isComplete;

  /// Devuelve una copia con los campos indicados reemplazados.
  OnboardingProgressData copyWith({
    bool? termsAccepted,
    bool? isComplete,
  }) {
    return OnboardingProgressData(
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

/// Persiste el progreso del primer uso en almacenamiento seguro del dispositivo.
///
/// Usa [FlutterSecureStorage] con claves namespaced por [kWalletId]. Los valores
/// son strings (`'true'` / `'false'`) para compatibilidad con el plugin.
///
/// **Claves en disco**
/// - `onboarding_terms_{walletId}` — aceptación de Términos y Condiciones.
/// - `onboarding_complete_{walletId}` — `'false'` mientras falta el paso de
///   credencial; ausente o `'true'` cuando el onboarding terminó.
///
/// **Ciclo de vida**
/// 1. Usuario acepta T&C → [setTermsAccepted].
/// 2. Usuario confirma PIN y se crea la wallet → [markWalletCreated].
/// 3. Usuario omite o genera credencial → [markComplete].
/// 4. Reset de wallet → [clear] (invocado desde [WalletNotifier.reset]).
///
/// Wallets existentes sin clave `onboarding_complete` se tratan como onboarding
/// completo para no forzar el paso de credencial a usuarios previos.
class OnboardingProgressRepository {
  /// [storage] inyectable para tests; por defecto usa el almacén seguro del SO.
  OnboardingProgressRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String get _termsKey => 'onboarding_terms_$kWalletId';
  static String get _completeKey => 'onboarding_complete_$kWalletId';

  /// Lee el progreso persistido y deriva [OnboardingProgressData.isComplete].
  ///
  /// [walletExists] debe ser `true` cuando ya hay salt de wallet en disco
  /// ([WalletLocked] o [WalletUnlocked]). Si es `false`, [isComplete] se
  /// reporta siempre como `true` porque el flag de completitud solo aplica
  /// una vez creada la wallet.
  Future<OnboardingProgressData> load({required bool walletExists}) async {
    final terms = await _storage.read(key: _termsKey);
    final completeRaw = await _storage.read(key: _completeKey);

    final isComplete = !walletExists || completeRaw != 'false';

    return OnboardingProgressData(
      termsAccepted: terms == 'true',
      isComplete: isComplete,
    );
  }

  /// Persiste que el usuario aceptó Términos y Condiciones.
  ///
  /// Se invoca al presionar "Continuar" en [SetupIntroScreen] con el checkbox
  /// marcado. Permite reanudar en creación de PIN si la app se cierra antes
  /// de configurar el acceso.
  Future<void> setTermsAccepted() async {
    await _storage.write(key: _termsKey, value: 'true');
  }

  /// Marca onboarding incompleto tras la creación exitosa de la wallet.
  ///
  /// Escribe `onboarding_complete = false` para que [GoRouter] permita quedarse
  /// en [CredentialGenerationScreen] aunque el estado pase a [WalletUnlocked].
  Future<void> markWalletCreated() async {
    await _storage.write(key: _completeKey, value: 'false');
  }

  /// Marca el onboarding como finalizado (usuario omitió o añadió credencial).
  ///
  /// Tras esta escritura, [GoRouter] redirige rutas `/onboarding` y `/authenticate`
  /// hacia `/home` cuando la wallet está desbloqueada.
  Future<void> markComplete() async {
    await _storage.write(key: _completeKey, value: 'true');
  }

  /// Elimina todas las claves de progreso de onboarding.
  ///
  /// Debe llamarse junto con el borrado de la wallet para no dejar flags
  /// huérfanos que alteren un futuro primer uso.
  Future<void> clear() async {
    await _storage.delete(key: _termsKey);
    await _storage.delete(key: _completeKey);
  }
}
