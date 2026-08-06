import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../../core/providers/wallet_notifier.dart';

/// Pantalla de **wallet bloqueada** por demasiados intentos fallidos de PIN.
///
/// Se llega desde [AuthenticateScreen] al superar el máximo de intentos; la ruta es
/// `/pin-locked` en [routerProvider]. No ofrece reintento de PIN: solo informa y
/// permite **resetear** la wallet con [WalletNotifier.reset], lo que deja
/// [WalletNotConfigured] y el [GoRouter.redirect] envía de nuevo a onboarding.

class PinLockedScreen extends ConsumerWidget {
  const PinLockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kAuthOnboardingScreenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 96, color: colors.error),
              const SizedBox(height: 24),
              Text(
                'Wallet bloqueada',
                style: text.quarkPageTitle,
              ),
              const SizedBox(height: 12),
              Text(
                'Superaste los intentos máximos de PIN.\nPara recuperar el acceso debés resetear tu wallet.\n\nTus credenciales se perderán.',
                style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.tonal(
                onPressed: () => _confirmReset(context, ref),
                style: AppButtonStyles.tonalDangerCta(context),
                child: const Text('Resetear wallet', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pide confirmación en un [AlertDialog]; si acepta, llama a [WalletNotifier.reset].
  ///
  /// Tras el reset, el estado global pasa a [WalletNotConfigured] y el redirect del
  /// router lleva a `/onboarding` sin navegación manual extra.

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Resetear wallet?'),
        content: const Text('Todas las credenciales almacenadas se eliminarán del dispositivo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(walletNotifierProvider.notifier).reset();
      // GoRouter redirige a /onboarding automáticamente tras WalletNotConfigured.
    }
  }
}
