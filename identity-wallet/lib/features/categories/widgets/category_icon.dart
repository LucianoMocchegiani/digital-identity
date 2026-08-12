import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';

/// Ícono de categoría legible en light/dark.
///
/// Los assets de línea (`icons/`) van tintados sobre un círculo con el color de
/// la categoría. Los badges ya pintados (`categorias/`) se muestran sin tint.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.asset,
    this.colorArgb,
    this.size = 35,
  });

  final String asset;
  final int? colorArgb;
  final double size;

  bool get _isPrebakedBadge => asset.contains('/categorias/');

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final accent = colorArgb != null
        ? Color(colorArgb!)
        : colors.accent;
    final fill = accent.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.28 : 0.16,
    );

    if (_isPrebakedBadge) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
      );
    }

    final iconSize = size * 0.52;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        asset,
        width: iconSize,
        height: iconSize,
        color: accent,
        colorBlendMode: BlendMode.srcIn,
        fit: BoxFit.contain,
      ),
    );
  }
}
