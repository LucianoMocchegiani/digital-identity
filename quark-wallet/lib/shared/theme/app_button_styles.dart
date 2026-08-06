import 'package:flutter/material.dart';

/// Estilos de botones reutilizados en onboarding, auth y diálogos similares.
abstract final class AppButtonStyles {
  static const double _ctaHeight = 52;
  static final BorderRadius _ctaRadius = BorderRadius.circular(14);

  /// [FilledButton] principal (alto fijo y bordes redondeados).
  static ButtonStyle primaryCta(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(_ctaHeight),
      shape: RoundedRectangleBorder(borderRadius: _ctaRadius),
    );
  }

  /// [FilledButton.tonal] para acciones destructivas o de advertencia (p. ej. reset).
  static ButtonStyle tonalDangerCta(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(_ctaHeight),
      shape: RoundedRectangleBorder(borderRadius: _ctaRadius),
      backgroundColor: colors.errorContainer,
      foregroundColor: colors.onErrorContainer,
    );
  }
}
