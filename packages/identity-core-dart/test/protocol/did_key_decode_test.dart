import 'dart:typed_data';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sodium_libs/src/platforms/sodium_windows.dart';
import 'package:sodium_libs/src/sodium_platform.dart';
import 'package:identity_core_dart/src/protocol/didcomm/crypto/didcomm_envelope_v1.dart';
import 'package:identity_core_dart/src/protocol/didcomm/crypto/libsodium_ed25519.dart';
import 'package:identity_core_dart/src/utils/multibase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isWindows) {
      SodiumWindows.registerWith();
    }
  });

  test('libsodium convierte did:key Credo Ed25519 a X25519', () async {
    const did = 'did:key:z6MkwTZQx5aw794Xg6MhkjqttFzjxreDZm3voY3RXGtjH1FC';
    final pk = DidCommEnvelopeV1.ed25519PublicKeyBytesFromDid(did)!;
    expect(pk.length, 32);

    final x25519 = await LibsodiumEd25519.publicKeyToCurve25519(pk);
    expect(x25519.length, 32);
  });

  test('packAnoncrypt con clave Credo real', () async {
    const did = 'did:key:z6MkwTZQx5aw794Xg6MhkjqttFzjxreDZm3voY3RXGtjH1FC';
    final pk = DidCommEnvelopeV1.ed25519PublicKeyBytesFromDid(did)!;

    final envelope = await DidCommEnvelopeV1.packAnoncrypt(
      message: {
        '@type': 'https://didcomm.org/didexchange/1.1/request',
        '@id': 'test',
      },
      recipientEd25519PublicKey: pk,
    );

    expect(envelope['protected'], isA<String>());
    expect(envelope['ciphertext'], isA<String>());
  });
}
