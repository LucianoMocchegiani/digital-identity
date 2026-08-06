import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../credentials/models/wallet_credential.dart';
import '../../../credentials/widgets/credential_fields_view.dart';

/// Bottom sheet de confirmación "¿Deseás agregar esta credencial?".
///
/// Usa el mismo layout que el sheet de compartir ([ShareSheetContent]):
/// tarjeta + fila de emisor con "Verificado" + claims etiqueta/valor, sin
/// sección "Atributos" ni divisores.
///
/// Es presentacional: [onReject] y [onAccept] los provee la pantalla del flujo.
class AddCredentialSheet extends StatelessWidget {
  const AddCredentialSheet({
    super.key,
    required this.credential,
    required this.claims,
    required this.onReject,
    required this.onAccept,
  });

  /// Credencial a previsualizar en la tarjeta superior.
  final WalletCredential credential;

  /// Claims a listar bajo el emisor (etiqueta + valor).
  final List<LabeledClaim> claims;

  /// Cierra el flujo sin agregar la credencial.
  final VoidCallback onReject;

  /// Confirma y agrega la credencial (inicia la adquisición).
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return IdentityFlowSheet(
      title: '¿Deseás agregar esta credencial?',
      secondaryLabel: 'Rechazar',
      onSecondary: onReject,
      primaryLabel: 'Agregar',
      onPrimary: onAccept,
      children: [
        CredentialFieldsView(
          credential: credential,
          fields: previewCredentialFields(credential, claims),
        ),
      ],
    );
  }
}
