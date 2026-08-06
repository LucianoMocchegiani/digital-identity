import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_credential.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_crypto.dart';
import 'package:identity_core_dart/src/credential/bbs/claim_path_filter.dart';
import 'package:identity_core_dart/src/credential/display/labeled_claim.dart';

class _FakeBbsCrypto implements BbsCryptoBackend {
  @override
  Future<Map<String, dynamic>> deriveProof({
    required Map<String, dynamic> credential,
    required Map<String, dynamic> revealDocument,
    String? nonce,
    Map<String, dynamic>? issuerDidDocument,
  }) async {
    final subject = Map<String, dynamic>.from(
      credential['credentialSubject'] as Map,
    );
    return {
      ...credential,
      'credentialSubject': {
        'id': subject['id'],
        'name': subject['name'],
      },
      'proof': {
        'type': 'BbsBlsSignatureProof2020',
        'proofValue': 'fake',
        'nonce': nonce,
      },
    };
  }

  @override
  Future<({bool verified, String? error})> verifyCredential({
    required Map<String, dynamic> credential,
    Map<String, dynamic>? issuerDidDocument,
  }) async =>
      (verified: true, error: null);
}

void main() {
  tearDown(() => debugSetBbsCryptoBackend(null));

  test('maybeDeriveBbsCredentialForPex deriva con backend fake', () async {
    debugSetBbsCryptoBackend(_FakeBbsCrypto());
    final vc = {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': ['VerifiableCredential', 'GenericCredential'],
      'credentialSubject': {
        'id': 'did:key:z1',
        'name': 'Ana',
        'documentNumber': '99',
      },
      'proof': {'type': 'BbsBlsSignature2020', 'proofValue': 'sig'},
    };
    final pd = {
      'input_descriptors': [
        {
          'constraints': {
            'fields': [
              {'path': '\$.credentialSubject.name'},
            ],
          },
        },
      ],
    };
    final derived = await maybeDeriveBbsCredentialForPex(
      credential: vc,
      presentationDefinition: pd,
      nonce: 'challenge-1',
    );
    expect(derived['proof'], isA<Map>());
    expect((derived['proof'] as Map)['type'], 'BbsBlsSignatureProof2020');
    expect(
      (derived['credentialSubject'] as Map).containsKey('documentNumber'),
      isFalse,
    );
    expect((derived['credentialSubject'] as Map)['name'], 'Ana');
  });

  test('filterClaimsByPresentationDefinition filtra keys', () {
    final claims = [
      const LabeledClaim(label: 'Nombre', key: 'name', value: 'Ana'),
      const LabeledClaim(label: 'Doc', key: 'documentNumber', value: '99'),
      const LabeledClaim(label: 'Id', key: 'id', value: 'did:key:z1'),
    ];
    final filtered = filterClaimsByPresentationDefinition(
      claims: claims,
      presentationDefinition: {
        'input_descriptors': [
          {
            'constraints': {
              'fields': [
                {'path': '\$.credentialSubject.name'},
              ],
            },
          },
        ],
      },
      claimKey: (c) => c.key,
    );
    expect(filtered.map((c) => c.key), containsAll(['name', 'id']));
    expect(filtered.map((c) => c.key), isNot(contains('documentNumber')));
  });
}
