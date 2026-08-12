import 'package:flutter/material.dart';

/// Asset de marca Kuatia sin fondo (K + credencial).
const String kKuatiaMarkAsset = 'public/images/logo/kuatia-app-icon.png';

/// Ícono de marca / about (PNG transparente).
class KuatiaAppIcon extends StatelessWidget {
  const KuatiaAppIcon({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kKuatiaMarkAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
