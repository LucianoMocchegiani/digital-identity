import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón base de la plataforma (componente `Boton-Base`).
///
/// Fondo blanco, borde neutro, sombra suave y label de 14px. Si se pasa [icon]
/// se muestra a la izquierda del texto. [onTap] responde al toque.
///
/// Por defecto es compacto (se ajusta a su contenido), pensado para acciones
/// como "Crear nueva". Con [expand] en `true` ocupa todo el ancho disponible y
/// adopta el alto de un CTA (46px), para usarse como acción secundaria junto a
/// [QuarkPrimaryButton] en una fila de acciones.
class QuarkOutlineButton extends StatelessWidget {
  const QuarkOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = false,
  });

  /// Texto del botón.
  final String label;

  /// Ícono opcional a la izquierda del texto.
  final IconData? icon;

  /// Callback al tocar el botón.
  final VoidCallback? onTap;

  /// Si es `true`, ocupa todo el ancho y el alto de un CTA (acción secundaria).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(expand ? 16 : 8);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          // Compacto: padding ajustado. Expandido: alto de CTA y ancho completo.
          width: expand ? double.infinity : null,
          constraints: expand ? const BoxConstraints(minHeight: 46) : null,
          padding: expand
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: expand ? Alignment.center : null,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.borderNeutral),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(10, 13, 18, 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: const Color(0xFF181D27)),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
                style: const TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textNeutralPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
