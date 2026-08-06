import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/models/credential_record.dart';
import 'package:identity_core_dart/src/credential/models/w3c_credential_record.dart';
import 'package:identity_core_dart/src/protocol/openid4vc/oid4vp/match_credentials.dart';
import 'package:identity_core_dart/src/protocol/openid4vc/oid4vp/models/presentation_definition.dart';

void main() {
  group('matchPex', () {
    test('aplica contains al array type y exige los claims declarados',
        () async {
      final definition = PresentationDefinition.fromJson({
        'id': 'verify-generic-credential',
        'input_descriptors': [
          {
            'id': 'generic-credential',
            'constraints': {
              'fields': [
                {
                  'path': [r'$.type'],
                  'filter': {
                    'type': 'array',
                    'contains': {'const': 'GenericCredential'},
                  },
                },
                {
                  'path': [r'$.credentialSubject.name'],
                },
              ],
            },
          },
        ],
      });
      final now = DateTime.utc(2026, 1, 1);
      final credentials = <W3cCredentialRecord>[
        W3cCredentialRecord(
          id: 'generic',
          createdAt: now,
          claimFormat: ClaimFormat.w3cLdp,
          credential: {
            'type': ['VerifiableCredential', 'GenericCredential'],
            'credentialSubject': {'name': 'Juan Perez'},
          },
          types: const ['VerifiableCredential', 'GenericCredential'],
        ),
        W3cCredentialRecord(
          id: 'other',
          createdAt: now,
          claimFormat: ClaimFormat.w3cLdp,
          credential: {
            'type': ['VerifiableCredential', 'OtherCredential'],
            'credentialSubject': {'name': 'Juan Perez'},
          },
          types: const ['VerifiableCredential', 'OtherCredential'],
        ),
      ];

      final result = await matchPex(
        definition: definition,
        credentials: credentials,
      );

      expect(result.areAllSatisfied, isTrue);
      expect(result.entries.single.matchingCredentials, hasLength(1));
      expect(
        result.entries.single.matchingCredentials!.single.id,
        equals('generic'),
      );
    });
  });
}
