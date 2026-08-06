import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// [AppBar] con barra de progreso inferior para pasos de un flujo (OID4VCI, OID4VP, DIDComm).
///
/// Alineado al design system: fondo de superficie neutra, título 16px semibold
/// de la paleta, flecha de retroceso oscura y barra de progreso en color de marca.
abstract final class FlowStepAppBar {
  /// [progress] entre 0 y 1 para [LinearProgressIndicator.value].
  static AppBar build({
    required String title,
    required double progress,
    Widget? leading,
  }) {
    return AppBar(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textNeutralPrimary,
      leading: leading ??
          const BackButton(color: AppColors.textNeutralPrimary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textNeutralPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          color: AppColors.brandPrimary,
          backgroundColor: AppColors.borderNeutral,
        ),
      ),
    );
  }
}
