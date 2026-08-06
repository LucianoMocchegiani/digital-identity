import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/crypto/ldp/ed25519_signature_2018.dart';
import 'package:identity_core_dart/src/kms/software_kms.dart';
import 'package:identity_core_dart/src/record/models/key_record.dart';
import 'package:identity_core_dart/src/utils/base64_utils.dart';

/// Genera una VP firmada con clave determinista y la persiste como fixture.
///
/// El fixture se verifica de forma cruzada con
/// `packages/identity-core/scripts/verify-ldp-vp.mjs`, que usa el mismo
/// stack jsonld-signatures/URDNA2015 que Credo-TS al verificar.
void main() {
  test('createProof produce una VP JSON-LD firmada verificable', () async {
    final seed = Uint8List.fromList(List.generate(32, (i) => i + 1));
    final keyPair = await Ed25519().newKeyPairFromSeed(seed);
    final publicKey = await keyPair.extractPublicKey();

    final publicJwk = <String, dynamic>{
      'kty': 'OKP',
      'crv': 'Ed25519',
      'x': base64UrlEncode(Uint8List.fromList(publicKey.bytes)),
    };
    final signingKey = KeyRecord(
      keyId: 'test-key',
      keyType: KeyType.ed25519,
      publicJwk: publicJwk,
      privateJwk: {...publicJwk, 'd': base64UrlEncode(seed)},
      isHardwareBacked: false,
      createdAt: DateTime.utc(2026),
    );

    final vc = {
      '@context': [
        'https://www.w3.org/2018/credentials/v1',
        'http://schema.org/',
        {'TestCredential': 'https://www.w3.org/2018/credentials#TestCredential'},
      ],
      'id': 'urn:uuid:5c1a4c6d-3f0f-4c8f-9b3a-000000000001',
      'type': ['VerifiableCredential', 'TestCredential'],
      'issuer': 'did:example:issuer',
      'issuanceDate': '2026-01-01T00:00:00Z',
      'credentialSubject': {
        'id': 'did:example:holder',
        'name': 'Juan Prueba',
        'documentNumber': '12345678',
      },
      'proof': {
        'type': 'Ed25519Signature2018',
        'created': '2026-01-01T00:00:00Z',
        'verificationMethod': 'did:example:issuer#key-1',
        'proofPurpose': 'assertionMethod',
        'jws': 'eyJhbGciOiJFZERTQSIsImI2NCI6ZmFsc2UsImNyaXQiOlsiYjY0Il19..'
            'ZmFrZS1maXJtYS1zb2xvLXBhcmEtY2Fub25pemFyLWVsLWRvY3VtZW50bw',
      },
    };

    final document = <String, dynamic>{
      '@context': [
        'https://www.w3.org/2018/credentials/v1',
        'https://identity.foundation/presentation-exchange/submission/v1',
      ],
      'type': ['VerifiablePresentation', 'PresentationSubmission'],
      'holder': 'did:example:holder',
      'presentation_submission': {
        'id': 'submission-1',
        'definition_id': 'definition-1',
        'descriptor_map': [
          {
            'id': 'descriptor-1',
            'format': 'ldp_vc',
            'path': r'$.verifiableCredential[0]',
          },
        ],
      },
      'verifiableCredential': [vc],
    };

    final proof = await Ed25519Signature2018.createProof(
      document: document,
      verificationMethod: 'did:example:holder#key-1',
      proofPurpose: 'authentication',
      challenge: 'challenge-test-123',
      kms: SoftwareKms(),
      signingKey: signingKey,
      created: DateTime.utc(2026, 1, 2, 3, 4, 5),
    );

    expect(proof['type'], 'Ed25519Signature2018');
    expect(proof['challenge'], 'challenge-test-123');
    expect(proof['created'], '2026-01-02T03:04:05Z');
    final jws = proof['jws'] as String;
    expect(
      jws,
      startsWith('eyJhbGciOiJFZERTQSIsImI2NCI6ZmFsc2UsImNyaXQiOlsiYjY0Il19..'),
    );

    final signedVp = {...document, 'proof': proof};
    final fixture = {
      'publicKeyBase64Url': publicJwk['x'],
      'vp': signedVp,
    };
    final outFile = File('test/crypto/ldp/fixtures/signed_vp.json');
    outFile.createSync(recursive: true);
    outFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(fixture),
    );
  });
}
