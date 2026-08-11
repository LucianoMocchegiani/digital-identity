import 'package:flutter/material.dart';

import 'credential_display_style.dart';

/// Modelo de presentación de una credencial para la capa UI.
///
/// Agrupa los datos mínimos para [CredentialCard], [CredentialDetailDrawer] y
/// listados en categorías. Se construye desde [CredentialRecord] del SDK
/// mediante [CredentialUiMapper]; no incluye favoritas ni categorías (eso
/// vive en [WalletUxData]).
///
/// **Estilos OID4VCI**
/// [backgroundColor], [textColor], [logoUrl] y [backgroundImageUrl] provienen de
/// `displayMetadata`
/// del emisor. Si faltan, [resolvedBackground] y [resolvedForeground] aplican
/// el tema neutro definido en [CredentialDisplayStyle].
@immutable
class WalletCredential {
  const WalletCredential({
    this.id,
    required this.title,
    required this.issuer,
    this.details = const [],
    this.logoUrl,
    this.backgroundColor,
    this.backgroundImageUrl,
    this.textColor,
    this.verified = false,
  });

  /// Identificador de [CredentialRecord.id] del SDK; `null` en instancias transitorias.
  final String? id;

  /// Nombre de la credencial (ej. "Partida de nacimiento").
  final String title;

  /// Entidad emisora (ej. "Gobierno de la Ciudad de Buenos Aires").
  final String issuer;

  /// Datos adicionales que se muestran al expandir (ej. nombre, número).
  final List<String> details;

  /// URL remota del logo (metadata OID4VCI `display.logo.uri`).
  final String? logoUrl;

  /// Color de fondo de la tarjeta (`display.background_color`).
  final Color? backgroundColor;

  /// Imagen de fondo de la tarjeta (`display.background_image.uri`).
  final String? backgroundImageUrl;

  /// Color de textos de la tarjeta (`display.text_color`).
  final Color? textColor;

  /// Si la credencial está verificada (muestra la insignia).
  final bool verified;

  /// Color de fondo efectivo: metadata del emisor o neutro del tema.
  Color resolvedBackground([Brightness brightness = Brightness.dark]) {
    if (backgroundColor != null) return backgroundColor!;
    return CredentialDisplayStyle.neutralFor(brightness).$1;
  }

  /// Color de texto efectivo: metadata del emisor o neutro del tema.
  Color resolvedForeground([Brightness brightness = Brightness.dark]) {
    if (textColor != null) return textColor!;
    return CredentialDisplayStyle.neutralFor(brightness).$2;
  }

  /// Copia con los campos indicados reemplazados (útil en tests y previews).
  WalletCredential copyWith({
    String? id,
    String? title,
    String? issuer,
    List<String>? details,
    String? logoUrl,
    Color? backgroundColor,
    String? backgroundImageUrl,
    Color? textColor,
    bool? verified,
  }) {
    return WalletCredential(
      id: id ?? this.id,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      details: details ?? this.details,
      logoUrl: logoUrl ?? this.logoUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      textColor: textColor ?? this.textColor,
      verified: verified ?? this.verified,
    );
  }
}
