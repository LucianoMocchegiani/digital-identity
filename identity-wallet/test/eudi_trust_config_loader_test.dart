import 'package:flutter_test/flutter_test.dart';
import 'package:identity_wallet/core/trust/eudi_trust_config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EudiTrustConfigLoader', () {
    test('_pemBodyToDerBase64 strips PEM headers', () {
      const pem = '''
-----BEGIN CERTIFICATE-----
MIIBkTCB+wIJAKHBfpE
n0s0MA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNV
-----END CERTIFICATE-----
''';
      expect(
        EudiTrustConfigLoader.pemBodyToDerBase64ForTest(pem),
        'MIIBkTCB+wIJAKHBfpEn0s0MA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNV',
      );
    });
  });
}
