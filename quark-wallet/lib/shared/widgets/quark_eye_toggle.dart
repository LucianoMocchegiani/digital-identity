import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ojo de mostrar/ocultar del design system (`Opciones-wrapper`).
///
/// Alterna entre el asset abierto y cerrado según [expanded]. Lo usan la tarjeta
/// de credencial (sobre el fondo del emisor, con [color] y [opacity] propios) y
/// el acordeón de categorías, para que expandir y colapsar se vea igual en toda
/// la app.
class QuarkEyeToggle extends StatelessWidget {
  const QuarkEyeToggle({
    super.key,
    required this.expanded,
    required this.onTap,
    this.color = AppColors.textNeutralSecondary,
    this.opacity = 1,
    this.size = 24,
  });

  /// Estado actual: `true` dibuja el ojo abierto (contenido visible).
  final bool expanded;

  /// Acción al tocar el ojo.
  final VoidCallback onTap;

  /// Color del ícono; sobre tarjetas se pasa el color de texto del emisor.
  final Color color;

  /// Opacidad del ícono (la tarjeta lo atenúa al 40% como el corazón).
  final double opacity;

  /// Lado del ícono en píxeles lógicos.
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          expanded
              ? 'public/images/icons/Opciones-wrapper-open.png'
              : 'public/images/icons/Opciones-wrapper-close.png',
          width: size,
          height: size,
          color: color,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}
