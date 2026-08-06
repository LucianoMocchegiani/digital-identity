import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../../../credentials/models/wallet_credential.dart';
import '../../oid4vp/slides/share_credentials_slide.dart';

/// Bottom sheet de confirmación antes de enviar la presentación DIDComm.
///
/// Reutiliza el mismo copy y [ShareSheetContent] que OID4VP para que emisor
/// “Verificado”, claims etiquetados y título coincidan entre protocolos.
class DidCommSharePresentationSheet extends StatelessWidget {
  const DidCommSharePresentationSheet({
    super.key,
    required this.credential,
    required this.claims,
    required this.onReject,
    required this.onAccept,
  });

  final WalletCredential credential;
  final List<LabeledClaim> claims;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return FlowSheetScaffold(
      sheet: QuarkFlowSheet(
        title: '¿Deseás compartir estos datos?',
        secondaryLabel: 'Cancelar',
        onSecondary: onReject,
        primaryLabel: 'Compartir',
        onPrimary: onAccept,
        children: [
          ShareSheetContent(
            entries: [
              ShareEntryUi(credential: credential, claims: claims),
            ],
          ),
        ],
      ),
    );
  }
}
