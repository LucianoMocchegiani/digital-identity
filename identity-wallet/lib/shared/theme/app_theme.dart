import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'kuatia_colors.dart';

/// [ThemeData] light/dark alineados a la web Kuatia.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, KuatiaColors.light);

  static ThemeData dark() => _build(Brightness.dark, KuatiaColors.dark);

  static ThemeData _build(Brightness brightness, KuatiaColors kuatia) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: kuatia.accent,
      onPrimary: isDark ? kuatia.ink : kuatia.ink,
      primaryContainer: kuatia.accentSurface,
      onPrimaryContainer: kuatia.text,
      secondary: kuatia.accent,
      onSecondary: kuatia.ink,
      secondaryContainer: kuatia.accentSurface,
      onSecondaryContainer: kuatia.text,
      tertiary: kuatia.atmosphereMid,
      onTertiary: kuatia.text,
      error: kuatia.dangerIcon,
      onError: kuatia.textOnDark,
      errorContainer: kuatia.errorSurface,
      onErrorContainer: kuatia.errorText,
      surface: kuatia.panel,
      onSurface: kuatia.text,
      surfaceContainerHighest: kuatia.atmosphereMid,
      onSurfaceVariant: kuatia.muted,
      outline: kuatia.border,
      outlineVariant: kuatia.borderSubtle,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? KuatiaColors.light.panel : KuatiaColors.dark.panel,
      onInverseSurface: isDark ? KuatiaColors.light.text : KuatiaColors.dark.text,
      inversePrimary: AppColors.brandPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: kuatia.bg,
      canvasColor: kuatia.bg,
      cardColor: kuatia.panel,
      dividerColor: kuatia.border,
      extensions: [kuatia],
      appBarTheme: AppBarTheme(
        backgroundColor: kuatia.bg,
        foregroundColor: kuatia.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kuatia.accent,
          foregroundColor: kuatia.ink,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kuatia.text,
          side: BorderSide(color: kuatia.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return kuatia.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kuatia.accent;
          return kuatia.border;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: kuatia.accent),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kuatia.accent,
        foregroundColor: kuatia.ink,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kuatia.panel,
        contentTextStyle: TextStyle(color: kuatia.text),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kuatia.panel,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: kuatia.panel,
        surfaceTintColor: Colors.transparent,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: kuatia.text,
        displayColor: kuatia.text,
      ),
    );
  }
}
