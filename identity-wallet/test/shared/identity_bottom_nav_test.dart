import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_wallet/shared/theme/app_theme.dart';
import 'package:identity_wallet/shared/widgets/identity_bottom_nav.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(bottomNavigationBar: child),
    );
  }

  testWidgets('muestra Inicio, QR y Menú', (tester) async {
    await tester.pumpWidget(
      wrap(const IdentityBottomNav(currentTab: IdentityNavTab.home)),
    );

    expect(find.byKey(const ValueKey('navScanIcon')), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('el QR invoca onScan al tocar', (tester) async {
    var scanned = false;
    await tester.pumpWidget(
      wrap(
        IdentityBottomNav(
          currentTab: IdentityNavTab.home,
          onScan: () => scanned = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('navScanIcon')));
    await tester.pump();
    expect(scanned, isTrue);
  });

  testWidgets('en pestaña scan el ícono QR sigue visible', (tester) async {
    await tester.pumpWidget(
      wrap(const IdentityBottomNav(currentTab: IdentityNavTab.scan)),
    );

    expect(find.byKey(const ValueKey('navScanIcon')), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
