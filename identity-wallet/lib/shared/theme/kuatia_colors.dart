import 'package:flutter/material.dart';

/// Paleta Kuatia (alineada a web: charcoal + teal `#00a89d`).
///
/// Se registra como [ThemeExtension] en light/dark. Preferir
/// `context.kuatia` en widgets con [BuildContext]; los estáticos de
/// [AppColors] siguen siendo el tema claro (const / tests).
@immutable
class KuatiaColors extends ThemeExtension<KuatiaColors> {
  const KuatiaColors({
    required this.bg,
    required this.panel,
    required this.text,
    required this.muted,
    required this.accent,
    required this.ink,
    required this.border,
    required this.borderSubtle,
    required this.hover,
    required this.atmosphereMid,
    required this.warningSurface,
    required this.warningText,
    required this.errorDot,
    required this.errorSurface,
    required this.errorText,
    required this.dangerSurface,
    required this.dangerText,
    required this.dangerIcon,
    required this.successSurface,
    required this.successIcon,
    required this.successText,
    required this.scanSuccessFrame,
    required this.notificationBadge,
    required this.textOnDark,
    required this.accentSurface,
    required this.progressActive,
    required this.checkboxCheckedFill,
    required this.link,
  });

  final Color bg;
  final Color panel;
  final Color text;
  final Color muted;
  final Color accent;
  final Color ink;
  final Color border;
  final Color borderSubtle;
  final Color hover;
  final Color atmosphereMid;
  final Color warningSurface;
  final Color warningText;
  final Color errorDot;
  final Color errorSurface;
  final Color errorText;
  final Color dangerSurface;
  final Color dangerText;
  final Color dangerIcon;
  final Color successSurface;
  final Color successIcon;
  final Color successText;
  final Color scanSuccessFrame;
  final Color notificationBadge;
  final Color textOnDark;
  final Color accentSurface;
  final Color progressActive;
  final Color checkboxCheckedFill;
  final Color link;

  /// Tema claro (web `[data-theme=light]`).
  static const light = KuatiaColors(
    bg: Color(0xFFEEF3F5),
    panel: Color(0xFFFFFFFF),
    text: Color(0xFF0C1520),
    muted: Color(0xFF5C6D7E),
    accent: Color(0xFF00968C),
    ink: Color(0xFF041016),
    border: Color(0x1F0C1520),
    borderSubtle: Color(0x120C1520),
    hover: Color(0x0F0C1520),
    atmosphereMid: Color(0xFFE4ECEF),
    warningSurface: Color(0xFFFFFAEB),
    warningText: Color(0xFF93370D),
    errorDot: Color(0xFFF97066),
    errorSurface: Color(0xFFFEF3F2),
    errorText: Color(0xFF912018),
    dangerSurface: Color(0xFFFEE4E2),
    dangerText: Color(0xFFF04438),
    dangerIcon: Color(0xFFD92D20),
    successSurface: Color(0xFFECFDF3),
    successIcon: Color(0xFF12B76A),
    successText: Color(0xFF05603A),
    scanSuccessFrame: Color(0xFF32D583),
    notificationBadge: Color(0xFFE74C3C),
    textOnDark: Color(0xFFF3F7F8),
    accentSurface: Color(0x1A00968C),
    progressActive: Color(0xFF00A89D),
    checkboxCheckedFill: Color(0xFF00A89D),
    link: Color(0xFF00968C),
  );

  /// Tema oscuro (web default / `[data-theme=dark]`).
  static const dark = KuatiaColors(
    bg: Color(0xFF050A10),
    panel: Color(0xFF0B1520),
    text: Color(0xFFF3F7F8),
    muted: Color(0xFF8B9AAB),
    accent: Color(0xFF00A89D),
    ink: Color(0xFF041016),
    border: Color(0x1AFFFFFF),
    borderSubtle: Color(0x0DFFFFFF),
    hover: Color(0x0FFFFFFF),
    atmosphereMid: Color(0xFF071018),
    warningSurface: Color(0xFF2A2110),
    warningText: Color(0xFFFEC84B),
    errorDot: Color(0xFFF97066),
    errorSurface: Color(0xFF2A1215),
    errorText: Color(0xFFFDA29B),
    dangerSurface: Color(0xFF2A1215),
    dangerText: Color(0xFFF97066),
    dangerIcon: Color(0xFFF04438),
    successSurface: Color(0xFF0C1F17),
    successIcon: Color(0xFF32D583),
    successText: Color(0xFFA6F4C5),
    scanSuccessFrame: Color(0xFF32D583),
    notificationBadge: Color(0xFFE74C3C),
    textOnDark: Color(0xFFF3F7F8),
    accentSurface: Color(0x2900A89D),
    progressActive: Color(0xFF00A89D),
    checkboxCheckedFill: Color(0xFF00A89D),
    link: Color(0xFF00A89D),
  );

