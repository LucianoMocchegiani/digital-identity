import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'notification_button.dart';

/// Navbar superior fijo de la app (componente `Top-Menu`).
///
/// Barra sin marca: solo el [NotificationButton] alineado a la derecha.
/// Implementa [PreferredSizeWidget] para colocarse en `Scaffold.appBar` y
/// mantenerse consistente en todas las pantallas.
///
/// [notificationCount] es el conteo que se muestra en el badge de la campana.
/// [onNotificationsPressed] se dispara al tocar la campana (ej. abrir el inbox).
class IdentityTopBar extends StatelessWidget implements PreferredSizeWidget {
  const IdentityTopBar({
    super.key,
    this.notificationCount,
    this.onNotificationsPressed,
    this.showNotifications = false,
  });

  /// Conteo de notificaciones a mostrar en el badge de la campana.
  final int? notificationCount;

  /// Callback al tocar la campana.
  final VoidCallback? onNotificationsPressed;

  /// Muestra el botón de notificaciones (campana).
  // TODO: volver a `true` cuando el inbox tenga funcionalidad útil; oculto por ahora.
  final bool showNotifications;

  static const double _height = 48;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    // Fondo blanco con borde y esquinas inferiores redondeadas (12px). El borde
    // superior y laterales quedan al ras de la pantalla, por lo que solo se ve
    // el borde inferior, tal como el `border-bottom` del diseño.
    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          side: BorderSide(color: AppColors.borderNeutral),
        ),
      ),
      // SafeArea (solo arriba) reserva el espacio de la status bar; el cuerpo de
      // la pantalla comienza por debajo de la altura efectiva del navbar.
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Campana oculta temporalmente hasta que el inbox sea útil.
                if (showNotifications)
                  NotificationButton(
                    count: notificationCount,
                    onPressed: onNotificationsPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
