import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';

/// Estado vacío de la vista de credenciales.
class EmptyCredentialsView extends StatelessWidget {
  const EmptyCredentialsView({super.key, this.onAddCredential});

  final VoidCallback? onAddCredential;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
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
            Text(
              'Tu wallet está vacía',
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 222,
              child: Text(
                'Tus credenciales digitales aparecerán aquí una vez que las '
                'hayas incorporado a tu wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: colors.muted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            IdentityOutlineButton(
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
