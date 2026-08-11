import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ojo de mostrar/ocultar del design system (`Opciones-wrapper`).
class IdentityEyeToggle extends StatelessWidget {
  const IdentityEyeToggle({
    super.key,
    required this.expanded,
    required this.onTap,
    this.color,
    this.opacity = 1,
    this.size = 24,
  });

  final bool expanded;
  final VoidCallback onTap;
  final Color? color;
  final double opacity;
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
          color: color ?? AppColors.textNeutralSecondary,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}
