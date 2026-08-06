import 'package:flutter/material.dart';

/// Anillos concéntricos decorativos detrás de un ícono o spinner.
///
/// Replica el patrón del design system (cuatro elipses de 96/144/192/240 con
/// opacidades 0.6/0.4/0.2/0.1, borde `#D5D7DA`). Se usa tanto en el modal de
/// éxito como en el modal de carga de credenciales.
///
/// Devuelve una lista de [Positioned] para insertar dentro de un [Stack]; cada
/// anillo se centra en [center] (coordenadas relativas al Stack).
List<Widget> concentricRings({double center = 40}) {
  const specs = <List<double>>[
    [96, 0.6],
    [144, 0.4],
    [192, 0.2],
    [240, 0.1],
  ];
  return [
    for (final s in specs)
      Positioned(
        left: center - s[0] / 2,
        top: center - s[0] / 2,
        width: s[0],
        height: s[0],
        child: Opacity(
          opacity: s[1],
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD5D7DA)),
            ),
          ),
        ),
      ),
  ];
}
