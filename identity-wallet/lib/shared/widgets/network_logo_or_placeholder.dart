import 'package:flutter/material.dart';

import 'app_network_image.dart';

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
    return AppNetworkImage(
      url: url,
      height: height,
      fit: BoxFit.contain,
      placeholder: placeholder,
      error: placeholder,
    );
  }
}
