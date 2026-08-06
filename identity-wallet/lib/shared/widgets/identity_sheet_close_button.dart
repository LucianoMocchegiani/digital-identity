import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón circular de cierre (`Cross`) de los drawers: disco oscuro translúcido.
///
/// Se posiciona por fuera del sheet, sobre el backdrop oscurecido (`top: -46`
/// dentro de un `Stack` con `Clip.none`), tal como el detalle de credencial y
/// el de actividad.
class IdentitySheetCloseButton extends StatelessWidget {
  const IdentitySheetCloseButton({super.key, required this.onTap});

  /// Acción al tocar; normalmente cierra el bottom sheet.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromRGBO(0, 0, 0, 0.7),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: Image.asset(
              'public/images/icons/Cross.png',
              width: 18,
              height: 18,
              color: AppColors.textOnDark,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
