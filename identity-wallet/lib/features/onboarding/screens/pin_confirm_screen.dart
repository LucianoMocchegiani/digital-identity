import 'package:flutter/material.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../widgets/pin_entry_view.dart';

/// Confirmación del PIN durante el onboarding (paso 2 de 2 del bloque PIN).
///
/// El usuario reingresa el PIN creado en [PinCreateScreen]. La pantalla valida
/// coincidencia localmente y, solo si coincide, delega la creación real de la
/// wallet en [onConfirmed].
///
/// **Orden de operaciones (importante para UX)**
/// 1. Validar que ambos PIN coinciden.
/// 2. Invocar [onConfirmed] → [WalletNotifier.create] en [OnboardingFlow].
/// 3. Mostrar [IdentitySuccessModal] *solo* si la creación fue exitosa.
/// 4. Llamar [onSuccess] para avanzar al paso de credencial opcional.
///
/// Si [onConfirmed] lanza (error de I/O o SDK), se muestra un mensaje de error
/// en [PinEntryView] sin modal de éxito ni avance de página.
class PinConfirmScreen extends StatefulWidget {
  const PinConfirmScreen({
    super.key,
    required this.expectedPin,
    required this.onConfirmed,
    required this.onSuccess,
    required this.onBack,
  });

  /// PIN elegido en [PinCreateScreen]; nunca se persiste fuera de memoria.
  final String expectedPin;

  /// Crea la wallet cifrada con el PIN confirmado.
  ///
  /// Implementado por [OnboardingFlow._onPinConfirmed]. Debe completar solo
  /// tras [WalletNotifier.create] exitoso; lanza en caso contrario.
  final Future<void> Function(String pin) onConfirmed;

  /// Avanza al siguiente índice del [PageView] tras cerrar el modal de éxito.
  final VoidCallback onSuccess;

  /// Vuelve a [PinCreateScreen] sin borrar el progreso de T&C en disco.
  final VoidCallback onBack;

  @override
  State<PinConfirmScreen> createState() => _PinConfirmScreenState();
}

class _PinConfirmScreenState extends State<PinConfirmScreen> {
  /// Incrementa en cada error para disparar el estado visual de [PinEntryView].
  int _errorNonce = 0;

  /// Bloquea teclado y botón mientras [onConfirmed] está en curso.
  bool _submitting = false;

  /// Mensaje de error de creación de wallet; `null` en error de coincidencia.
  String? _submitError;

  Future<void> _onSubmit(String pin) async {
    if (pin != widget.expectedPin) {
      setState(() {
        _errorNonce++;
        _submitError = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      await widget.onConfirmed(pin);
      if (!mounted) return;
      await IdentitySuccessModal.show(
        context,
        title: 'PIN creado correctamente',
        description:
            'Tu PIN fue registrado con éxito. Ya podés continuar con la '
            'configuración de acceso a tu wallet.',
      );
      if (mounted) widget.onSuccess();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError =
            'No pudimos crear la wallet. Verificá el PIN e intentá de nuevo.';
        _errorNonce++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PinEntryView(
      title: 'Reingresá tu PIN',
      description:
          'Ingresá nuevamente tu PIN para confirmar tu acceso seguro a la wallet.',
      currentStep: 1,
      totalSteps: 2,
      submitLabel: 'Confirmar',
      onBack: widget.onBack,
      onSubmit: _onSubmit,
      errorText: _submitError ?? 'El código ingresado no coincide',
      errorNonce: _errorNonce,
      isSubmitting: _submitting,
    );
  }
}
