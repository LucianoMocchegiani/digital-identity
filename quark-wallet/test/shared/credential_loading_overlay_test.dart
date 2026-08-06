import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quark_wallet/shared/widgets/credential_loading_overlay.dart';

void main() {
  group('CredentialLoadingOverlay', () {
    testWidgets(
        'los textos no usan el estilo fallback (subrayado amarillo) '
        'cuando el overlay se apila fuera de un Material', (tester) async {
      // Reproduce el uso real: el overlay es hermano del slide en un Stack,
      // por lo que NO tiene un Material como ancestro.
      await tester.pumpWidget(
        const MaterialApp(
          home: Stack(
            fit: StackFit.expand,
            children: [
              Scaffold(body: SizedBox()),
              CredentialLoadingOverlay(
                title: 'Enviando credenciales...',
                description: 'Aguarde unos instantes.',
              ),
            ],
          ),
        ),
      );
      // Un frame alcanza; el spinner anima en loop, no usar pumpAndSettle.
      await tester.pump();

      for (final text in ['Enviando credenciales...', 'Aguarde unos instantes.']) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(text, findRichText: false),
        );
        final style = paragraph.text.style;
        expect(
          style?.decoration ?? TextDecoration.none,
          TextDecoration.none,
          reason: 'El texto "$text" se renderiza con el estilo fallback de '
              'Flutter (falta un Material ancestro dentro del overlay).',
        );
      }
    });
  });
}
