import 'package:flutter/material.dart';

import '../models/credential_display_style.dart';

/// Logo del emisor en tarjetas y listados de credenciales.
///
/// Carga [logoUrl] remota (PNG/JPG/WebP) o muestra placeholder si falta o falla.
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

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
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

/// Logo del emisor con insignia de verificado opcional.
class CredentialLogoWithBadge extends StatelessWidget {
  const CredentialLogoWithBadge({
    super.key,
    this.logoUrl,
    this.size = 32,
    this.verified = false,
    this.borderColor,
  });

  final String? logoUrl;
  final double size;
  final bool verified;
  final Color? borderColor;

  static const _badgeSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final slot = verified ? size + 4 : size;

    return SizedBox(
      width: slot,
      height: slot,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          CredentialLogo(
            logoUrl: logoUrl,
            size: size,
            borderColor: borderColor,
          ),
          if (verified)
            Positioned(
              left: size - _badgeSize + 2,
              top: size - _badgeSize + 2,
              child: Image.asset(
                'public/images/icons/Badge-wrapper.png',
                width: _badgeSize,
                height: _badgeSize,
              ),
            ),
        ],
      ),
    );
  }
}
