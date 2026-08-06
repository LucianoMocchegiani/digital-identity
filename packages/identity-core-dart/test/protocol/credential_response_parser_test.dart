import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

void main() {
  group('extractIssuedCredentials', () {
    test('singular credential', () {
      expect(
        extractIssuedCredentials({'credential': 'eyJ.sd.jwt~'}),
        ['eyJ.sd.jwt~'],
      );
    });

    test('credentials array of strings (EUDI)', () {
      expect(
        extractIssuedCredentials({
          'credentials': ['eyJ.abc.def~', 'eyJ.xyz.uvw~'],
        }),
        ['eyJ.abc.def~', 'eyJ.xyz.uvw~'],
      );
    });

    test('credentials array of objects', () {
      expect(
        extractIssuedCredentials({
          'credentials': [
            {'credential': 'token-one~'},
          ],
        }),
        ['token-one~'],
      );
    });
  });
}
