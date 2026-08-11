import 'package:flutter/material.dart';

import 'kuatia_colors.dart';

/// Tokens de color del design system.
///
/// Los getters leen la paleta bindeada al tema activo ([bind] desde
/// [MaterialApp.builder]). Así home/menú/modales que aún usan `AppColors.*`
/// siguen light/dark sin reescribir cada archivo.
///
/// Preferir `context.kuatia` en código nuevo.
abstract final class AppColors {
  static KuatiaColors _bound = KuatiaColors.dark;

  /// Actualiza la paleta estática al tema Material vigente.
  static void bind(KuatiaColors colors) => _bound = colors;

  static Color get backgroundNeutralSecondary => _bound.bg;
  static Color get panel => _bound.panel;
  static Color get borderNeutral => _bound.border;
  static Color get textNeutralPrimary => _bound.text;
  static Color get textNeutralMuted => _bound.muted;
  static Color get textNeutralSecondary => _bound.muted;
  static Color get brandPrimary => _bound.accent;
  static Color get accentBlue => _bound.accent;
  static Color get accentBlueSurface => _bound.accentSurface;
  static Color get progressActive => _bound.progressActive;
  static Color get checkboxCheckedFill => _bound.checkboxCheckedFill;
  static Color get linkBlue => _bound.link;
  static Color get warningSurface => _bound.warningSurface;
  static Color get warningText => _bound.warningText;
  static Color get errorDot => _bound.errorDot;
  static Color get errorSurface => _bound.errorSurface;
  static Color get errorText => _bound.errorText;
  static Color get notificationBadge => _bound.notificationBadge;
  static Color get dangerSurface => _bound.dangerSurface;
  static Color get dangerText => _bound.dangerText;
  static Color get dangerIcon => _bound.dangerIcon;
  static Color get scanSuccessFrame => _bound.scanSuccessFrame;
  static Color get successSurface => _bound.successSurface;
  static Color get successIcon => _bound.successIcon;
  static Color get successText => _bound.successText;
  static Color get textOnDark => _bound.textOnDark;
  static Color get inkOnAccent => _bound.ink;
}
