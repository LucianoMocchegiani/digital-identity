import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón de acción destructiva: fondo rosado, texto rojo y tacho a la izquierda.
///
/// Es el mismo control que usan el detalle de credencial, la edición de
/// categoría y el reinicio de wallet, para que "eliminar" se vea igual en toda
/// la app. Con [isLoading] muestra un indicador y bloquea el toque; con [icon]
/// en `false` se omite el tacho (acciones destructivas que no borran ítems).
class IdentityDangerButton extends StatelessWidget {
  const IdentityDangerButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon = true,
  });

  /// Texto del botón (ej. "Eliminar").
  final String label;

  /// Acción al tocar; en `null` (o mientras [isLoading]) el botón se atenúa.
  final VoidCallback? onTap;

  /// Reemplaza el contenido por un indicador de progreso.
  final bool isLoading;

  /// Muestra el ícono de tacho a la izquierda del texto.
  final bool icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final canTap = onTap != null && !isLoading;

    return Opacity(
      opacity: canTap || isLoading ? 1 : 0.4,
      child: Material(
        color: AppColors.dangerSurface,
        borderRadius: radius,
        child: InkWell(
          onTap: canTap ? onTap : null,
          borderRadius: radius,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 46),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.dangerText,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon) ...[
                        Image.asset(
                          'public/images/icons/Trash-Bin-Trash.png',
                          width: 18,
                          height: 18,
                          color: AppColors.dangerIcon,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          height: 18 / 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dangerText,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
