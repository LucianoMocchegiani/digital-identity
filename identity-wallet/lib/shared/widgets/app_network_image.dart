import 'package:flutter/material.dart';

/// Imagen remota con la [ImageCache] de Flutter (memoria).
///
/// Usa [gaplessPlayback] y un [frameBuilder] que no sustituye la imagen por un
/// hueco vacío en cada rebuild: si la URL ya está en cache, se pinta al
/// instante al volver a la pantalla.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// [ImageProvider] alineado con lo que pinta este widget (misma clave de cache).
  static ImageProvider providerFor(
    BuildContext context, {
    required String url,
    double? width,
    double? height,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = memCacheWidth ??
        (width != null && width.isFinite ? (width * dpr).round() : null);
    final cacheHeight = memCacheHeight ??
        (height != null && height.isFinite ? (height * dpr).round() : null);

    ImageProvider provider = NetworkImage(url);
    if (cacheWidth != null || cacheHeight != null) {
      provider = ResizeImage(
        provider,
        width: cacheWidth,
        height: cacheHeight,
        allowUpscaling: false,
      );
    }
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: providerFor(
        context,
        url: url,
        width: width,
        height: height,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
      ),
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) =>
          error ?? placeholder ?? const SizedBox.shrink(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        // Sin placeholder: no vaciar el frame (evita flash del color de fondo
        // en cards al volver del menú). Con placeholder: solo en cold load.
        return placeholder ?? child;
      },
    );
  }
}
