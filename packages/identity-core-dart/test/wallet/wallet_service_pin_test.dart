import 'dart:typed_data';

import 'package:convert/convert.dart' as hex_codec;
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../helpers/memory_wallet_secure_storage.dart';

void main() {
  late MemoryWalletSecureStorage storage;
  late WalletService service;
  late PinVerifier verifier;

  const walletId = 'test-wallet';
  const pin = '123456';
  const wrongPin = '654321';

  setUp(() {
    storage = MemoryWalletSecureStorage();
    service = WalletService(walletSecureStorage: storage);
    verifier = PinVerifier();
  });

  test('unlock con PIN incorrecto lanza WrongPinError antes de abrir Isar', () async {
    final salt = Uint8List.fromList(List<int>.generate(16, (i) => i + 1));
    final pinHash = await verifier.derivePinHash(pin: pin, salt: salt);

    await storage.write(
      key: 'wallet_salt_$walletId',
      value: hex_codec.hex.encode(salt),
    );
    await storage.write(
      key: 'wallet_pin_hash_$walletId',
      value: hex_codec.hex.encode(pinHash),
    );

    expect(
      () => service.unlock(
        walletId: walletId,
        pin: wrongPin,
        directory: '/tmp/wallet-test',
      ),
      throwsA(isA<WrongPinError>()),
    );
  });

  test('wallet sin hash de PIN (legacy) no valida PIN en unlock', () async {
    final salt = Uint8List.fromList(List<int>.generate(16, (i) => i + 2));
    await storage.write(
      key: 'wallet_salt_$walletId',
      value: hex_codec.hex.encode(salt),
    );

    try {
      await service.unlock(
        walletId: walletId,
        pin: wrongPin,
        directory: '/tmp/wallet-test',
      );
    } on WrongPinError {
      fail('no debe lanzar WrongPinError sin hash de PIN legacy');
    } catch (_) {
      // Isar u otro error tras pasar verificación legacy es esperado en VM.
    }
  });

  test('reset elimina salt y hash de PIN del storage', () async {
    await storage.write(key: 'wallet_salt_$walletId', value: 'aa');
    await storage.write(key: 'wallet_pin_hash_$walletId', value: 'bb');

    await service.reset(walletId: walletId, directory: '/tmp');

    expect(await storage.read(key: 'wallet_salt_$walletId'), isNull);
    expect(await storage.read(key: 'wallet_pin_hash_$walletId'), isNull);
  });
}
