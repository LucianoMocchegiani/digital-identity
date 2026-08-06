import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/protocol/didcomm/credential/didcomm_credential_attach.dart';

void main() {
  group('DidCommCredentialAttach', () {
    test('lee offers~attach en offer v2', () {
      final offer = {
        'offers~attach': [
          {
            '@id': 'libindy-cred-offer-0',
            'mime-type': 'application/json',
            'data': {'base64': _b64({'credential': {'type': ['VerifiableCredential', 'GenericCredential']}})},
          },
        ],
      };

      final list = DidCommCredentialAttach.listFromMessage(offer);
      expect(list, hasLength(1));
      expect(list.first['@id'], 'libindy-cred-offer-0');
    });

    test('decodifica credential detail desde base64', () {
      final attach = {
        'data': {
          'base64': _b64({
            'credential': {
              'type': ['VerifiableCredential', 'GenericCredential'],
              'issuer': 'did:web:issuer.example',
              'credentialSubject': {'name': 'Juan Perez'},
            },
            'options': {'proofType': 'Ed25519Signature2018'},
          }),
        },
      };

      final vc = DidCommCredentialAttach.credentialFromAttach(attach);
      expect(vc?['issuer'], 'did:web:issuer.example');
      expect(vc?['credentialSubject'], isA<Map>());
    });

    test('mergeIssuedCredentialWithOfferDetail completa subject del offer', () {
      final merged = DidCommCredentialAttach.mergeIssuedCredentialWithOfferDetail(
        issued: const {
          'credentialSubject': {'id': 'did:peer:holder'},
        },
        offerDetail: const {
          'credentialSubject': {
            'id': 'did:peer:holder',
            'name': 'Juan Perez',
            'documentNumber': '12345678',
          },
        },
      );
      final subject = merged['credentialSubject'] as Map<String, dynamic>;
      expect(subject['name'], 'Juan Perez');
      expect(subject['documentNumber'], '12345678');
    });

    test('merge completa subject cuando issued trae solo DID como string', () {
      final merged = DidCommCredentialAttach.mergeIssuedCredentialWithOfferDetail(
        issued: const {
          'credentialSubject': 'did:peer:holder',
        },
        offerDetail: const {
          'credentialSubject': {
            'id': 'did:peer:holder',
            'name': 'Juan Perez',
          },
        },
      );
      final subject = merged['credentialSubject'] as Map<String, dynamic>;
      expect(subject['id'], 'did:peer:holder');
      expect(subject['name'], 'Juan Perez');
    });

    test('normalizeSubjectMap compacta claves JSON-LD expandidas', () {
      final normalized = DidCommCredentialAttach.normalizeSubjectMap({
        'id': 'did:peer:holder',
        'https://schema.org/name': 'Juan Perez',
        'https://w3id.org/citizenship#documentNumber': '12345678',
      });

      expect(normalized['name'], 'Juan Perez');
      expect(normalized['documentNumber'], '12345678');
    });

    test('credentialFromOfferMessage lee offers~attach', () {
      final offer = {
        'offers~attach': [
          {
            'data': {
              'base64': _b64({
                'credential': {
                  'credentialSubject': {'name': 'Ana'},
                },
              }),
            },
          },
        ],
      };

      final vc = DidCommCredentialAttach.credentialFromOfferMessage(offer);
      expect(
        DidCommCredentialAttach.normalizeSubjectMap(vc?['credentialSubject'])['name'],
        'Ana',
      );
    });

    test('attributesFromCredentialPreview mapea attributes', () {
      final claims = DidCommCredentialAttach.attributesFromCredentialPreview({
        'credential_preview': {
          '@type': 'https://didcomm.org/issue-credential/2.0/credential-preview',
          'attributes': [
            {'name': 'name', 'value': 'Juan Perez'},
            {'name': 'documentNumber', 'value': '12345678'},
            {'name': 'id', 'value': 'did:peer:x'},
          ],
        },
      });

      expect(claims['name'], 'Juan Perez');
      expect(claims['documentNumber'], '12345678');
      expect(claims.containsKey('id'), isFalse);
    });

    test('enrichOfferDetailWithPreview completa subject vacío', () {
      final enriched = DidCommCredentialAttach.enrichOfferDetailWithPreview(
        offerDetail: {
          'credentialSubject': {'id': 'did:peer:holder'},
        },
        offerMessage: {
          'credential_preview': {
            'attributes': [
              {'name': 'name', 'value': 'Ana'},
            ],
          },
        },
      );

      final subject = enriched!['credentialSubject'] as Map<String, dynamic>;
      expect(subject['id'], 'did:peer:holder');
      expect(subject['name'], 'Ana');
    });

    test('threadIdFromOfferMessage lee ~thread.thid (no @id)', () {
      final offer = {
        '@id': 'offer-message-id',
        '~thread': {'thid': 'exchange-thread-id'},
      };

      expect(
        DidCommCredentialAttach.threadIdFromOfferMessage(offer),
        'exchange-thread-id',
      );
    });

    test('requestAttachmentsFromOffer copia offers~attach', () {
      final offer = {
        'formats': [
          {
            'attach_id': 'libindy-cred-offer-0',
            'format': 'aries/ld-proof-vc-detail@v1.0',
          },
        ],
        'offers~attach': [
          {
            '@id': 'libindy-cred-offer-0',
            'mime-type': 'application/json',
            'data': {'base64': _b64({'credential': {'id': 'urn:uuid:test'}})},
          },
        ],
      };

      final requests =
          DidCommCredentialAttach.requestAttachmentsFromOffer(offer);
      expect(requests, hasLength(1));
      expect(requests.first['@id'], 'libindy-cred-offer-0');
    });
  });
}

String _b64(Map<String, dynamic> value) =>
    base64.encode(utf8.encode(jsonEncode(value)));
