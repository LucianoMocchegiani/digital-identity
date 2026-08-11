import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_wallet/shared/widgets/credential_loading_overlay.dart';

void main() {
  group('spinnerDotColor', () {
    test('el punto activo es teal Kuatia', () {
      expect(spinnerDotColor(3, 3), const Color(0xFF00A89D));
    });

    test('un punto no activo es gris', () {
      expect(spinnerDotColor(0, 3), const Color(0xFFD9D9D9));
    });

    test('cubre los 8 índices sin error', () {
      for (var active = 0; active < 8; active++) {
        for (var dot = 0; dot < 8; dot++) {
          final c = spinnerDotColor(dot, active);
          expect(
            c == const Color(0xFF00A89D) || c == const Color(0xFFD9D9D9),
            isTrue,
          );
        }
      }
    });
  });
}
