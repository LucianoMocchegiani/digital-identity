import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import 'onboarding_step_header.dart';

/// Duración tras la cual el mensaje de error se desvanece y el campo se resetea.
const _kErrorAutoDismiss = Duration(seconds: 3);

/// Vista reutilizable de ingreso de PIN con teclado numérico propio.
///
/// Maneja internamente los dígitos escritos y dibuja: barra superior con botón
/// "atrás" e indicador de paso (opcionales), título, descripción, badge de
/// advertencia opcional, los puntos de progreso, el teclado y —según el modo—
/// un botón de envío o auto-envío al completar [pinLength] dígitos.
///
/// La usan la creación y confirmación del PIN (con barra superior y botón) y el
/// desbloqueo en [AuthenticateScreen] (sin barra superior, con botón "Confirmar").
/// (ej. PINs no coinciden o PIN incorrecto) el padre pasa un [errorText] e
/// incrementa [errorNonce]: la vista pinta los puntos en rojo, muestra el badge
/// de error y, tras [_kErrorAutoDismiss], lo desvanece y limpia el campo.
class PinEntryView extends StatefulWidget {
  const PinEntryView({
    super.key,
    required this.title,
    required this.description,
    required this.onSubmit,
    this.currentStep,
    this.totalSteps = 2,
    this.onBack,
    this.submitLabel = 'Continuar',
    this.pinLength = 6,
    this.showWarning = false,
    this.autoSubmit = false,
    this.errorText,
    this.errorNonce = 0,
    this.isSubmitting = false,
  });

  /// Título principal (ej. "Creá tu PIN de acceso").
  final String title;

  /// Descripción bajo el título.
  final String description;

  /// Se invoca con el PIN completo (al presionar el botón o, con [autoSubmit],
  /// al completar [pinLength] dígitos).
  final ValueChanged<String> onSubmit;

  /// Paso actual (base 1) del indicador superior; si es `null` (junto con
  /// [onBack] nulo) la barra superior no se muestra (caso desbloqueo).
  final int? currentStep;

  /// Cantidad total de pasos del indicador superior.
  final int totalSteps;

  /// Acción del botón "atrás"; si es `null` la barra superior no se muestra.
  final VoidCallback? onBack;

  /// Etiqueta del botón de envío (ej. "Continuar" o "Confirmar").
  final String submitLabel;

  /// Cantidad de dígitos del PIN.
  final int pinLength;

  /// Muestra el badge de advertencia ("Recordá tu PIN. No podrá recuperarse.").
  final bool showWarning;

  /// Si es true, envía automáticamente al completar [pinLength] dígitos y oculta
  /// el botón. En desbloqueo y onboarding se prefiere `false` con [submitLabel].
  final bool autoSubmit;

  /// Mensaje de error a mostrar cuando [errorNonce] cambia (ej. PINs no coinciden).
  final String? errorText;

  /// Nonce de error: al cambiar su valor, la vista entra en estado de error.
  final int errorNonce;

  /// Si es `true`, deshabilita el teclado y muestra carga en el botón de envío.
  ///
  /// Usado en [PinConfirmScreen] y [AuthenticateScreen] mientras se crea o
  /// desbloquea la wallet ([QuarkPrimaryButton.isLoading]).
  final bool isSubmitting;

