import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_core_dart/src/protocol/didcomm/crypto/didcomm_envelope_v1.dart';
import 'package:identity_core_dart/src/utils/base64_utils.dart';
import 'package:sodium_libs/src/platforms/sodium_windows.dart';
import 'package:sodium_libs/src/sodium_init.dart' as sodium_libs;

import '../helpers/memory_wallet_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isWindows) {
      SodiumWindows.registerWith();
    }
  });

  test('packAnoncrypt produce estructura envelope V1 Credo', () async {
    final sodium = await sodium_libs.SodiumInit.init();
    final recipient = sodium.crypto.sign.keyPair();
    final recipientEd25519 = Uint8List.fromList(recipient.publicKey);

    final envelope = await DidCommEnvelopeV1.packAnoncrypt(
      message: {
        '@type': 'https://didcomm.org/didexchange/1.1/request',
        '@id': 'x',
      },
      recipientEd25519PublicKey: recipientEd25519,
    );

    expect(envelope['protected'], isA<String>());
    expect(envelope['iv'], isA<String>());
    expect(envelope['ciphertext'], isA<String>());
    expect(envelope['tag'], isA<String>());

    final protectedJson = jsonDecode(
      utf8.decode(base64UrlDecode(envelope['protected'] as String)),
    ) as Map<String, dynamic>;

    expect(protectedJson['alg'], 'Anoncrypt');
    expect(protectedJson['enc'], 'xchacha20poly1305_ietf');
    expect(protectedJson['typ'], 'JWM/1.0');
    expect(protectedJson['recipients'], isA<List>());
  });

  test('packAnoncrypt CEK usa seal Askar (80 bytes)', () async {
    final sodium = await sodium_libs.SodiumInit.init();
    final recipient = sodium.crypto.sign.keyPair();
    final recipientEd25519 = Uint8List.fromList(recipient.publicKey);

    final envelope = await DidCommEnvelopeV1.packAnoncrypt(
      message: {'hello': 'world'},
      recipientEd25519PublicKey: recipientEd25519,
    );

    final protectedJson = jsonDecode(
      utf8.decode(base64UrlDecode(envelope['protected'] as String)),
    ) as Map<String, dynamic>;
    final recipientEntry =
        (protectedJson['recipients'] as List).first as Map<String, dynamic>;
    final encryptedKey = base64UrlDecode(
      recipientEntry['encrypted_key'] as String,
    );

    // sealBytes (48) + CEK (32) = 80; contrato Askar CryptoBox.seal
    expect(encryptedKey.length, sodium.crypto.box.sealBytes + 32);
  });

  test('pack/unpack Anoncrypt round-trip mensaje', () async {
    final sodium = await sodium_libs.SodiumInit.init();
    final recipient = sodium.crypto.sign.keyPair();
    final recipientEd25519 = Uint8List.fromList(recipient.publicKey);
    final privateJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(recipientEd25519),
      'd': base64UrlEncode(recipient.secretKey.extractBytes()),
    };
    final publicJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(recipientEd25519),
    };

    final original = {
      '@type': 'https://didcomm.org/didexchange/1.1/response',
      '@id': 'resp-1',
      'did': 'did:peer:2.test',
    };
    final envelope = await DidCommEnvelopeV1.packAnoncrypt(
      message: original,
      recipientEd25519PublicKey: recipientEd25519,
    );
    final decoded = await DidCommEnvelopeV1.unpack(
      envelope: envelope,
      recipientEd25519PrivateJwk: privateJwk,
      recipientEd25519PublicJwk: publicJwk,
    );
    expect(decoded['@type'], original['@type']);
    expect(decoded['did'], original['did']);
  });

  test('packAuthcrypt round-trip mensaje', () async {
    final sodium = await sodium_libs.SodiumInit.init();
    final sender = sodium.crypto.sign.keyPair();
    final recipient = sodium.crypto.sign.keyPair();
    final senderEd25519 = Uint8List.fromList(sender.publicKey);
    final recipientEd25519 = Uint8List.fromList(recipient.publicKey);
    final senderPrivateJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(senderEd25519),
      'd': base64UrlEncode(sender.secretKey.extractBytes()),
    };
    final senderPublicJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(senderEd25519),
    };
    final recipientPrivateJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(recipientEd25519),
      'd': base64UrlEncode(recipient.secretKey.extractBytes()),
    };
    final recipientPublicJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(recipientEd25519),
    };

    final original = {
      '@type': 'https://didcomm.org/didexchange/1.1/request',
      '@id': 'req-1',
      'did': 'did:peer:4.test',
    };
    final envelope = await DidCommEnvelopeV1.packAuthcrypt(
      message: original,
      recipientEd25519PublicKey: recipientEd25519,
      senderEd25519PrivateJwk: senderPrivateJwk,
      senderEd25519PublicJwk: senderPublicJwk,
    );
    final protectedJson = jsonDecode(
      utf8.decode(base64UrlDecode(envelope['protected'] as String)),
    ) as Map<String, dynamic>;
    expect(protectedJson['alg'], 'Authcrypt');

    final decoded = await DidCommEnvelopeV1.unpack(
      envelope: envelope,
      recipientEd25519PrivateJwk: recipientPrivateJwk,
      recipientEd25519PublicJwk: recipientPublicJwk,
    );
    expect(decoded['@type'], original['@type']);
    expect(decoded['did'], original['did']);
  });

  const runLive = bool.fromEnvironment('SPIKE_LIVE_ISSUER');

  test(
    'acceptInvitation contra issuer local (integration)',
    () async {
      final invRes = await HttpClient()
          .postUrl(
            Uri.parse(
              'http://localhost:9001/v1/issuers/gcba-issuer/didcomm/create-invitation',
            ),
          )
        ..headers.contentType = ContentType.json
        ..write('{}');
      final invJson = jsonDecode(
        await (await invRes.close()).transform(utf8.decoder).join(),
      ) as Map<String, dynamic>;

      final invitation = OobParser.parse(invJson['invitation'] as String)!;

      final storage = MemoryWalletSecureStorage();
      final service = WalletService(walletSecureStorage: storage);
      final dir = Directory.systemTemp.createTempSync('env-v1-').path;
      final session = await service.create(
        walletId: 'envelope-v1-test',
        pin: '123456',
        directory: dir,
      );

      final connection = await session.didcomm.acceptInvitation(invitation);
      expect(connection.state, ConnectionState.complete);
    },
    skip: !runLive ? 'Definir --dart-define=SPIKE_LIVE_ISSUER=true' : false,
  );
}
