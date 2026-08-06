import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/features/credentials/models/wallet_credential.dart';
import 'package:quark_wallet/features/protocol_flows/oid4vp/slides/share_credentials_slide.dart';

void main() {
  const credential = WalletCredential(title: 'Estudiante UADE', issuer: 'UADE');

  Widget host(List<ShareEntryUi> entries) => ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ListView(children: [ShareSheetContent(entries: entries)]),
          ),
        ),
      );

  group('ShareSheetContent', () {
    testWidgets('muestra la fila de emisor y los claims pedidos',
        (tester) async {
      await tester.pumpWidget(host(const [
        ShareEntryUi(
          credential: credential,
          claims: [
            LabeledClaim(label: 'Nombre', key: 'nombre', value: 'Juan'),
            LabeledClaim(label: 'Apellido', key: 'apellido', value: 'Pérez'),
          ],
        ),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Institución/Empresa emisora'), findsOneWidget);
      expect(find.text('UADE'), findsWidgets);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('Apellido'), findsOneWidget);
      expect(find.text('Pérez'), findsOneWidget);
    });

    testWidgets('sin claims pedidos avisa credencial completa', (tester) async {
      await tester.pumpWidget(host(const [
        ShareEntryUi(credential: credential, claims: []),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('Institución/Empresa emisora'), findsOneWidget);
      expect(find.text('Se compartirá la credencial completa.'), findsOneWidget);
    });

    testWidgets('entrada insatisfecha muestra fila de error', (tester) async {
      await tester.pumpWidget(host(const [
        ShareEntryUi(missingName: 'Título universitario'),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('Título universitario'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
