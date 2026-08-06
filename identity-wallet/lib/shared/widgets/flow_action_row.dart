import 'package:flutter/material.dart';

import 'identity_outline_button.dart';
import 'identity_primary_button.dart';

/// Fila estándar cancelar + acción principal (ancho expandido, 12 px de separación).
///
/// Usa los botones del design system: [IdentityOutlineButton] (expandido) para
/// cancelar y [IdentityPrimaryButton] para la acción principal. Si [onPrimary] es
/// `null`, el botón principal queda deshabilitado.
class FlowActionRow extends StatelessWidget {
  const FlowActionRow({
    super.key,
    required this.onCancel,
    this.onPrimary,
    this.cancelLabel = 'Cancelar',
    this.primaryLabel = 'Continuar',
  });

  final VoidCallback onCancel;

  /// Si es null, el botón principal queda deshabilitado.
  final VoidCallback? onPrimary;

  final String cancelLabel;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IdentityOutlineButton(
            label: cancelLabel,
            onTap: onCancel,
            expand: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: IdentityPrimaryButton(
            label: primaryLabel,
            enabled: onPrimary != null,
            onTap: onPrimary ?? () {},
          ),
        ),
      ],
    );
  }
}
