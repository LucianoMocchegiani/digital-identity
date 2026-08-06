import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

const _kBiometricsKey = 'biometrics_enabled';
const _storage = FlutterSecureStorage();

/// Lee si el desbloqueo biométrico está habilitado (clave en [FlutterSecureStorage]).
///
/// Valor persistido como string `'true'` / `'false'`. Se invalida tras cada cambio
/// desde [SettingsScreen].

final _biometricsEnabledProvider = FutureProvider<bool>((ref) async {
  final value = await _storage.read(key: _kBiometricsKey);
  return value == 'true';
});

/// Ajustes de la app bajo `/home/menu/settings`.
///
/// Por ahora solo expone el interruptor de **desbloqueo biométrico**: persiste la
/// preferencia en almacenamiento seguro y, al activar, comprueba disponibilidad con
/// [LocalAuthentication.canCheckBiometrics]. La lectura inicial va por
/// [_biometricsEnabledProvider].

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricsAsync = ref.watch(_biometricsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
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
        ],
      ),
    );
  }

  /// Activa o desactiva la preferencia biométrica y refresca el provider.
  ///
  /// Si [enable] es true y el dispositivo no puede usar biométricos, muestra
  /// [SnackBar] y no guarda el cambio.

  Future<void> _toggleBiometrics(BuildContext context, WidgetRef ref, bool enable) async {
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

/// Fila del interruptor biométrico: huella, título, descripción y switch.
///
/// Con [loading] reemplaza el switch por un indicador mientras se lee la
/// preferencia persistida.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.fingerprint,
            size: 22,
            color: AppColors.textNeutralSecondary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbloqueo biométrico',
                  style: TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textNeutralPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Usar huella o Face ID para desbloquear',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textNeutralSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.brandPrimary,
            ),
        ],
      ),
    );
  }
}
