import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

void main() {
  group('FieldCipher', () {
    late FieldCipher cipher;
    late List<int> key;

    setUp(() {
      cipher = FieldCipher();
      key = List<int>.generate(32, (i) => i + 1);
    });

    test('round-trip mantiene el plaintext', () async {
      const plaintext = '{"d":"secret-private-key"}';
      final encrypted = await cipher.encrypt(
        Uint8List.fromList(key),
        plaintext,
      );
      expect(cipher.isEncrypted(encrypted), isTrue);
      final decrypted = await cipher.decrypt(
        Uint8List.fromList(key),
        encrypted,
      );
      expect(decrypted, plaintext);
    });

    test('clave incorrecta lanza FieldCipherError', () async {
      final encrypted = await cipher.encrypt(
        Uint8List.fromList(key),
        'secreto',
      );
      final wrongKey = Uint8List.fromList(List<int>.generate(32, (i) => i + 2));
      expect(
        () => cipher.decrypt(wrongKey, encrypted),
        throwsA(isA<FieldCipherError>()),
      );
    });

    test('valores legacy sin prefijo se devuelven sin cambio', () async {
      const legacy = '{"plain":true}';
      final result = await cipher.decrypt(Uint8List.fromList(key), legacy);
      expect(result, legacy);
      expect(cipher.isEncrypted(legacy), isFalse);
    });

    test('nonces distintos por cifrado', () async {
      final a = await cipher.encrypt(Uint8List.fromList(key), 'same');
      final b = await cipher.encrypt(Uint8List.fromList(key), 'same');
      expect(a, isNot(equals(b)));
    });
  });
}
