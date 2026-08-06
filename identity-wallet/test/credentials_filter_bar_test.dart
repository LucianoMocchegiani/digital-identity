import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:identity_wallet/features/credentials/widgets/credentials_filter_bar.dart';

void main() {
  testWidgets(
    'la barra de filtros no desborda en pantalla angosta con fuente grande',
    (tester) async {
      // Pantalla angosta (360 lógicos) + fuente del sistema ampliada (1.3),
      // condiciones típicas de teléfonos reales donde la barra se "rompía".
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: Align(
                alignment: Alignment.topCenter,
                child: CredentialsFilterBar(),
              ),
            ),
          ),
        ),
      );

      // Un overflow de RenderFlex registra una excepción de Flutter durante el
      // layout; takeException la captura. Sin overflow, debe ser null.
      expect(tester.takeException(), isNull);
    },
  );
}
