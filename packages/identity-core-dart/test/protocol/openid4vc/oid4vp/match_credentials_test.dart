import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/models/credential_record.dart';
import 'package:identity_core_dart/src/credential/models/sd_jwt_vc_record.dart';
import 'package:identity_core_dart/src/credential/models/w3c_credential_record.dart';
import 'package:identity_core_dart/src/protocol/openid4vc/oid4vp/match_credentials.dart';
import 'package:identity_core_dart/src/protocol/openid4vc/oid4vp/models/dcql_query.dart';
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

  group('matchDcql credential_sets', () {
    final now = DateTime.utc(2026, 1, 1);
    final packVc = SdJwtVcRecord(
      id: 'pack-vc',
      createdAt: now,
      compactSdJwt: 'e30.e30.',
      vct: 'urn:faciliter:pack:1',
      prettyClaims: const {},
    );

    Map<String, dynamic> twoQueriesJson({bool withSets = false}) {
      return {
        'credentials': [
          {
            'id': 'faciliter_pack',
            'format': 'dc+sd-jwt',
            'meta': {
              'vct_values': ['urn:faciliter:pack:1'],
            },
          },
          {
            'id': 'faciliter_staff',
            'format': 'dc+sd-jwt',
            'meta': {
              'vct_values': ['urn:faciliter:staff:1'],
            },
          },
        ],
        if (withSets)
          'credential_sets': [
            {
              'options': [
                ['faciliter_pack'],
                ['faciliter_staff'],
              ],
              'required': true,
            },
          ],
      };
    }

    test('sin credential_sets: dos queries son AND', () async {
      final raw = twoQueriesJson();
      final result = await matchDcql(
        query: DcqlQuery.fromJson(raw),
        credentials: [packVc],
      );
      expect(result.areAllSatisfied, isFalse);
      expect(result.entries.where((e) => e.isSatisfied), hasLength(1));
    });

    test('con credential_sets OR: una VC de pack alcanza', () async {
      final raw = twoQueriesJson(withSets: true);
      final result = await matchDcql(
        query: DcqlQuery.fromJson(raw),
        credentials: [packVc],
        credentialSets: parseDcqlCredentialSets(raw),
      );
      expect(result.areAllSatisfied, isTrue);
      expect(
        result.entries
            .firstWhere((e) => e.inputDescriptorId == 'faciliter_pack')
            .isSatisfied,
        isTrue,
      );
      expect(
        result.entries
            .firstWhere((e) => e.inputDescriptorId == 'faciliter_staff')
            .isSatisfied,
        isFalse,
      );
    });
  });
}
