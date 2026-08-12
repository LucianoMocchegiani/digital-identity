import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

const _kBiometricsKey = 'biometrics_enabled';
const _storage = FlutterSecureStorage();

final _biometricsEnabledProvider = FutureProvider<bool>((ref) async {
  final value = await _storage.read(key: _kBiometricsKey);
  return value == 'true';
});

/// Ajustes: biometría, tema y permiso de cámara (vía ajustes del sistema).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricsAsync = ref.watch(_biometricsEnabledProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colors = context.kuatia;

    return KuatiaScaffold(
      appBar: IdentityPageAppBar.build(title: 'Ajustes'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        children: [
          IdentityCard(
            child: biometricsAsync.when(
              loading: () => const _BiometricsRow(
                enabled: false,
                loading: true,
                onChanged: null,
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (enabled) => _BiometricsRow(
                enabled: enabled,
                onChanged: (value) => _toggleBiometrics(context, ref, value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          IdentityCard(
            child: _CameraPermissionRow(
              onOpenSettings: () => AppSettings.openAppSettings(
                type: AppSettingsType.settings,
              ),
            ),
          ),
          const SizedBox(height: 12),
          IdentityCard(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apariencia',
                  style: TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elegí claro u oscuro',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Claro'),
                      icon: Icon(Icons.light_mode_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Oscuro'),
                      icon: Icon(Icons.dark_mode_outlined, size: 18),
                    ),
                  ],
                  selected: {
                    themeMode == ThemeMode.light
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  },
                  onSelectionChanged: (next) {
                    ref.read(themeModeProvider.notifier).setMode(next.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: WidgetStatePropertyAll(colors.text),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return colors.accentSurface;
                      }
                      return colors.hover;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometrics(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    if (enable) {
      final auth = LocalAuthentication();
      final available = await auth.canCheckBiometrics;
      if (!available) {
        if (context.mounted) {
          showAppSnackBar(context, 'Biometría no disponible en este dispositivo.');
        }
        return;
      }
    }
    await _storage.write(key: _kBiometricsKey, value: enable.toString());
    ref.invalidate(_biometricsEnabledProvider);
  }
}

class _BiometricsRow extends StatelessWidget {
  const _BiometricsRow({
    required this.enabled,
    required this.onChanged,
    this.loading = false,
  });

  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.fingerprint, size: 22, color: colors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbloqueo biométrico',
                  style: TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Usar huella o Face ID para desbloquear',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.accent,
              ),
            )
          else
            Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CameraPermissionRow extends StatelessWidget {
  const _CameraPermissionRow({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.photo_camera_outlined, size: 22, color: colors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permiso de cámara',
                  style: TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Si la denegaste, activá Cámara en los ajustes del sistema',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onOpenSettings,
            child: const Text('Ajustes'),
          ),
        ],
      ),
    );
  }
}
