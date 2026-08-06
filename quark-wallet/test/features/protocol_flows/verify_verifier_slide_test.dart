import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quark_wallet/features/protocol_flows/oid4vp/slides/verify_verifier_slide.dart';

void main() {
  Widget host({
    String name = 'UADE',
    String? domain = 'verifier.uade.edu.ar',
    bool isVerified = true,
    String? purpose,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: VerifierSheetContent(
            name: name,
            domain: domain,
            logoUrl: null,
            isVerified: isVerified,
            purpose: purpose,
          ),
        ),
      );

  group('VerifierSheetContent', () {
    testWidgets('muestra nombre y dominio del verificador', (tester) async {
      await tester.pumpWidget(host());
      await tester.pump();
      expect(find.text('UADE'), findsOneWidget);
      expect(find.text('verifier.uade.edu.ar'), findsOneWidget);
    });

    testWidgets('oculta el secundario cuando domain es null', (tester) async {
      await tester.pumpWidget(host(name: 'Verificador no identificado', domain: null));
      await tester.pump();
      expect(find.text('Verificador no identificado'), findsOneWidget);
      expect(find.textContaining('x509_hash:'), findsNothing);
      expect(find.textContaining('decentralized_identifier:'), findsNothing);
    });

    testWidgets('badge de confianza cuando isVerified', (tester) async {
      await tester.pumpWidget(host(isVerified: true));
      await tester.pump();
      expect(find.text('Verificador de confianza'), findsOneWidget);
    });

    testWidgets('badge de advertencia cuando no isVerified', (tester) async {
      await tester.pumpWidget(host(isVerified: false));
      await tester.pump();
      expect(find.text('Sin verificación de confianza'), findsOneWidget);
    });

    testWidgets('muestra el propósito cuando viene', (tester) async {
      await tester.pumpWidget(host(purpose: 'Validar identidad'));
      await tester.pump();
      expect(find.text('Validar identidad'), findsOneWidget);
    });
  });
}
