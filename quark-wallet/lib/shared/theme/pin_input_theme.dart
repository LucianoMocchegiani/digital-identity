import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// Tema visual base para campos PIN ([Pinput]) compartidos entre features.
///
/// Toma colores de [ThemeData.colorScheme] vía [context] para respetar claro/oscuro
/// y el tema global. Define tamaño de celda, tipografía del dígito y borde redondeado.
///
/// Usado por el PIN de la app (auth) y por el ingreso de `tx_code` en OID4VCI, entre otros.
/// Para estado inválido usá [buildPinThemeError].

PinTheme buildPinTheme(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  return PinTheme(
    width: 52,
    height: 60,
    textStyle: TextStyle(fontSize: 22, color: colors.onSurface),
    decoration: BoxDecoration(
      border: Border.all(color: colors.outline),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

/// Tema PIN con realce de error (borde [ColorScheme.error] más grueso).
///
/// Parte de [buildPinTheme] y solo sustituye la [PinTheme.decoration] para feedback
/// visual sin duplicar medidas ni [TextStyle].

PinTheme buildPinThemeError(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  return buildPinTheme(context).copyWith(
    decoration: BoxDecoration(
      border: Border.all(color: colors.error, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
