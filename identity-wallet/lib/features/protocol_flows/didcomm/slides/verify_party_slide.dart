import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Pantalla de confirmación antes de aceptar una invitación DIDComm (OOB).
///
/// Se muestra desde [DidCommNotificationScreen] cuando [DidCommNotifier] está en
/// [DidCommVerifyPartyState]. Lee campos típicos del JSON de invitación: `label`,
/// `goal`, `from`. El título e icono dependen de [DidCommFlowType].
///
/// [onAccept] debe disparar [DidCommNotifier.acceptConnection]; [onCancel] cierra
/// el flujo sin conectar.

class VerifyPartySlide extends StatelessWidget {
  const VerifyPartySlide({
    super.key,
    required this.invitation,
    required this.flowType,
    required this.onAccept,
    required this.onCancel,
  });

  /// Payload OOB ya resuelto (mapa JSON de la invitación).
  final Map<String, dynamic> invitation;

  /// Tipo de flujo detectado (conexión, emisión o verificación).
  final DidCommFlowType flowType;

  /// Confirmación del usuario: inicia el DID Exchange en el notifier.
  final VoidCallback onAccept;

  /// Rechazo: vuelve atrás o al home según defina la pantalla padre.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final label = invitation['label'] as String? ?? 'Agente desconocido';
    final goal = invitation['goal'] as String?;
    final from = invitation['from'] as String?;

    return Scaffold(
      appBar: FlowStepAppBar.build(
        title: _titleForFlow(flowType),
        progress: 0.5,
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconForFlow(flowType), size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (goal != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      goal,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (from != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      from,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            FlowActionRow(
              onCancel: onCancel,
              onPrimary: onAccept,
              primaryLabel: 'Conectar',
            ),
          ],
        ),
      ),
    );
  }

  /// Título del [AppBar] según el tipo de flujo DIDComm.

  String _titleForFlow(DidCommFlowType type) => switch (type) {
    DidCommFlowType.connect => 'Solicitud de conexión',
    DidCommFlowType.issue => 'Oferta de credencial',
    DidCommFlowType.verify => 'Solicitud de verificación',
  };

  /// Icono central acorde al tipo de flujo.

  IconData _iconForFlow(DidCommFlowType type) => switch (type) {
    DidCommFlowType.connect => Icons.people_outline,
    DidCommFlowType.issue => Icons.download_outlined,
    DidCommFlowType.verify => Icons.verified_user_outlined,
  };
}
