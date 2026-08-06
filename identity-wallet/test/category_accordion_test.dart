import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:identity_wallet/features/categories/models/wallet_category.dart';
import 'package:identity_wallet/features/categories/widgets/category_accordion.dart';
import 'package:identity_wallet/features/credentials/models/wallet_credential.dart';

void main() {
  testWidgets(
    'tocar la fila de una credencial invoca onCredentialTap con esa credencial',
    (tester) async {
      const credential = WalletCredential(
        id: 'cred-1',
        title: 'Documento de Identidad',
        issuer: 'Gobierno de la Ciudad',
      );
      final category = WalletCategory(
        id: 'cat-1',
        label: 'Identidad',
        iconAsset: 'public/images/categorias/identidad-category.png',
        rowColor: const Color(0x149E77ED),
        credentials: const [credential],
      );

      WalletCredential? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryAccordion(
              category: category,
              onCredentialTap: (c) => tapped = c,
            ),
          ),
        ),
      );

      // Arranca colapsado: expandir para ver la lista de credenciales.
      await tester.tap(find.text('Identidad'));
      await tester.pumpAndSettle();

      // Tocar la fila de la credencial.
      await tester.tap(find.text('Documento de Identidad'));
      await tester.pumpAndSettle();

      expect(tapped, same(credential));
    },
  );
}
