import 'package:flutter/material.dart';

import '../widgets/pin_entry_view.dart';

/// Primer paso de PIN en onboarding (paso 1 de 2): creación de un PIN de 6
/// dígitos con teclado propio ([PinEntryView]).
///
/// Al presionar "Continuar" con los seis dígitos completos llama [onPinCreated]
/// con el PIN (la confirmación se hace en el paso siguiente).
///
/// [onBack] es opcional: no se muestra si los T&C ya fueron aceptados y
/// persistidos, porque volver a [SetupIntroScreen] no aporta y confunde el estado
/// del checkbox.
class PinCreateScreen extends StatelessWidget {
  const PinCreateScreen({
    super.key,
    required this.onPinCreated,
    this.onBack,
  });

  /// Callback con el PIN de seis dígitos al completar el paso.
  final ValueChanged<String> onPinCreated;

  /// Acción del botón "atrás"; `null` oculta la flecha (T&C ya aceptados).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PinEntryView(
      title: 'Creá tu PIN de acceso',
      description:
          'Configurá un PIN de 6 dígitos para acceder de forma rápida y segura '
          'a tu wallet.',
      currentStep: 1,
      totalSteps: 2,
      showWarning: true,
      onBack: onBack,
      onSubmit: onPinCreated,
    );
  }
}
