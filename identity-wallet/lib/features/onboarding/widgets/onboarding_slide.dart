import 'package:flutter/material.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Slide de bienvenida del onboarding (componente `Onboarding-Slide` del diseño).
///
/// Estructura vertical, de arriba hacia abajo:
/// 1. Ilustración centrada en la zona flexible (el PNG ya incluye el círculo de fondo).
/// 2. Indicador de progreso por puntos ([stepIndex] marca el paso activo como píldora).
/// 3. Título y descripción.
/// 4. Botón primario "Siguiente" ([onNext]) y, opcionalmente, "Omitir" ([onSkip]).
///    El último slide oculta "Omitir" pasando [onSkip] en `null`.
///
/// Es un widget de presentación puro: no conoce el [PageController]; quien lo
/// usa (p. ej. `WelcomeSlidesScreen`) decide qué hacen [onNext] y [onSkip].
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.illustrationAsset,
    required this.title,
    required this.description,
    required this.stepIndex,
    required this.stepCount,
    required this.onNext,
    this.onSkip,
    this.nextLabel = 'Siguiente',
    this.skipLabel = 'Omitir',
  });

  /// Ruta del asset de la ilustración (incluye su círculo de fondo).
  final String illustrationAsset;

  /// Título principal del slide (p. ej. "Bienvenido").
  final String title;

  /// Texto descriptivo bajo el título.
  final String description;

  /// Índice (base 0) del paso actual; determina qué punto se muestra activo.
  final int stepIndex;

  /// Cantidad total de puntos del indicador de progreso.
  final int stepCount;

  /// Acción del botón primario "Siguiente".
  final VoidCallback onNext;

  /// Acción del botón secundario "Omitir"; si es `null` el botón no se muestra.
  final VoidCallback? onSkip;

  /// Etiqueta del botón primario.
  final String nextLabel;

  /// Etiqueta del botón secundario.
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ilustración: ocupa el espacio flexible y se escala manteniendo proporción.
          Expanded(
            child: Center(
              child: Image.asset(
                illustrationAsset,
                fit: BoxFit.contain,
                semanticLabel: title,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Bloque inferior: progreso + textos.
          _ProgressDots(stepIndex: stepIndex, stepCount: stepCount),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w400,
              color: colors.muted,
            ),
          ),

          const SizedBox(height: 32),

          // Botonera: "Omitir" (secundario, opcional) y botón primario.
          if (onSkip != null) ...[
            _SlideButton(label: skipLabel, onTap: onSkip!),
            const SizedBox(height: 12),
          ],
          _SlideButton(label: nextLabel, onTap: onNext, primary: true),
        ],
      ),
    );
  }
}

/// Indicador de progreso por puntos: el paso activo es una píldora celeste y
/// el resto círculos grises.
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.stepIndex, required this.stepCount});

  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepCount, (index) {
        final isActive = index == stepIndex;
        return Padding(
          // Separación de 8px entre puntos (sin margen en los extremos).
          padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isActive ? 25.5 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.progressActive
                  : AppColors.borderNeutral,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}

/// Botón a todo el ancho del slide.
///
/// Con [primary] usa teal Kuatia + ink; sin él, panel + texto del tema.
class _SlideButton extends StatelessWidget {
  const _SlideButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final radius = BorderRadius.circular(16);
    final bg = primary ? colors.accent : colors.panel;
    final fg = primary ? colors.ink : colors.text;

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: primary ? null : Border.all(color: colors.border),
            boxShadow: const [kShadowXs],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
