import 'package:identity_core_dart/src/did/did_peer.dart';
import 'package:identity_core_dart/src/protocol/didcomm/did_doc_recipient_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DidDocRecipientKey', () {
    test('extrae did:key desde authentication de did:peer:4', () {
      final did = DidPeer.createNumAlgo4(
        ed25519PublicJwk: {
          'kty': 'OKP',
          'crv': 'Ed25519',
          'x': '11qYAYKxCrfVS_7TyWQHOg7hcvPapiMlrwIaaPc7hA8',
        },
        x25519PublicJwk: {
          'kty': 'OKP',
          'crv': 'X25519',
          'x': 'KA0HCnRqxfWqQ8wqPky8HBbfuEv2htLA3KZmfFVrCjU',
        },
        serviceEndpoint: 'https://issuer.example/didcomm',
      );

      final doc = DidPeer.resolve(did);
      final keyDid = DidDocRecipientKey.extractEd25519KeyDid(doc);

      expect(keyDid, isNotNull);
      expect(keyDid, startsWith('did:key:z'));
    });
  });
}
