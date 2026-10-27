import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

void main() {
  test('bad decrypt deletes only the unreadable salt and returns null', () async {
    var deleted = false;

    final value = await readWalletSaltWithRecovery(
      read: () async => throw PlatformException(
        code: 'Exception encountered, read',
        message: 'BadPaddingException: BAD_DECRYPT',
      ),
      delete: () async => deleted = true,
    );

    expect(value, isNull);
    expect(deleted, isTrue);
  });

  test('unrelated storage errors are propagated without deleting the key', () async {
    var deleted = false;
    final error = PlatformException(code: 'write', message: 'disk unavailable');

    await expectLater(
      readWalletSaltWithRecovery(
        read: () async => throw error,
        delete: () async => deleted = true,
      ),
      throwsA(same(error)),
    );

    expect(deleted, isFalse);
  });
}
