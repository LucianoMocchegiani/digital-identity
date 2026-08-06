import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/bbs/reveal_frame.dart';

void main() {
  group('buildRevealFrame', () {
    final credential = {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': ['VerifiableCredential', 'GenericCredential'],
      'credentialSubject': {
        'id': 'did:key:zHolder',
        'name': 'Juan Perez',
        'documentNumber': '12345678',
      },
    };

    test('revela name e id; omite documentNumber', () {
      final frame = buildRevealFrame(credential, [
        '\$.credentialSubject.name',
      ]);
      final subject = frame['credentialSubject'] as Map;
      expect(subject['@explicit'], isTrue);
      expect(subject.containsKey('name'), isTrue);
      expect(subject.containsKey('id'), isTrue);
      expect(subject.containsKey('documentNumber'), isFalse);
    });

    test('ignora paths que no son credentialSubject.propiedad', () {
      final frame = buildRevealFrame(credential, [
        '\$.type',
        '\$.credentialSubject.name',
      ]);
      final subject = frame['credentialSubject'] as Map;
      expect(subject.containsKey('name'), isTrue);
    });
  });

  group('extractRevealPathsFromPresentationDefinition', () {
    test('lee fields.path string y list', () {
      final pd = {
        'input_descriptors': [
          {
            'constraints': {
              'fields': [
                {
                  'path': ['\$.type', '\$.credentialSubject.name'],
                },
                {'path': '\$.credentialSubject.documentNumber'},
              ],
            },
          },
        ],
      };
      final paths = extractRevealPathsFromPresentationDefinition(pd);
      expect(paths, contains('\$.credentialSubject.name'));
      expect(paths, contains('\$.credentialSubject.documentNumber'));
      expect(paths, contains('\$.type'));
    });
  });

  group('presentationDefinitionForHolderVpSigning', () {
    test('añade Ed25519 a ldp_vc.proof_type si hay VC BBS', () {
      final pd = {
        'id': 'pd-1',
        'format': {
          'ldp_vc': {
            'proof_type': ['BbsBlsSignature2020', 'BbsBlsSignatureProof2020'],
          },
        },
        'input_descriptors': [
          {
            'id': 'd1',
            'format': {
              'ldp_vc': {
                'proof_type': ['BbsBlsSignature2020'],
              },
            },
          },
        ],
      };
      final vc = {
        'proof': {'type': 'BbsBlsSignature2020'},
      };
      final out = presentationDefinitionForHolderVpSigning(pd, [vc]);
      final top = (out['format'] as Map)['ldp_vc'] as Map;
      expect(top['proof_type'], contains('Ed25519Signature2018'));
      final desc = (out['input_descriptors'] as List).first as Map;
      final descLdp = (desc['format'] as Map)['ldp_vc'] as Map;
      expect(descLdp['proof_type'], contains('Ed25519Signature2018'));
    });

    test('no modifica PD si no hay BBS', () {
      final pd = {
        'format': {
          'ldp_vc': {
            'proof_type': ['Ed25519Signature2018'],
          },
        },
      };
      final vc = {
        'proof': {'type': 'Ed25519Signature2018'},
      };
      final out = presentationDefinitionForHolderVpSigning(pd, [vc]);
      expect(out, same(pd));
    });
  });
}
