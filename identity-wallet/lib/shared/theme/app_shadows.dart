import 'package:flutter/material.dart';

/// Sombra `shadow-xs` del design system (`0px 1px 2px rgba(10, 13, 18, 0.05)`).
///
/// Elevación sutil reutilizada en botones, badges y contenedores.
const BoxShadow kShadowXs = BoxShadow(
  color: Color.fromRGBO(10, 13, 18, 0.05),
  offset: Offset(0, 1),
  blurRadius: 2,
);
