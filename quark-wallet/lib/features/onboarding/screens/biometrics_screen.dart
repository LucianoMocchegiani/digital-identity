import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

/// Paso opcional de onboarding: ofrecer desbloqueo biométrico con [LocalAuthentication].
///
/// Al montar consulta si el dispositivo soporta y puede usar biometría
/// ([LocalAuthentication.isDeviceSupported], [LocalAuthentication.canCheckBiometrics]).
/// Si no hay soporte, muestra mensaje informativo y solo permite [onResult] con `false`
/// vía "Saltar".
///
/// [onResult] se llama con `true` solo si el usuario completa [LocalAuthentication.authenticate]
/// con éxito (`biometricOnly`); ante error, cancelación o "Saltar" se invoca con `false`.
/// Quien embebe esta pantalla decide el siguiente paso (p. ej. continuar el flujo de creación de wallet).
class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key, required this.onResult});

  /// `true` si el usuario activó biometría correctamente; `false` si saltó o falló.
  final ValueChanged<bool> onResult;

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

/// Estado: consulta de disponibilidad y llamada a [LocalAuthentication.authenticate].
class _BiometricsScreenState extends State<BiometricsScreen> {
  final _auth = LocalAuthentication();
  bool _available = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  /// Actualiza [_available] y deja de mostrar el indicador de carga inicial.
  Future<void> _checkAvailability() async {
    final supported = await _auth.isDeviceSupported();
    final canCheck = await _auth.canCheckBiometrics;
    if (mounted) setState(() { _available = supported && canCheck; _loading = false; });
  }

  /// Dispara el prompt del SO; el resultado se reenvía con [BiometricsScreen.onResult].
  Future<void> _enable() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Activar biometría para desbloquear la wallet',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      widget.onResult(authenticated);
    } catch (_) {
      widget.onResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: kAuthOnboardingScreenPadding,
      child: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.fingerprint,
            size: 96,
            color: _available ? colors.primary : colors.outline,
          ),
          const SizedBox(height: 32),
          Text(
            'Biometría',
            style: text.quarkPageTitle,
          ),
          const SizedBox(height: 8),
          Text(
            _available
                ? 'Activá Face ID / huella para desbloquear tu wallet más rápido.'
                : 'Tu dispositivo no soporta biometría.',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (_available)
            FilledButton(
              onPressed: _enable,
              style: AppButtonStyles.primaryCta(context),
              child: const Text('Activar biometría', style: TextStyle(fontSize: 16)),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => widget.onResult(false),
            child: const Text('Saltar'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
