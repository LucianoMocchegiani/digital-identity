import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:pinput/pinput.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

/// Slide de ingreso del transaction code (`tx_code`) en flujo OID4VCI pre-authorized.
///
/// Lee metadatos de la oferta en [offer] (`grants.preAuthorized.txCode`: longitud,
/// descripción y modo de entrada, p. ej. numérico o texto).
/// Al completar el PIN con [Pinput] invoca [onConfirm] con el código; [onCancel] aborta
/// el paso (p. ej. volver o cerrar según el contenedor).
class TxCodeSlide extends StatefulWidget {
  const TxCodeSlide({
    super.key,
    required this.offer,
    required this.onConfirm,
    required this.onCancel,
  });

  /// Oferta OID4VCI ya resuelta; fuente de `tx_code` para longitud, texto y teclado.
  final ResolvedCredentialOffer offer;

  /// Callback con el código ingresado (PIN completo o confirmación manual).
  final ValueChanged<String> onConfirm;

  /// Callback al cancelar desde la acción explícita en la barra inferior.
  final VoidCallback onCancel;

  @override
  State<TxCodeSlide> createState() => _TxCodeSlideState();
}

/// Estado local del slide: [TextEditingController] del PIN y su ciclo de vida.
class _TxCodeSlideState extends State<TxCodeSlide> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  /// Libera el controlador del campo PIN al desmontar el widget.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txCode = widget.offer.offer.grants?.preAuthorized?.txCode;
    final length = txCode?.length ?? 4;
    final description = txCode?.description ?? 'Ingresá el código enviado por el emisor.';
    final isNumeric = (txCode?.inputMode ?? 'numeric') == 'numeric';

    return Scaffold(
      appBar: FlowStepAppBar.build(
        title: 'Código de verificación',
        progress: 2.5 / 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 24),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Pinput(
                    controller: _controller,
                    length: length,
                    keyboardType: isNumeric
                        ? TextInputType.number
                        : TextInputType.text,
                    defaultPinTheme: buildPinTheme(context),
                    onCompleted: widget.onConfirm,
                  ),
                ],
              ),
            ),
            FlowActionRow(
              onCancel: widget.onCancel,
              onPrimary: _controller.text.length == length
                  ? () => widget.onConfirm(_controller.text)
                  : null,
              primaryLabel: 'Confirmar',
            ),
          ],
        ),
      ),
    );
  }
}
