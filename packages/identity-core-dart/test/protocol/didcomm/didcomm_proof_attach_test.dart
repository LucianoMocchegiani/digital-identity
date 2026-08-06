import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/protocol/didcomm/proof/didcomm_proof_attach.dart';

void main() {
  group('DidCommProofAttach', () {
    test('extrae presentation_definition y challenge del request', () {
      const message = {
        '@type':
            'https://didcomm.org/present-proof/2.0/request-presentation',
        'request_presentations~attach': [
          {
            'data': {
              'json': {
                'options': {'challenge': 'challenge-abc'},
                'presentation_definition': {
                  'id': 'req-gen-1',
                  'input_descriptors': [
                    {
                      'id': 'desc-generic-1',
                      'constraints': {'fields': []},
                    },
                  ],
                },
              },
            },
          },
        ],
      };

      final pd =
          DidCommProofAttach.presentationDefinitionFromMessage(message);
      expect(pd, isNotNull);
      expect(pd!['id'], 'req-gen-1');

      expect(
        DidCommProofAttach.challengeFromMessage(message),
        'challenge-abc',
      );
    });
  });
}
