import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón de notificaciones del navbar superior (componente `Notificaciones-BTN`).
///
/// Cuadrado de 32px con radio 8px, borde 1px y fondo neutro. Muestra un badge
/// rojo con [count] cuando es mayor que cero; si [count] es null o 0, el badge
/// se oculta. Al tocarlo dispara [onPressed] (ej. navegar al inbox).
class NotificationButton extends StatelessWidget {
  const NotificationButton({
    super.key,
    this.count,
    this.onPressed,
  });

  /// Cantidad de notificaciones sin leer; el badge se oculta si es null o 0.
  final int? count;

  /// Callback al tocar el botón.
  final VoidCallback? onPressed;

  static const double _size = 32;
  static const double _radius = 8;
  static const String _bellAsset = 'public/images/icons/campana.png';

  @override
  Widget build(BuildContext context) {
    final showBadge = (count ?? 0) > 0;
    final radius = BorderRadius.circular(_radius);

    return Semantics(
      button: true,
      label: 'Notificaciones',
      child: SizedBox(
        width: _size,
        height: _size,
        // Clip.none permite que el badge sobresalga del borde del botón.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.backgroundNeutralSecondary,
              borderRadius: radius,
              child: InkWell(
                onTap: onPressed,
                borderRadius: radius,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: Image.asset(_bellAsset, fit: BoxFit.contain),
                ),
              ),
            ),
            if (showBadge) _NotificationBadge(count: count!),
          ],
        ),
      ),
    );
  }
}

/// Badge rojo con el conteo de notificaciones, anclado a la esquina superior izquierda.
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    // Posición del diseño: sobresale hacia la izquierda y arriba de la campana.
    return Positioned(
      top: -2,
      left: -14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.notificationBadge,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          // TODO: aplicar la familia 'Nunito Sans' al definir la tipografía global.
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}
