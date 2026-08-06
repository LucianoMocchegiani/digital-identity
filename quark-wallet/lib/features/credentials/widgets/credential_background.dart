import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/credential_display_style.dart';

/// Fondo de tarjeta o cabecera de credencial: color sólido + imagen opcional.
///
/// Lee [backgroundImageUrl] del metadata OID4VCI (`display.background_image.uri`).
/// Si la URL no es raster (PNG/JPG/WebP) o falla la carga, queda solo [backgroundColor].
///
/// Con [showSheen] añade los reflejos suaves del componente `Credencial-v2`.
class CredentialBackground extends StatelessWidget {
  const CredentialBackground({
    super.key,
    required this.backgroundColor,
    this.backgroundImageUrl,
    this.borderRadius = BorderRadius.zero,
    this.showSheen = false,
  });

  final Color backgroundColor;
  final String? backgroundImageUrl;
  final BorderRadius borderRadius;
  final bool showSheen;

  @override
  Widget build(BuildContext context) {
    final imageUrl = backgroundImageUrl;
    final showImage =
        imageUrl != null && CredentialDisplayStyle.isRasterImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: backgroundColor),
          if (showImage)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          if (showSheen) ...[
            _sheen(left: 200, top: -61, color: Colors.white.withValues(alpha: 0.25)),
            _sheen(left: -6, top: 53, color: Colors.black.withValues(alpha: 0.05)),
          ],
        ],
      ),
    );
  }

  Widget _sheen({required double left, required double top, required Color color}) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Transform.rotate(
            angle: -0.776,
            child: Container(
              width: 103,
              height: 136,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
