import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../../../credentials/mappers/credential_ui_mapper.dart';
import '../../../credentials/widgets/credential_card.dart';

/// Vista previa de la oferta OID4VCI antes de solicitar la credencial al issuer.
///
/// Se muestra desde [Oid4VciNotificationScreen] en [Oid4VciPreviewState]. Renderiza
/// [CredentialCard] con [CredentialUiMapper.fromResolvedOffer]. [onAccept] suele llamar
/// a [Oid4VciNotifier.accept]; [onCancel] cierra el flujo.
class CredentialPreviewSlide extends StatelessWidget {
  const CredentialPreviewSlide({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onCancel,
  });

  /// Oferta ya resuelta por Identity Core.
  final ResolvedCredentialOffer offer;

  /// Confirma "Agregar" e inicia la adquisición (posible paso de TX code).
  final VoidCallback onAccept;

  /// Cancela y vuelve según defina la pantalla padre.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final credential = CredentialUiMapper.fromResolvedOffer(offer);

    return Scaffold(
      appBar: FlowStepAppBar.build(
        title: 'Vista previa',
        progress: 2 / 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: CredentialCard(
                  credential: credential,
                  initiallyExpanded: credential.details.isNotEmpty,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FlowActionRow(
              onCancel: onCancel,
              onPrimary: onAccept,
              primaryLabel: 'Agregar',
            ),
          ],
        ),
      ),
    );
  }
}
