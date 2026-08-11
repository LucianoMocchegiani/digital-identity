import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../core/providers/wallet_notifier.dart';

/// Pantalla para **borrar por completo** la wallet del dispositivo (`/home/menu/reset`).
///
/// Explica el riesgo y ofrece un [IdentityDangerButton] que abre el
/// [IdentityConfirmModal] compartido. Si el usuario acepta, llama a
/// [WalletNotifier.reset]; el estado pasa a [WalletNotConfigured] y el
/// [GoRouter.redirect] de [routerProvider] envía a onboarding sin `context.go`
/// manual.
///
/// Durante la operación el botón queda en estado de carga y deja de responder.
class ResetWalletScreen extends ConsumerStatefulWidget {
  const ResetWalletScreen({super.key});

  @override
  ConsumerState<ResetWalletScreen> createState() => _ResetWalletScreenState();
}

class _ResetWalletScreenState extends ConsumerState<ResetWalletScreen> {
  bool _resetting = false;

  /// Confirmación y, si acepta, [WalletNotifier.reset] con UI de progreso.
  Future<void> _confirmReset() async {
    final confirmed = await IdentityConfirmModal.show(
      context,
      title: '¿Reiniciar wallet?',
      description:
          'Se eliminarán todas las credenciales, claves y datos del wallet. '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'Reiniciar',
    );
    if (!confirmed || !mounted) return;

    setState(() => _resetting = true);
    await ref.read(walletNotifierProvider.notifier).reset();
    // El redirect del router lleva a onboarding al quedar WalletNotConfigured.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      appBar: IdentityPageAppBar.build(title: 'Reiniciar wallet'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: IdentityCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.warningSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 32,
                          color: AppColors.warningText,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Esto eliminará permanentemente todos tus datos del wallet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 22 / 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textNeutralPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No podrás recuperar tus credenciales después de reiniciar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 18 / 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textNeutralSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            IdentityDangerButton(
              label: 'Reiniciar wallet',
              isLoading: _resetting,
              onTap: _confirmReset,
            ),
          ],
        ),
      ),
    );
  }
}
