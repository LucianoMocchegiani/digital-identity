import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(bottomNavigationBar: child),
    );

void main() {
  testWidgets('muestra el icono QR cuando showClose es false', (tester) async {
    await tester.pumpWidget(_wrap(
      const IdentityBottomNav(currentTab: IdentityNavTab.credentials),
    ));
    final qr = tester.widget<Image>(
      find.byKey(const ValueKey('navCenterIcon')),
    );
    expect((qr.image as AssetImage).assetName, contains('QR Code.png'));
  });

  testWidgets('muestra la cruz cuando showClose es true', (tester) async {
    await tester.pumpWidget(_wrap(
      const IdentityBottomNav(
        currentTab: IdentityNavTab.credentials,
        showClose: true,
      ),
    ));
    final cross = tester.widget<Image>(
      find.byKey(const ValueKey('navCenterIcon')),
    );
    expect((cross.image as AssetImage).assetName, contains('Cross.png'));
  });
}
