import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Superficie blanca del design system: radio 12, borde neutro y sombra `xs`.
///
/// Es el contenedor base de los bloques de contenido (grupos del menú, filas de
/// ajustes, panel de detalles de una credencial). Con [padding] en `null` el
/// hijo llega hasta el borde, útil cuando adentro hay filas con divisores.
class QuarkCard extends StatelessWidget {
  const QuarkCard({super.key, required this.child, this.padding});

  /// Contenido de la tarjeta.
  final Widget child;

  /// Relleno interno; en `null` no agrega ninguno.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutral),
        boxShadow: const [kShadowXs],
      ),
      child: child,
    );
  }
}
