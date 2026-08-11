import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../core/providers/onboarding_progress_notifier.dart';
import '../../core/providers/wallet_notifier.dart';
import '../../core/wallet_state.dart';
import 'screens/credential_generation_screen.dart';
import 'screens/pin_confirm_screen.dart';
import 'screens/pin_create_screen.dart';
import 'screens/setup_intro_screen.dart';
import 'screens/welcome_slides_screen.dart';

/// Índices del [PageView] de [OnboardingFlow].
///
/// Deben mantenerse alineados con el orden del array `children` del [PageView].
/// Usados para [PageController.initialPage] al reanudar el flujo persistido.
abstract final class OnboardingPages {
  /// Carrusel de bienvenida ([WelcomeSlidesScreen]).
  static const welcome = 0;

  /// Intro y aceptación de T&C ([SetupIntroScreen]).
  static const setup = 1;

  /// Primer ingreso del PIN de 6 dígitos ([PinCreateScreen]).
  static const pinCreate = 2;

  /// Confirmación del PIN ([PinConfirmScreen]); aquí se crea la wallet.
  static const pinConfirm = 3;

  /// Paso opcional de primera credencial ([CredentialGenerationScreen]).
  static const credential = 4;
}

/// Orquestador del primer lanzamiento de la app.
///
/// Compone un [PageView] sin swipe manual entre cinco pantallas:
/// bienvenida → setup/T&C → crear PIN → confirmar PIN → credencial opcional.
///
/// **Persistencia y reanudación**
/// - T&C aceptados → [OnboardingProgressRepository.setTermsAccepted]; si la app
///   se cierra antes del PIN, reanuda en [OnboardingPages.pinCreate].
/// - Desde creación de PIN no hay "atrás" hacia T&C (ya aceptados en disco).
/// - Confirmación de PIN sí permite volver a corregir el PIN ingresado.
/// - PIN confirmado → [WalletNotifier.create] + `onboarding_complete = false`;
///   si se cierra antes de omitir credencial, tras desbloquear reanuda en
///   [OnboardingPages.credential].
///
/// **Seguridad**
/// El PIN solo vive en memoria (`_pin`) entre crear y confirmar; nunca se
/// escribe en [FlutterSecureStorage]. El salt cifrado lo persiste el SDK.
///
/// La navegación post-onboarding la resuelve [GoRouter] según [WalletState]
/// y [OnboardingProgressData.isComplete].
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  PageController? _controller;
  bool _ready = false;

  /// PIN provisional entre [PinCreateScreen] y [PinConfirmScreen].
  ///
  /// Se descarta al salir del flujo; no se persiste en disco.
  String _pin = '';

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  /// Calcula la pantalla inicial según progreso en disco y estado de la wallet.
  ///
  /// Muestra un [CircularProgressIndicator] hasta que termina y se crea el
  /// [PageController] con [PageController.initialPage] correcto.
  Future<void> _initFlow() async {
    final progress = await ref.read(onboardingProgressNotifierProvider.future);
    final walletState = ref.read(walletNotifierProvider).valueOrNull;

    var initialPage = OnboardingPages.welcome;
    if (walletState is WalletUnlocked && !progress.isComplete) {
      initialPage = OnboardingPages.credential;
    } else if (progress.termsAccepted && walletState is WalletNotConfigured) {
      initialPage = OnboardingPages.pinCreate;
    }

    if (!mounted) return;
    setState(() {
      _controller = PageController(initialPage: initialPage);
      _ready = true;
    });
  }

  void _next() {
    _controller?.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _back() {
    _controller?.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Persiste T&C y avanza a creación de PIN.
  Future<void> _onSetupContinue() async {
    await ref.read(onboardingProgressNotifierProvider.notifier).acceptTerms();
    _next();
  }

  /// Guarda el PIN en memoria y avanza a confirmación.
  void _onPinCreated(String pin) {
    setState(() => _pin = pin);
    _next();
  }

  /// Crea la wallet en disco con el PIN confirmado.
  ///
  /// Delega en [WalletNotifier.create]. Si falla, propaga el error a
  /// [PinConfirmScreen] para mostrar mensaje sin avanzar ni mostrar el modal
  /// de éxito. Si tiene éxito, marca onboarding incompleto en disco.
  Future<void> _onPinConfirmed(String pin) async {
    await ref.read(walletNotifierProvider.notifier).create(pin);
    final walletState = ref.read(walletNotifierProvider);
    if (walletState.hasError) {
      throw walletState.error!;
    }
    await ref.read(onboardingProgressNotifierProvider.notifier).markWalletCreated();
  }

  /// Avanza al paso opcional de credencial tras el modal de PIN creado.
  void _onPinSuccess() => _next();

  /// Marca el onboarding como completo (botón "Omitir" en credencial).
  ///
  /// [GoRouter] redirige a `/home` en el siguiente refresh.
  Future<void> _onComplete() async {
    await ref.read(onboardingProgressNotifierProvider.notifier).markComplete();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundNeutralSecondary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WelcomeSlidesScreen(onContinue: _next),
            SetupIntroScreen(onContinue: _onSetupContinue),
            PinCreateScreen(
              onPinCreated: _onPinCreated,
              // Sin "atrás": los T&C ya están persistidos al llegar acá.
              onBack: null,
            ),
            PinConfirmScreen(
              expectedPin: _pin,
              onConfirmed: _onPinConfirmed,
              onSuccess: _onPinSuccess,
              onBack: _back,
            ),
            CredentialGenerationScreen(
              onSkip: _onComplete,
              onAddCredential: () => context.push('/home/scan'),
            ),
          ],
        ),
      ),
    );
  }
}
