import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quark_wallet/features/credentials/models/wallet_credential.dart';
import 'package:quark_wallet/features/credentials/widgets/credential_card.dart';
import 'package:quark_wallet/features/credentials/widgets/credential_fields_view.dart';

void main() {
  const credential = WalletCredential(title: 'Estudiante UADE', issuer: 'UADE');

  Widget host(List<CredentialField> fields) => ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ListView(children: [
              CredentialFieldsView(credential: credential, fields: fields),
            ]),
          ),
        ),
      );

  testWidgets('renderiza la tarjeta y una fila por campo', (tester) async {
    await tester.pumpWidget(host(const [
      (label: 'Institución/Empresa emisora', value: 'UADE', verified: true),
      (label: 'Nombre', value: 'Camila Sosa', verified: false),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(CredentialCard), findsOneWidget);
    expect(find.text('Institución/Empresa emisora'), findsOneWidget);
    expect(find.text('UADE'), findsWidgets); // en la tarjeta y en la fila de emisor
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Camila Sosa'), findsOneWidget);
  });

  testWidgets('sin campos igual muestra la tarjeta', (tester) async {
    await tester.pumpWidget(host(const []));
    await tester.pumpAndSettle();
    expect(find.byType(CredentialCard), findsOneWidget);
  });
}
