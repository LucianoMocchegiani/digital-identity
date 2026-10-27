import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:identity_wallet/features/categories/models/wallet_category.dart';
import 'package:identity_wallet/features/categories/widgets/categories_panel.dart';
import 'package:identity_wallet/features/credentials/models/wallet_credential.dart';

void main() {
  testWidgets('abrir una categoría oculta las demás y permite volver', (tester) async {
    const credential = WalletCredential(
      id: 'cred-1',
      title: 'Pase del club',
      issuer: 'Club',
    );
    final categories = [
      const WalletCategory(
        id: 'club',
        label: 'Club',
        iconAsset: 'public/images/categorias/identidad-category.png',
        rowColor: Color(0x149E77ED),
        credentials: [credential],
      ),
      const WalletCategory(
        id: 'eventos',
        label: 'Eventos',
        iconAsset: 'public/images/categorias/identidad-category.png',
        rowColor: Color(0x149E77ED),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CategoriesPanel(categories: categories)),
      ),
    );

    await tester.tap(find.text('Club').first);
    await tester.pumpAndSettle();

    expect(find.text('Pase del club'), findsOneWidget);
    expect(find.text('Eventos'), findsNothing);

    await tester.tap(find.byTooltip('Volver a categorías'));
    await tester.pumpAndSettle();

    expect(find.text('Eventos'), findsOneWidget);
  });
}
