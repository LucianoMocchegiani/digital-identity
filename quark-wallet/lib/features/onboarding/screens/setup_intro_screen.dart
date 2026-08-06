import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../widgets/terms_conditions_sheet.dart';

/// Pantalla de introducción a la configuración de la wallet ("Configurá tu
/// wallet"), previa a la creación del PIN.
///
/// Informa los pasos esenciales (proteger la cuenta con PIN y, opcionalmente,
/// generar la primera credencial) y exige aceptar los Términos y Condiciones
/// para habilitar el botón "Continuar".
///
/// [onContinue] avanza al siguiente paso del onboarding (creación del PIN).
class SetupIntroScreen extends StatefulWidget {
  const SetupIntroScreen({super.key, required this.onContinue});

  /// Acción del botón "Continuar" (solo activa con los T&C aceptados).
  final VoidCallback onContinue;

  @override
  State<SetupIntroScreen> createState() => _SetupIntroScreenState();
}

class _SetupIntroScreenState extends State<SetupIntroScreen> {
  /// Indica si el usuario aceptó los Términos y Condiciones.
  bool _accepted = false;

  /// Reconocedor del enlace "Términos y Condiciones" del texto del checkbox.
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  /// Alterna la aceptación de los Términos y Condiciones.
  void _toggleAccepted() => setState(() => _accepted = !_accepted);

  /// Abre el drawer de Términos y Condiciones.
  void _openTerms() => showTermsConditionsSheet(context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título y descripción.
          const Text(
            'Configurá tu wallet',
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
            'Antes de comenzar, necesitás completar algunos pasos para '
            'configurar y proteger tu cuenta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Pasos de configuración.
          const _StepRow(
            iconAsset: 'public/images/login/Key.png',
            stepLabel: 'Paso 1',
            title: 'Protegé tu cuenta',
            description:
                'Creá un PIN de acceso de 6 dígitos para acceder de forma '
                'segura a la wallet.',
          ),
          const SizedBox(height: 32),
          const _StepRow(
            iconAsset: 'public/images/login/QR-Code.png',
            stepLabel: 'Paso 2',
            optionalLabel: 'OPCIONAL',
            title: 'Genera tu primera credencial',
            description:
                'Escaneá el QR de la entidad emisora para generar credencial.',
          ),

          // Empuja la botonera al borde inferior.
          const Spacer(),

          // Checkbox de aceptación + botón "Continuar".
          _AcceptTermsRow(
            accepted: _accepted,
            onToggle: _toggleAccepted,
            termsRecognizer: _termsRecognizer,
          ),
          const SizedBox(height: 12),
          QuarkPrimaryButton(
            label: 'Continuar',
            enabled: _accepted,
            onTap: widget.onContinue,
          ),
        ],
      ),
    );
  }
}

/// Fila de un paso de configuración: ícono en contenedor celeste + textos.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.iconAsset,
    required this.stepLabel,
    required this.title,
    required this.description,
    this.optionalLabel,
  });

  /// Ruta del ícono (24×24) del paso.
  final String iconAsset;

  /// Etiqueta del paso (ej. "Paso 1").
  final String stepLabel;

  /// Título del paso.
  final String title;

  /// Descripción del paso.
  final String description;

  /// Etiqueta opcional a la derecha del paso (ej. "OPCIONAL"); puede ser `null`.
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenedor del ícono (46×44, fondo celeste, esquinas redondeadas).
          Container(
            width: 46,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentBlueSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(iconAsset, width: 24, height: 24),
          ),
          const SizedBox(width: 16),
          // Textos del paso.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepLabel(stepLabel: stepLabel, optionalLabel: optionalLabel),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textNeutralPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 18 / 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textNeutralSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Línea de etiqueta del paso: "Paso N" y, opcionalmente, "· OPCIONAL".
class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.stepLabel, this.optionalLabel});

  final String stepLabel;
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) {
    const stepStyle = TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textNeutralSecondary,
    );

    return Row(
      children: [
        Text(stepLabel, style: stepStyle),
        if (optionalLabel != null) ...[
          const SizedBox(width: 8),
          const Text('·', style: stepStyle),
          const SizedBox(width: 8),
          Text(
            optionalLabel!,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Fila del checkbox de aceptación con el texto "Acepto los Términos y
/// Condiciones" (este último como enlace).
class _AcceptTermsRow extends StatelessWidget {
  const _AcceptTermsRow({
    required this.accepted,
    required this.onToggle,
    required this.termsRecognizer,
  });

  final bool accepted;
  final VoidCallback onToggle;
  final TapGestureRecognizer termsRecognizer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Checkbox(checked: accepted, onTap: onToggle),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF181D27),
                ),
                children: [
                  const TextSpan(text: 'Acepto los '),
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: const TextStyle(color: AppColors.linkBlue),
                    recognizer: termsRecognizer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checkbox cuadrado (16×16): vacío cuando está sin marcar; azul con check
/// blanco ([_checkAsset]) cuando está marcado.
class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  static const _checkAsset = 'public/images/login/check.png';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 16,
        height: 16,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: checked ? AppColors.checkboxCheckedFill : Colors.white,
          border: Border.all(
            color: checked ? AppColors.progressActive : AppColors.borderNeutral,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked
            ? Image.asset(_checkAsset, fit: BoxFit.contain)
            : null,
      ),
    );
  }
}
