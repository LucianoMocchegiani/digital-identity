import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Botón primario: ancho completo, teal Kuatia, radio 16, label ink.
///
/// Cuando [enabled] es `false` se atenúa (opacidad 0.4) y deja de responder al
/// toque; se usa para CTAs que requieren completar un paso previo (ej. aceptar
/// términos o completar un PIN).
///
/// Con [isLoading] en `true` muestra un indicador centrado dentro del botón (estilo
/// loading button de MUI) y bloquea nuevos toques hasta que termine la acción.
class IdentityPrimaryButton extends StatelessWidget {
  const IdentityPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  /// Texto del botón; se oculta mientras [isLoading] es `true`.
  final String label;

  /// Acción al tocar (solo activa con [enabled] y sin carga en curso).
  final VoidCallback onTap;

  /// Habilita o atenúa/deshabilita el botón.
  final bool enabled;

  /// Muestra un [CircularProgressIndicator] en lugar del label y deshabilita el toque.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final canTap = enabled && !isLoading;
    final opacity = (enabled || isLoading) ? 1.0 : 0.4;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: AppColors.brandPrimary,
        borderRadius: radius,
        child: InkWell(
          onTap: canTap ? onTap : null,
          borderRadius: radius,
          child: Container(
            // Alto mínimo en lugar de fijo: el botón crece si la fuente del
            // sistema es mayor (textScaleFactor alto) en vez de desbordar.
            constraints: const BoxConstraints(minHeight: 46),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: const [kShadowXs],
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.inkOnAccent,
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 18 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkOnAccent,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
