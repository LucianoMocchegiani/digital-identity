import 'package:flutter_test/flutter_test.dart';
import 'package:quark_wallet/features/scan/scan_screen.dart';

void main() {
  group('scanErrorLabel', () {
    test('acercate', () {
      expect(scanErrorLabel(ScanError.acercate), 'Acercate un poco más.');
    });
    test('qrInvalido', () {
      expect(scanErrorLabel(ScanError.qrInvalido), 'Código QR invalido');
    });
    test('qrExpirado', () {
      expect(scanErrorLabel(ScanError.qrExpirado), 'El código QR expiró');
    });
    test('sinConexion', () {
      expect(scanErrorLabel(ScanError.sinConexion), 'Sin conexión a internet');
    });
  });
}
