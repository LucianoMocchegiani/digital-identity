import 'package:flutter/material.dart';

import '../../../shared/quark_shared.dart';

/// Estado vacío de la vista de credenciales (componente `Empty state`).
///
/// Centra la ilustración del wallet, un título y descripción atenuados, y un
/// botón para añadir una credencial. [onAddCredential] se dispara al tocarlo.
class EmptyCredentialsView extends StatelessWidget {
  const EmptyCredentialsView({super.key, this.onAddCredential});

  /// Callback al tocar el botón "Añadir credencial".
  final VoidCallback? onAddCredential;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'public/images/icons/wallet-empty.png',
              width: 92.11,
              height: 127.92,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            // Bloque de texto principal (título + descripción), gap 4px.
            const Text(
              'Tu wallet está vacía',
              // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textNeutralMuted,
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 222,
              child: Text(
                'Tus credenciales digitales aparecerán aquí una vez que las '
                'hayas incorporado a tu wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textNeutralMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            QuarkOutlineButton(
              label: 'Añadir credencial',
              icon: Icons.add,
              onTap: onAddCredential,
            ),
          ],
        ),
      ),
    );
  }
}