  @override
  State<PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends State<PinEntryView> {
  /// Dígitos ingresados hasta el momento.
  String _pin = '';

  /// Mensaje de error activo (no nulo mientras se muestra el badge rojo).
  String? _error;

  /// Temporizador del auto-descarte del error.
  Timer? _errorTimer;

  @override
  void didUpdateWidget(PinEntryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Un nonce nuevo activa el estado de error (puntos rojos + badge).
    if (widget.errorNonce != oldWidget.errorNonce && widget.errorText != null) {
      _showError(widget.errorText!);
    }
  }

  /// Activa el estado de error y programa su desvanecimiento + reseteo.
  void _showError(String message) {
    setState(() => _error = message);
    _errorTimer?.cancel();
    _errorTimer = Timer(_kErrorAutoDismiss, () {
      if (!mounted) return;
      setState(() {
        _error = null;
        _pin = '';
      });
    });
  }

  /// Agrega un dígito si no hay error activo y no se alcanzó la longitud del PIN.
  void _onDigit(String digit) {
    if (_error != null || _pin.length >= widget.pinLength || widget.isSubmitting) {
      return;
    }
    setState(() => _pin += digit);
    // En modo auto-envío, al completar la longitud se envía solo.
    if (widget.autoSubmit && _pin.length == widget.pinLength) {
      widget.onSubmit(_pin);
    }
  }

  /// Borra el último dígito ingresado (deshabilitado durante el error).
  void _onBackspace() {
    if (_error != null || _pin.isEmpty || widget.isSubmitting) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  /// Envía el PIN si está completo.
  void _onSubmit() {
    if (_pin.length == widget.pinLength && !widget.isSubmitting) {
      widget.onSubmit(_pin);
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complete = _pin.length == widget.pinLength;
    final hasError = _error != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra superior solo en los pasos del onboarding; en desbloqueo se
          // omite y un Spacer centra el contenido.
          if (widget.currentStep != null && widget.onBack != null) ...[
            OnboardingStepHeader(
              currentStep: widget.currentStep!,
              totalSteps: widget.totalSteps,
              onBack: widget.onBack!,
            ),
            const SizedBox(height: 32),
          ] else
            const Spacer(),

          // Título + descripción.
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralSecondary,
            ),
          ),

          if (widget.showWarning) ...[
            const SizedBox(height: 12),
            const _WarningBadge(),
          ],

          const SizedBox(height: 24),
          // En error, todos los puntos se muestran rellenos en rojo.
          _PinDots(
            filled: hasError ? widget.pinLength : _pin.length,
            total: widget.pinLength,
            hasError: hasError,
          ),
          // Badge de error bajo los puntos; aparece y se desvanece de forma sutil.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: hasError
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _ErrorBadge(message: _error!),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),
          _Keypad(onDigit: _onDigit, onBackspace: _onBackspace),

          const Spacer(),
          if (!widget.autoSubmit)
            QuarkPrimaryButton(
              label: widget.submitLabel,
              enabled: complete,
              isLoading: widget.isSubmitting,
              onTap: _onSubmit,
            ),
        ],
      ),
    );
  }
}

/// Badge de advertencia con ícono de triángulo y texto ámbar.
class _WarningBadge extends StatelessWidget {
  const _WarningBadge();

  static const _iconAsset = 'public/images/login/Danger-Triangle.png';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 2, 8, 2),
        decoration: BoxDecoration(
          color: AppColors.warningSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_iconAsset, width: 12, height: 12),
            const SizedBox(width: 4),
            const Flexible(
              child: Text(
                'Recordá tu PIN. No podrá recuperarse.',
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warningText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de puntos que refleja cuántos dígitos del PIN se ingresaron. En
/// [hasError] los puntos rellenos se muestran en rojo.
class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.filled,
    required this.total,
    this.hasError = false,
  });

  final int filled;
  final int total;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isFilled = index < filled;
        final fillColor = hasError ? AppColors.errorDot : AppColors.brandPrimary;
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              // El relleno crece con cada dígito; en error vira a rojo.
              color: isFilled ? fillColor : AppColors.borderNeutral,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

/// Badge de error bajo los puntos del PIN (ícono de prohibido + mensaje rojo).
class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge({required this.message});

  final String message;

  static const _iconAsset = 'public/images/login/Forbidden-circle.png';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 2, 8, 2),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_iconAsset, width: 12, height: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.errorText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teclado numérico: 1-9, un hueco vacío, 0 y borrar.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    // Cada fila se describe con tokens: dígitos, '' (hueco) y 'back' (borrar).
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final key in rows[r]) _buildKey(key),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 72, height: 72);
    if (key == 'back') {
      return _KeypadButton(
        onTap: onBackspace,
        filled: false,
        child: const Icon(
          Icons.backspace_outlined,
          size: 28,
          color: AppColors.textNeutralMuted,
        ),
      );
    }
    return _KeypadButton(
      onTap: () => onDigit(key),
      filled: true,
      child: Text(
        key,
        style: const TextStyle(
          fontSize: 32,
          height: 30 / 32,
          fontWeight: FontWeight.w500,
          color: AppColors.textNeutralPrimary,
        ),
      ),
    );
  }
}

/// Tecla circular del teclado (77×78 ≈ 72): fondo tenue para dígitos,
/// transparente para borrar; feedback morado al presionar.
class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.onTap,
    required this.filled,
    required this.child,
  });

  final VoidCallback onTap;
  final bool filled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? const Color.fromRGBO(24, 29, 39, 0.02) : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        highlightColor: AppColors.brandPrimary.withValues(alpha: 0.12),
        splashColor: AppColors.brandPrimary.withValues(alpha: 0.12),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(child: child),
        ),
      ),
    );
  }
}
