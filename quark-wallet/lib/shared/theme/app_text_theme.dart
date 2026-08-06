import 'package:flutter/material.dart';

/// Tipografía reutilizada en títulos de página de auth y onboarding.
extension QuarkPageTitleText on TextTheme {
  /// Título de sección basado en [headlineSmall] en negrita.
  TextStyle? get quarkPageTitle =>
      headlineSmall?.copyWith(fontWeight: FontWeight.bold);

  /// Título principal tipo bienvenida u héroe ([headlineLarge] en negrita).
  TextStyle? get quarkHeroTitle =>
      headlineLarge?.copyWith(fontWeight: FontWeight.bold);
}
