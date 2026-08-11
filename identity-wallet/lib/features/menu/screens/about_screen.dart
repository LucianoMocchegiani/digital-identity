import 'package:flutter/material.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Pantalla informativa "Acerca de" bajo `/home/menu/about`.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return KuatiaScaffold(
      appBar: IdentityPageAppBar.build(title: 'Acerca de'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
        children: [
          const Center(child: KuatiaAppIcon(size: 80)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Kuatia Wallet',
              style: TextStyle(
                fontSize: 20,
                height: 26 / 20,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v0.1.0',
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w400,
                color: colors.muted,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const IdentityCard(
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
