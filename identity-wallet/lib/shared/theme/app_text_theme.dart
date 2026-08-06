import 'package:flutter/material.dart';

/// Tipografía reutilizada en títulos de página de auth y onboarding.
extension IdentityPageTitleText on TextTheme {
  /// Título de sección basado en [headlineSmall] en negrita.
  TextStyle? get identityPageTitle =>
      headlineSmall?.copyWith(fontWeight: FontWeight.bold);

  /// Título principal tipo bienvenida u héroe ([headlineLarge] en negrita).
  TextStyle? get identityHeroTitle =>
      headlineLarge?.copyWith(fontWeight: FontWeight.bold);
}
