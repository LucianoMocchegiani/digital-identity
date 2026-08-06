import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/providers/wallet_notifier.dart';
import '../../core/wallet_state.dart';
import '../onboarding/widgets/pin_entry_view.dart';

/// Desbloqueo con PIN cuando [WalletState] es [WalletLocked].
///
/// Ruta `/authenticate` desde [routerProvider]: el usuario ya tiene wallet en disco
/// pero sin sesión activa. Reutiliza [PinEntryView] (teclado propio) en modo
/// desbloqueo (sin barra superior, con botón "Confirmar"). Al presionar confirmar
/// con seis dígitos se llama a [WalletNotifier.unlock]; si el estado sigue siendo
/// [WalletLocked] (PIN incorrecto), se muestra el error en [PinEntryView] y se
/// cuentan intentos fallidos; al superar el máximo se navega a `/pin-locked`.
///
/// En [initState] se intenta biometría con [LocalAuthentication] si el dispositivo
/// lo permite; el desbloqueo completo solo con biométricos queda pendiente (ver
/// comentario en [_tryBiometrics]).

class AuthenticateScreen extends ConsumerStatefulWidget {
  const AuthenticateScreen({super.key});

  @override
  ConsumerState<AuthenticateScreen> createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends ConsumerState<AuthenticateScreen> {
  final _auth = LocalAuthentication();
  int _failedAttempts = 0;
  static const _maxAttempts = 5;

  /// Mensaje de error a mostrar en [PinEntryView] tras un PIN incorrecto.
  String _errorText = 'PIN incorrecto';

  /// Nonce que se incrementa en cada fallo para disparar el estado de error.
  int _errorNonce = 0;

  @override
  void initState() {
    super.initState();
    _tryBiometrics();
  }

  /// Prueba biométricos al abrir la pantalla (huella / Face ID, etc.).
  ///
  /// No hace nada si el hardware no soporta o no hay biométricos enrolados.
  /// El desbloqueo de la wallet sin PIN vía biométricos se deja para trabajo futuro
  /// (INT-4 en comentario de implementación).

  Future<void> _tryBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      // canCheckBiometrics es un getter en local_auth, no un método
      final canCheck = await _auth.canCheckBiometrics;
      if (!supported || !canCheck) return;

      await _auth.authenticate(
        localizedReason: 'Desbloquear wallet',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      // Biometric-full unlock se implementa en INT-4 (requiere almacenar key cifrada).
    } catch (_) {}
  }

  /// Desbloquea con [pin] vía [WalletNotifier.unlock] y actualiza UI según resultado.
  ///
  /// Si la wallet permanece [WalletLocked] (PIN incorrecto), incrementa el contador
  /// de fallos y dispara el estado de error en [PinEntryView] con los intentos
  /// restantes; al alcanzar el máximo redirige a `/pin-locked`.

  Future<void> _onPinCompleted(String pin) async {
    await ref.read(walletNotifierProvider.notifier).unlock(pin);

    if (!mounted) return;
    final ws = ref.read(walletNotifierProvider).valueOrNull;
    if (ws is! WalletLocked) return;

    _failedAttempts++;
    if (_failedAttempts >= _maxAttempts) {
      context.go('/pin-locked');
      return;
    }
    final remaining = _maxAttempts - _failedAttempts;
    setState(() {
      _errorText = remaining == 1
          ? 'PIN incorrecto. Te queda 1 intento.'
          : 'PIN incorrecto. Te quedan $remaining intentos.';
      _errorNonce++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(walletNotifierProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: PinEntryView(
          title: 'Ingresá tu PIN',
          description:
              'Accedé de forma segura a tu wallet con tu PIN de 6 dígitos.',
          submitLabel: 'Confirmar',
          onSubmit: _onPinCompleted,
          errorText: _errorText,
          errorNonce: _errorNonce,
          isSubmitting: isSubmitting,
        ),
      ),
    );
  }
}
