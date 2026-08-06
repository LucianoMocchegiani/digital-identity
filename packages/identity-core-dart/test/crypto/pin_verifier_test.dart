import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

void main() {
  late PinVerifier verifier;
  late Uint8List salt;

  setUp(() {
    verifier = PinVerifier();
    salt = Uint8List.fromList(List<int>.generate(16, (i) => i));
  });

  test('deriveEncryptionKey y derivePinHash producen valores distintos', () async {
    const pin = '123456';
    final enc = await verifier.deriveEncryptionKey(pin: pin, salt: salt);
    final hash = await verifier.derivePinHash(pin: pin, salt: salt);
    expect(enc, isNot(equals(hash)));
    expect(enc.length, 32);
    expect(hash.length, 32);
  });

  test('verifyPinHash acepta hash correcto y rechaza incorrecto', () async {
    const pin = '123456';
    final hash = await verifier.derivePinHash(pin: pin, salt: salt);
    final wrong = await verifier.derivePinHash(pin: '000000', salt: salt);

    expect(
      verifier.verifyPinHash(expected: hash, actual: hash),
      isTrue,
    );
    expect(
      verifier.verifyPinHash(expected: hash, actual: wrong),
      isFalse,
    );
  });
}
