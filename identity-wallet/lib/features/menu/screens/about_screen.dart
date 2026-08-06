import 'package:flutter/material.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Pantalla informativa "Acerca de" bajo `/home/menu/about`.
///
/// Contenido estático: nombre de la app, versión fija y capacidades (protocolos,
/// formatos de credencial, KMS, persistencia) listadas con [SheetFieldRow], el
/// mismo par etiqueta/valor que usan el detalle y los flujos de credencial.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      appBar: IdentityPageAppBar.build(title: 'Acerca de'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accentBlueSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 36,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Wallet',
              style: TextStyle(
                fontSize: 20,
                height: 26 / 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textNeutralPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'v0.1.0',
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textNeutralSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const IdentityCard(
            // Sin relleno inferior: cada SheetFieldRow ya aporta 16px abajo.
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetFieldRow(
                  label: 'Protocolo',
                  value: 'OID4VCI · OID4VP · DIDComm v1',
                ),
                SheetFieldRow(
                  label: 'Formatos',
                  value: 'SD-JWT VC · W3C JWT VC · mDoc',
                ),
                SheetFieldRow(
                  label: 'KMS',
                  value: 'Software / Hardware-backed',
                ),
                SheetFieldRow(
                  label: 'Persistencia',
                  value: 'Isar · campos sensibles AES-256-GCM',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
