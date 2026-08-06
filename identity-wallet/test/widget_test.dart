import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:identity_wallet/features/credentials/providers/credentials_provider.dart';
import 'package:identity_wallet/features/home/home_screen.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

void main() {
  testWidgets('El home del wallet monta la barra superior sin marca',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          credentialsProvider.overrideWith((_) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(IdentityTopBar), findsOneWidget);
    expect(find.text('Identity Wallet'), findsNothing);
  });
}
