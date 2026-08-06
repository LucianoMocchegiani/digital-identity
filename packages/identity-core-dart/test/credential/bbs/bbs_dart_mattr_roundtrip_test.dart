import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_key.dart';
import 'package:identity_core_dart/src/credential/bbs/bbs_verify_data.dart';
/// Exporta mensajes Dart y round-trip con MATTR (`tool/bbs_dart_messages_mattr_roundtrip.mjs`).
void main() {
  test('mensajes Dart → MATTR blsCreateProof + jsigs.verify', () async {
    final inputFile = File('test/fixtures/bbs_ld_derive_input.json');
    expect(inputFile.existsSync(), isTrue);

    final input =
        jsonDecode(inputFile.readAsStringSync()) as Map<String, dynamic>;
    final credential = Map<String, dynamic>.from(input['credential'] as Map);
    final revealDocument =
        Map<String, dynamic>.from(input['revealDocument'] as Map);
    final issuer =
        Map<String, dynamic>.from(input['issuerDidDocument'] as Map);
    final nonce = input['nonce'] as String? ?? 'phase2-challenge';

    final data = await buildBbsDeriveVerifyData(
      credential: credential,
      revealDocument: revealDocument,
      issuerDidDocument: issuer,
    );

    final proof = Map<String, dynamic>.from(credential['proof'] as Map);
    final publicKey = extractBbsPublicKeyBytes(
      issuerDidDocument: issuer,
      verificationMethodUrl: proof['verificationMethod'] as String,
    );
    final signature = decodeBbsProofValue(proof);
    final nonceBytes = Uint8List.fromList(utf8.encode(nonce));

    final payload = {
      'publicKeyB64': base64.encode(publicKey),
      'signatureB64': base64.encode(signature),
      'nonceB64': base64.encode(nonceBytes),
      'messagesB64': [
        for (final m in data.messages) base64.encode(m),
      ],
      'revealIndices': data.revealIndices,
      'revealedDocument': data.revealedDocument,
      'proofMeta': {
        'verificationMethod': proof['verificationMethod'],
        'created': proof['created'],
        'proofPurpose': proof['proofPurpose'] ?? 'assertionMethod',
      },
      'issuerDidDocument': issuer,
    };

    final outFile = File('test/fixtures/bbs_ld_dart_messages.json');
    await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));

    final script = File('tool/bbs_dart_messages_mattr_roundtrip.mjs');
    expect(script.existsSync(), isTrue);

    final proc = await Process.start(
      'node',
      [script.absolute.path],
      workingDirectory: Directory.current.path,
      runInShell: Platform.isWindows,
    );
    proc.stdin.add(utf8.encode(jsonEncode(payload)));
    await proc.stdin.close();
    final stdout = await proc.stdout.transform(utf8.decoder).join();
    final stderr = await proc.stderr.transform(utf8.decoder).join();
    final code = await proc.exitCode;

    expect(code, 0, reason: 'stderr=$stderr stdout=$stdout');
    final result = jsonDecode(stdout) as Map<String, dynamic>;
    expect(result['ok'], isTrue);
    expect(result['blsVerifyProof'], isTrue, reason: '$result');
    expect(result['jsigsVerified'], isTrue, reason: '$result $stderr');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
