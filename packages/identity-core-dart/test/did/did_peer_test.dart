import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/did/did_peer.dart';
import 'package:identity_core_dart/src/utils/base64_utils.dart';

void main() {
  test('createNumAlgo4 round-trip resolve', () {
    final ed25519 = Uint8List.fromList(List.generate(32, (i) => i + 1));
    final x25519 = Uint8List.fromList(List.generate(32, (i) => i + 33));

    final edJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(ed25519),
    };
    final xJwk = {
      'kty': 'OKP',
      'crv': 'X25519',
      'x': base64UrlEncode(x25519),
    };

    final did = DidPeer.createNumAlgo4(
      ed25519PublicJwk: edJwk,
      x25519PublicJwk: xJwk,
      serviceEndpoint: 'https://wallet.example/didcomm',
    );

    expect(did, startsWith('did:peer:4z'));
    expect(did.contains(':z'), isTrue);

    final doc = DidPeer.resolve(did);
    expect(doc['id'], did);
    expect(doc['authentication'], isA<List>());
    expect(doc['keyAgreement'], isA<List>());
    expect(doc['service'], isA<List>());

    final auth = (doc['authentication'] as List).first as Map<String, dynamic>;
    expect(auth['type'], 'Ed25519VerificationKey2018');
    expect(auth['publicKeyBase58'], isNotEmpty);
  });

  test('createNumAlgo4 produce formato long-form Credo', () {
    final edJwk = {
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(Uint8List(32)),
    };
    final xJwk = {
      'kty': 'OKP',
      'crv': 'X25519',
      'x': base64UrlEncode(Uint8List(32)),
    };

    final did = DidPeer.createNumAlgo4(
      ed25519PublicJwk: edJwk,
      x25519PublicJwk: xJwk,
    );

    final parts = did.split(':');
    expect(parts[2], startsWith('4z'));
    final payload = did.substring(did.indexOf(':z', 10) + 1);
    expect(payload, startsWith('z'));
    expect(() => utf8.decode(base64UrlDecode(payload)), throwsA(anything));
  });
}
