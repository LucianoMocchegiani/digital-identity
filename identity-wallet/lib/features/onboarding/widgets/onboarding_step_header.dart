import 'package:flutter/material.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Barra superior compartida del onboarding: botón "atrás" a la izquierda e
/// indicador de pasos centrado.
///
/// El indicador muestra cada paso según su relación con [currentStep] (base 1):
/// completado (círculo azul con check), actual (círculo blanco con número) o
/// futuro (círculo blanco atenuado). La usan las pantallas de PIN y la de
/// generación de credencial.
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  /// Paso actual (base 1).
  final int currentStep;

  /// Cantidad total de pasos.
  final int totalSteps;

  /// Acción del botón "atrás". Si es `null`, no se muestra la flecha (ej. en el
  /// paso final, donde retroceder reabriría la confirmación del PIN ya creado).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: onBack!),
            ),
          _StepIndicator(currentStep: currentStep, totalSteps: totalSteps),
        ],
      ),
    );
  }
}

/// Botón "atrás" (34×26, blanco con borde neutro y sombra suave).
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  static const _arrowAsset = 'public/images/login/Arrow-Left.png';

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: 34,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.borderNeutral),
            boxShadow: const [kShadowXs],
          ),
          child: Image.asset(_arrowAsset, width: 18, height: 18),
        ),
      ),
    );
  }
}

/// Indicador de pasos: círculos unidos por líneas punteadas. Los completados se
/// muestran en azul con check; el actual con su número; los futuros atenuados.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var step = 1; step <= totalSteps; step++) {
      if (step > 1) {
        children.add(const SizedBox(width: 4));
        children.add(const _DashedConnector());
        children.add(const SizedBox(width: 4));
      }
      children.add(_StepCircle(step: step, currentStep: currentStep));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// Círculo de un paso del indicador, con sus tres estados.
class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.step, required this.currentStep});

  final int step;
  final int currentStep;

  static const _doneAsset = 'public/images/login/Unread.png';

  @override
  Widget build(BuildContext context) {
    final isDone = step < currentStep;
    final isCurrent = step == currentStep;

    if (isDone) {
      // Completado: círculo azul con check.
      return Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.progressActive,
          border: Border.all(color: const Color(0xFFF6FEF9)),
          shape: BoxShape.circle,
        ),
        child: Image.asset(_doneAsset, width: 16, height: 16),
      );
    }

    // Actual (opacidad 1) o futuro (atenuado): círculo blanco con número.
    return Opacity(
      opacity: isCurrent ? 1 : 0.3,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutralSecondary,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$step',
          style: const TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textNeutralPrimary,
          ),
        ),
      ),
    );
  }
}

/// Línea punteada de 18px que une dos pasos del indicador.
class _DashedConnector extends StatelessWidget {
  const _DashedConnector();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 2,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

/// Pinta una línea horizontal de guiones grises para el conector de pasos.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5D7DA)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dashWidth = 3.0;
    const gap = 3.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
