import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_verify_data.dart';
import 'package:identity_core_dart/src/credential/bbs/materialize_reveal.dart';

void main() {
  final fixtures = Directory('test/fixtures');
  final inputFile = File('${fixtures.path}/bbs_ld_derive_input.json');
  final debugFile = File('${fixtures.path}/bbs_ld_derive_debug.json');

  group('materializeRevealDocument', () {
    test('quita claims no listados en el frame', () {
      final revealed = materializeRevealDocument(
        credential: {
          '@context': ['https://www.w3.org/2018/credentials/v1'],
          'type': ['VerifiableCredential'],
          'credentialSubject': {
            'id': 'did:example:holder',
            'name': 'Ada',
            'secret': 'no',
          },
          'proof': {'type': 'BbsBlsSignature2020'},
        },
        revealDocument: {
          'credentialSubject': {
            '@explicit': true,
            'id': {},
            'name': {},
          },
        },
      );
      expect(revealed.containsKey('proof'), isFalse);
      expect(revealed['credentialSubject'], {
        'id': 'did:example:holder',
        'name': 'Ada',
      });
    });
  });

  group('buildBbsDeriveVerifyData (golden MATTR statements)', () {
    test('índices coinciden con bbs_derive_debug', () async {
      if (!inputFile.existsSync() || !debugFile.existsSync()) {
        fail('Faltan fixtures bbs_ld_derive_*.json — generar con tool/bbs_derive_debug.mjs');
      }
      final input =
          jsonDecode(inputFile.readAsStringSync()) as Map<String, dynamic>;
      final debug =
          jsonDecode(debugFile.readAsStringSync()) as Map<String, dynamic>;

      final docStatements = (debug['documentStatements'] as List).cast<String>();
      final revealStatements =
          (debug['revealDocumentStatements'] as List).cast<String>();
      final expectedIndices =
          (debug['revealIndices'] as List).map((e) => e as int).toList();

      final data = await buildBbsDeriveVerifyData(
        credential: Map<String, dynamic>.from(input['credential'] as Map),
        revealDocument:
            Map<String, dynamic>.from(input['revealDocument'] as Map),
        issuerDidDocument:
            Map<String, dynamic>.from(input['issuerDidDocument'] as Map),
        proofStatementsOverride:
            (debug['proofStatements'] as List).cast<String>(),
        documentStatementsOverride: docStatements,
        revealStatementsOverride: revealStatements,
      );

      expect(data.revealIndices, expectedIndices);
      expect(data.revealedDocument['credentialSubject'], {
        'id': 'did:example:holder',
        'name': 'Ada',
      });
    });
  });
}
