import 'package:flutter/material.dart';

/// Logo remoto con altura fija; si la URL falta o la carga falla, muestra [placeholder].
class NetworkLogoOrPlaceholder extends StatelessWidget {
  const NetworkLogoOrPlaceholder({
    super.key,
    required this.logoUrl,
    required this.placeholder,
    this.height = 80,
  });

  final String? logoUrl;
  final Widget placeholder;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }
    return Image.network(
      url,
      height: height,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
