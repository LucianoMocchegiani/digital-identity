import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../shared/widgets/app_network_image.dart';
import '../models/credential_display_style.dart';

/// Fondo de tarjeta o cabecera de credencial: color sólido + imagen opcional.
///
/// Lee [backgroundImageUrl] del metadata OID4VCI (`display.background_image.uri`).
/// Si la URL no es raster (PNG/JPG/WebP) o falla la carga, queda solo [backgroundColor].
///
/// Con [textColor] y foto, aplica un scrim (degradé) del color de contraste de
/// [textColor] para que el copy del emisor siga legible sin sustituir su color.
///
/// Con [showSheen] añade los reflejos suaves del componente `Credencial-v2`.
class CredentialBackground extends StatelessWidget {
  const CredentialBackground({
    super.key,
    required this.backgroundColor,
    this.backgroundImageUrl,
    this.textColor,
    this.borderRadius = BorderRadius.zero,
    this.showSheen = false,
  });

  final Color backgroundColor;
  final String? backgroundImageUrl;

  /// `text_color` del emisor; solo se usa para orientar el scrim si hay imagen.
  final Color? textColor;

  final BorderRadius borderRadius;
  final bool showSheen;

  @override
  Widget build(BuildContext context) {
    final imageUrl = backgroundImageUrl;
    final showImage =
        imageUrl != null && CredentialDisplayStyle.isRasterImageUrl(imageUrl);
    final scrimFor = textColor;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: backgroundColor),
          if (showImage)
            LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.devicePixelRatioOf(context);
                // Solo ancho: la altura de la card cambia al expandir claims y
                // no debe invalidar la clave de ImageCache.
                final memW = constraints.maxWidth.isFinite
                    ? (constraints.maxWidth * dpr).round()
                    : null;
                return AppNetworkImage(
                  url: imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: memW,
                  error: const SizedBox.shrink(),
                );
              },
            ),
          if (showImage && scrimFor != null) _TextScrim(textColor: scrimFor),
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

/// Degradé de contraste bajo la zona de texto (izquierda / centro).
///
/// Usa [CredentialDisplayStyle.contrastAgainst] del `text_color` del emisor.
class _TextScrim extends StatelessWidget {
  const _TextScrim({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final edge = CredentialDisplayStyle.contrastAgainst(textColor);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              edge.withValues(alpha: 0.52),
              edge.withValues(alpha: 0.28),
              edge.withValues(alpha: 0.08),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
