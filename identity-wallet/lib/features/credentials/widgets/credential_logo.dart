import 'package:flutter/material.dart';

import '../../../shared/widgets/app_network_image.dart';
import '../models/credential_display_style.dart';

/// Logo del emisor en tarjetas y listados de credenciales.
///
/// Carga [logoUrl] remota (PNG/JPG/WebP) con cache en memoria, o muestra
/// placeholder si falta o falla.
class CredentialLogo extends StatelessWidget {
  const CredentialLogo({
    super.key,
    this.logoUrl,
    this.size = 32,
    this.radius = 8,
    this.borderColor,
  });

  final String? logoUrl;
  final double size;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.black.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: _buildInner() ?? _placeholder(),
      ),
    );
  }

  Widget? _buildInner() {
    final url = logoUrl;
    if (url == null || url.isEmpty) return null;

    if (!CredentialDisplayStyle.isRasterImageUrl(url)) {
      return null;
    }

    return AppNetworkImage(
      url: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: _placeholder(),
      error: _placeholder(),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.badge_outlined,
      size: size * 0.55,
      color: Colors.black.withValues(alpha: 0.35),
    );
  }
}
