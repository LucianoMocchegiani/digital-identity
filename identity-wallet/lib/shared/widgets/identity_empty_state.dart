import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estado vacío centrado: ícono atenuado, título y texto de ayuda.
///
/// Unifica el "no hay nada todavía" de las pantallas internas (actividad,
/// conexiones) con los tokens del design system.
class IdentityEmptyState extends StatelessWidget {
  const IdentityEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Ícono ilustrativo sobre el título.
  final IconData icon;

  /// Título breve (ej. "Sin actividad aún").
  final String title;

  /// Texto que explica qué va a aparecer acá.
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textNeutralMuted),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textNeutralPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textNeutralSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
