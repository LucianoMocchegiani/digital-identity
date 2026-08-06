import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// [AppBar] de las pantallas internas que se apilan sobre el navbar (ajustes,
/// acerca de, actividad, conexiones, reiniciar wallet).
///
/// Comparte los tokens de [FlowStepAppBar] —fondo neutro, título 16px semibold y
/// flecha oscura— pero sin barra de progreso: cierra con el mismo borde inferior
/// del [IdentityTopBar] para que la cabecera se lea igual en toda la app.
abstract final class IdentityPageAppBar {
  /// Construye la barra con [title] y [actions] opcionales a la derecha.
  static AppBar build({required String title, List<Widget>? actions}) {
    return AppBar(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textNeutralPrimary,
      leading: const BackButton(color: AppColors.textNeutralPrimary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textNeutralPrimary,
        ),
      ),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.borderNeutral),
      ),
    );
  }
}
