import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';
import 'notification_button.dart';

/// Navbar superior fijo de la app (componente `Top-Menu`).
///
/// Barra sin marca: solo el [NotificationButton] alineado a la derecha.
class IdentityTopBar extends StatelessWidget implements PreferredSizeWidget {
  const IdentityTopBar({
    super.key,
    this.notificationCount,
    this.onNotificationsPressed,
    this.showNotifications = false,
  });

  final int? notificationCount;
  final VoidCallback? onNotificationsPressed;
  final bool showNotifications;

  static const double _height = 48;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Container(
      decoration: ShapeDecoration(
        color: colors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          side: BorderSide(color: colors.border),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showNotifications)
                  NotificationButton(
                    count: notificationCount ?? 0,
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
