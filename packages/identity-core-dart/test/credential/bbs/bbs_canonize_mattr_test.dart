import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_nquads.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_verify_data.dart';
import 'package:identity_core_dart/src/credential/bbs/materialize_reveal.dart';

/// Compara URDNA2015 Dart (`json_ld_processor`) contra dump MATTR.
void main() {
  final fixtures = Directory('test/fixtures');
  final inputFile = File('${fixtures.path}/bbs_ld_derive_input.json');
  final debugFile = File('${fixtures.path}/bbs_ld_derive_debug.json');

  test('canonize documento Dart == documentStatements MATTR', () async {
    if (!inputFile.existsSync() || !debugFile.existsSync()) {
      fail('Faltan fixtures bbs_ld_derive_*.json');
    }
    final input =
        jsonDecode(inputFile.readAsStringSync()) as Map<String, dynamic>;
    final debug =
        jsonDecode(debugFile.readAsStringSync()) as Map<String, dynamic>;

    final credential =
        Map<String, dynamic>.from(input['credential'] as Map)..remove('proof');
    final issuer =
        Map<String, dynamic>.from(input['issuerDidDocument'] as Map);
    final expected =
        (debug['documentStatements'] as List).cast<String>();

    final actual = await canonizeToStatements(
      credential,
      issuerDidDocument: issuer,
    );

    expect(
      actual,
      expected,
      reason:
          'JsonLdProcessor.normalize debe producir los mismos N-Quads que MATTR',
    );
  });

  test('canonize reveal materializado Dart == revealStatements MATTR', () async {
    final input =
        jsonDecode(inputFile.readAsStringSync()) as Map<String, dynamic>;
    final debug =
        jsonDecode(debugFile.readAsStringSync()) as Map<String, dynamic>;

    final credential =
        Map<String, dynamic>.from(input['credential'] as Map)..remove('proof');
    final revealFrame =
        Map<String, dynamic>.from(input['revealDocument'] as Map);
    final issuer =
        Map<String, dynamic>.from(input['issuerDidDocument'] as Map);
    final expected =
        (debug['revealDocumentStatements'] as List).cast<String>();

    final revealed = materializeRevealDocument(
      credential: credential,
      revealDocument: revealFrame,
    );
    final actual = await canonizeToStatements(
      revealed,
      issuerDidDocument: issuer,
    );

    expect(actual, expected);
  });

  test('canonize proof options Dart == proofStatements MATTR', () async {
    final input =
        jsonDecode(inputFile.readAsStringSync()) as Map<String, dynamic>;
    final debug =
        jsonDecode(debugFile.readAsStringSync()) as Map<String, dynamic>;
    final proof = Map<String, dynamic>.from(
      (input['credential'] as Map)['proof'] as Map,
    );
    final expected = (debug['proofStatements'] as List).cast<String>();

    final actual = await canonizeToStatements(
      bbsProofOptionsForCanonize(proof),
    );
    expect(actual, expected);
  });
}
