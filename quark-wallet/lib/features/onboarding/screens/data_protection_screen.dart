import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

/// Último paso del onboarding: mensajes informativos sobre almacenamiento local y consentimiento.
///
/// Tres bloques fijos ([_InfoTile]) y el botón "Crear wallet", que ejecuta [onComplete].
/// Quien monta el flujo (p. ej. [OnboardingFlow]) suele crear la wallet en ese callback.
class DataProtectionScreen extends ConsumerWidget {
  const DataProtectionScreen({super.key, required this.onComplete});

  /// Invocado al pulsar "Crear wallet" (creación de wallet y navegación la define el padre).
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: kAuthOnboardingScreenPadding,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.lock_outline_rounded, size: 64, color: colors.primary),
          const SizedBox(height: 24),
          Text(
            'Protección de datos',
            style: text.quarkPageTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: const [
                _InfoTile(
                  icon: Icons.phone_android,
                  title: 'Todo en tu dispositivo',
                  body: 'Las credenciales se almacenan cifradas únicamente en tu teléfono.',
                ),
                _InfoTile(
                  icon: Icons.cloud_off,
                  title: 'Sin servidores',
                  body: 'La wallet no envía tus credenciales a ningún servidor.',
                ),
                _InfoTile(
                  icon: Icons.visibility_off_outlined,
                  title: 'Consentimiento explícito',
                  body: 'Siempre vas a ver qué datos se comparten antes de confirmar.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onComplete,
            style: AppButtonStyles.primaryCta(context),
            child: const Text('Crear wallet', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Fila con ícono, título y cuerpo para los puntos de la pantalla de protección de datos.
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
