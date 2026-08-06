import 'package:flutter/material.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../widgets/onboarding_step_header.dart';

/// Paso final (opcional) del onboarding: generar la primera credencial.
///
/// Es el paso 2 de 2 (el PIN y la wallet ya quedaron creados). Muestra una
/// ilustración y dos acciones. "Omitir" marca el onboarding como completo y
/// el router redirige al home; "Añadir credencial" abre el escáner QR (misma
/// ruta que el botón de escanear del home).
class CredentialGenerationScreen extends StatelessWidget {
  const CredentialGenerationScreen({
    super.key,
    required this.onSkip,
    required this.onAddCredential,
  });

  /// Finaliza el onboarding y entra a la app (botón "Omitir").
  final VoidCallback onSkip;

  /// Abre [ScanScreen] para leer un offer OID4VCI (u otro QR soportado).
  final VoidCallback onAddCredential;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingStepHeader(currentStep: 2, totalSteps: 2),
          const SizedBox(height: 32),

          // Título + descripción.
          const Text(
            'Genera tu primera credencial',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Podés generar tu primera credencial ahora o hacerlo más adelante '
            'desde tu perfil.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Ilustración (QR + credencial) sobre el círculo celeste.
          const Expanded(child: Center(child: _CredentialIllustration())),
          const SizedBox(height: 24),

          // Acciones.
          _ActionButton(
            label: 'Omitir',
            background: Colors.white,
            foreground: AppColors.textNeutralPrimary,
            border: AppColors.borderNeutral,
            onTap: onSkip,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Añadir credencial',
            background: AppColors.brandPrimary,
            foreground: AppColors.backgroundNeutralSecondary,
            iconAsset: 'public/images/login/QR-Code.png',
            iconColor: AppColors.backgroundNeutralSecondary,
            onTap: onAddCredential,
          ),
        ],
      ),
    );
  }
}

/// Ilustración de la credencial (QR + tarjeta) centrada sobre un círculo celeste.
///
/// El círculo de fondo no viene en el PNG, así que se compone aparte; el dibujo
/// desborda el círculo a los lados (como en el diseño).
class _CredentialIllustration extends StatelessWidget {
  const _CredentialIllustration();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 290,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 245,
              height: 245,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F9FF),
                shape: BoxShape.circle,
              ),
            ),
            Image.asset(
              'public/images/login/Ilustración-4.png',
              width: 290,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón de acción a todo el ancho (radio 16) con color de fondo/texto e ícono
/// opcional a la izquierda. Soporta borde y tinte del ícono.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.iconAsset,
    this.iconColor,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  /// Ícono opcional (18×18) a la izquierda del texto.
  final String? iconAsset;

  /// Si se indica, recolorea el ícono (útil para PNGs monocromos).
  final Color? iconColor;

  /// Color del borde; si es `null` no se dibuja borde.
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Material(
      color: background,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          // Alto mínimo en lugar de fijo: crece con la fuente del sistema en
          // vez de desbordar (textScaleFactor alto / pantallas de baja densidad).
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: border != null ? Border.all(color: border!) : null,
            boxShadow: const [kShadowXs],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconAsset != null) ...[
                Image.asset(
                  iconAsset!,
                  width: 18,
                  height: 18,
                  color: iconColor,
                  colorBlendMode: iconColor != null ? BlendMode.srcIn : null,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