  @override
  KuatiaColors copyWith({
    Color? bg,
    Color? panel,
    Color? text,
    Color? muted,
    Color? accent,
    Color? ink,
    Color? border,
    Color? borderSubtle,
    Color? hover,
    Color? atmosphereMid,
    Color? warningSurface,
    Color? warningText,
    Color? errorDot,
    Color? errorSurface,
    Color? errorText,
    Color? dangerSurface,
    Color? dangerText,
    Color? dangerIcon,
    Color? successSurface,
    Color? successIcon,
    Color? successText,
    Color? scanSuccessFrame,
    Color? notificationBadge,
    Color? textOnDark,
    Color? accentSurface,
    Color? progressActive,
    Color? checkboxCheckedFill,
    Color? link,
  }) {
    return KuatiaColors(
      bg: bg ?? this.bg,
      panel: panel ?? this.panel,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      ink: ink ?? this.ink,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      hover: hover ?? this.hover,
      atmosphereMid: atmosphereMid ?? this.atmosphereMid,
      warningSurface: warningSurface ?? this.warningSurface,
      warningText: warningText ?? this.warningText,
      errorDot: errorDot ?? this.errorDot,
      errorSurface: errorSurface ?? this.errorSurface,
      errorText: errorText ?? this.errorText,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      dangerText: dangerText ?? this.dangerText,
      dangerIcon: dangerIcon ?? this.dangerIcon,
      successSurface: successSurface ?? this.successSurface,
      successIcon: successIcon ?? this.successIcon,
      successText: successText ?? this.successText,
      scanSuccessFrame: scanSuccessFrame ?? this.scanSuccessFrame,
      notificationBadge: notificationBadge ?? this.notificationBadge,
      textOnDark: textOnDark ?? this.textOnDark,
      accentSurface: accentSurface ?? this.accentSurface,
      progressActive: progressActive ?? this.progressActive,
      checkboxCheckedFill: checkboxCheckedFill ?? this.checkboxCheckedFill,
      link: link ?? this.link,
    );
  }

  @override
  KuatiaColors lerp(ThemeExtension<KuatiaColors>? other, double t) {
    if (other is! KuatiaColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return KuatiaColors(
      bg: l(bg, other.bg),
      panel: l(panel, other.panel),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      accent: l(accent, other.accent),
      ink: l(ink, other.ink),
      border: l(border, other.border),
      borderSubtle: l(borderSubtle, other.borderSubtle),
      hover: l(hover, other.hover),
      atmosphereMid: l(atmosphereMid, other.atmosphereMid),
      warningSurface: l(warningSurface, other.warningSurface),
      warningText: l(warningText, other.warningText),
      errorDot: l(errorDot, other.errorDot),
      errorSurface: l(errorSurface, other.errorSurface),
      errorText: l(errorText, other.errorText),
      dangerSurface: l(dangerSurface, other.dangerSurface),
      dangerText: l(dangerText, other.dangerText),
      dangerIcon: l(dangerIcon, other.dangerIcon),
      successSurface: l(successSurface, other.successSurface),
      successIcon: l(successIcon, other.successIcon),
      successText: l(successText, other.successText),
      scanSuccessFrame: l(scanSuccessFrame, other.scanSuccessFrame),
      notificationBadge: l(notificationBadge, other.notificationBadge),
      textOnDark: l(textOnDark, other.textOnDark),
      accentSurface: l(accentSurface, other.accentSurface),
      progressActive: l(progressActive, other.progressActive),
      checkboxCheckedFill: l(checkboxCheckedFill, other.checkboxCheckedFill),
      link: l(link, other.link),
    );
  }
}

/// Acceso corto a la paleta Kuatia del tema activo.
extension KuatiaColorsContext on BuildContext {
  KuatiaColors get kuatia =>
      Theme.of(this).extension<KuatiaColors>() ?? KuatiaColors.light;
}
