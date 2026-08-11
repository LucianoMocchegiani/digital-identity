import 'package:flutter/material.dart';

/// Sombra `shadow-xs` del design system (`0px 1px 2px rgba(10, 13, 18, 0.05)`).
///
/// Elevación sutil reutilizada en botones, badges y contenedores.
const BoxShadow kShadowXs = BoxShadow(
  color: Color.fromRGBO(10, 13, 18, 0.05),
  offset: Offset(0, 1),
  blurRadius: 2,
);

/// Glow celeste alrededor de tarjetas de credencial (light/dark).
List<BoxShadow> kCredentialCelesteShadow(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return [
    BoxShadow(
      color: const Color(0xFF7DD3FC).withValues(alpha: dark ? 0.28 : 0.45),
      offset: const Offset(0, 6),
      blurRadius: dark ? 22 : 18,
      spreadRadius: dark ? 0 : 1,
    ),
    BoxShadow(
      color: const Color(0xFF00A89D).withValues(alpha: dark ? 0.18 : 0.12),
      offset: const Offset(0, 2),
      blurRadius: 10,
    ),
  ];
}
