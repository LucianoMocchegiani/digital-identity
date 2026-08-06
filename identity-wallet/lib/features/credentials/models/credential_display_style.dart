import 'package:flutter/material.dart';

/// Estilos visuales de una credencial según metadata OID4VCI del emisor.
///
/// El issuer declara colores y logo en `credentialConfigurationsSupported`
/// → `display[]` (campos `background_color`, `text_color`, `logo.uri`).
/// Tras recibir la credencial vía OID4VCI, `identity_core_dart` persiste ese
/// bloque en [SdJwtVcRecord.displayMetadata] (y equivalentes W3C/mDoc).
///
/// Esta clase parsea ese mapa a tipos Flutter y define el fallback neutro de
/// la app cuando el emisor no envía estilos.
@immutable
class CredentialDisplayStyle {
  const CredentialDisplayStyle({
    this.backgroundColor,
    this.textColor,
    this.logoUrl,
    this.backgroundImageUrl,
  });

  /// Color de fondo de la tarjeta; `null` si el emisor no lo definió.
  final Color? backgroundColor;

  /// Color de textos sobre la tarjeta; `null` si el emisor no lo definió.
  final Color? textColor;

  /// URI HTTP(S) del logo del emisor (`display.logo.uri` o `logo.url`).
  final String? logoUrl;

  /// URI HTTP(S) de la imagen de fondo (`display.background_image.uri`).
  final String? backgroundImageUrl;

  /// Fondo neutro por defecto de [CredentialCard] y [CredentialDetailDrawer].
  static const neutralBackground = Color(0xFFEDEFF2);

  /// Texto neutro por defecto cuando no hay `text_color` del emisor.
  static const neutralForeground = Color(0xFF252B37);

  /// Resuelve el color de fondo aplicando [fallback] y luego [neutralBackground].
  Color resolveBackground(Color? fallback) =>
      backgroundColor ?? fallback ?? neutralBackground;

  /// Resuelve el color de texto aplicando [fallback] y luego [neutralForeground].
  Color resolveForeground(Color? fallback) =>
      textColor ?? fallback ?? neutralForeground;

  /// Convierte un valor hex del metadata OID4VCI a [Color].
  ///
  /// Acepta `#RRGGBB` (opacidad FF) o `#AARRGGBB`. Retorna `null` si el
  /// formato no es válido o [value] no es un string.
  static Color? colorFromHex(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    var hex = value.trim().replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return null;
  }

  /// Extrae la URL del logo desde el objeto `display` del issuer.
  ///
  /// Soporta `logo` como mapa (`uri` / `url`) o como string directo.
  static String? logoUrlFromDisplay(Map<String, dynamic>? display) {
    return imageUrlFromDisplay(display, 'logo');
  }

  /// Extrae la URL de `background_image` desde el objeto `display`.
  static String? backgroundImageUrlFromDisplay(Map<String, dynamic>? display) {
    return imageUrlFromDisplay(display, 'background_image');
  }

  /// Indica si [url] apunta a un bitmap soportado por `Image.network`.
  ///
  /// Ignora query strings (p. ej. `.../foto.jpg?w=740`).
  static bool isRasterImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');
  }

  static String? imageUrlFromDisplay(
    Map<String, dynamic>? display,
    String key,
  ) {
    if (display == null) return null;
    final image = display[key];
    if (image is Map) {
      return image['uri'] as String? ?? image['url'] as String?;
    }
    if (image is String && image.isNotEmpty) return image;
    return null;
  }

  /// Construye estilos a partir de [displayMetadata] de un [CredentialRecord].
  ///
  /// Usado por [CredentialUiMapper.toWalletCredential] y en previews OID4VCI
  /// antes de almacenar la credencial en Isar.
  static CredentialDisplayStyle fromDisplayMetadata(
    Map<String, dynamic>? display,
  ) {
    if (display == null) return const CredentialDisplayStyle();
    return CredentialDisplayStyle(
      backgroundColor: colorFromHex(display['background_color']),
      textColor: colorFromHex(display['text_color']),
      logoUrl: logoUrlFromDisplay(display),
      backgroundImageUrl: backgroundImageUrlFromDisplay(display),
    );
  }
}
