import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'bbs_crypto_backend.dart';
import 'bbs_key.dart';
import 'bbs_verify_data.dart';
import 'constants.dart';
import 'ffi/bbs_pairing.dart';

/// Suite LD Dart + pairing FFI (fase 2) — derive/verify holder.
///
/// MVP: materialize reveal sin `jsonld.frame` (VCs sin blank nodes).
/// Pairing: [BbsPairingApi] (`libbbs`).
class DartBbsLdSuite implements BbsCryptoBackend {
  DartBbsLdSuite({BbsPairingApi? pairing}) : _pairing = pairing;

  BbsPairingApi? _pairing;

  BbsPairingApi get pairing {
    final existing = _pairing;
    if (existing != null) return existing;
    final opened = FfiBbsPairingApi.open();
    _pairing = opened;
    return opened;
  }

  @override
  Future<Map<String, dynamic>> deriveProof({
    required Map<String, dynamic> credential,
    required Map<String, dynamic> revealDocument,
    String? nonce,
    Map<String, dynamic>? issuerDidDocument,
  }) async {
    if (issuerDidDocument == null) {
      throw ArgumentError(
        'DartBbsLdSuite.deriveProof requiere issuerDidDocument',
      );
    }
    final proof = credential['proof'];
    if (proof is! Map) {
      throw ArgumentError('credential.proof ausente');
    }
    final proofMap = Map<String, dynamic>.from(proof);
    if (proofMap['type'] != kBbsProofType) {
      throw ArgumentError(
        'deriveProof espera $kBbsProofType, got ${proofMap['type']}',
      );
    }

    final verifyData = await buildBbsDeriveVerifyData(
      credential: credential,
      revealDocument: revealDocument,
      issuerDidDocument: issuerDidDocument,
    );

    final nonceBytes = nonce != null
        ? Uint8List.fromList(utf8.encode(nonce))
        : _randomNonce(50);

    final vmUrl = proofMap['verificationMethod'] as String;
    final publicKey = extractBbsPublicKeyBytes(
      issuerDidDocument: issuerDidDocument,
      verificationMethodUrl: vmUrl,
    );
    final signature = decodeBbsProofValue(proofMap);

    final derivedProofValue = await pairing.blsCreateProof(
      publicKey: publicKey,
      signature: signature,
      messages: verifyData.messages,
      revealed: verifyData.revealIndices,
      nonce: nonceBytes,
    );

    final derivedProof = <String, dynamic>{
      'type': kBbsProofTypeDerived,
      'created': proofMap['created'],
      'verificationMethod': vmUrl,
      'proofPurpose': proofMap['proofPurpose'] ?? 'assertionMethod',
      'nonce': base64.encode(nonceBytes),
      'proofValue': base64.encode(derivedProofValue),
    };

    return {
      ...verifyData.revealedDocument,
      'proof': derivedProof,
    };
  }

  @override
  Future<({bool verified, String? error})> verifyCredential({
    required Map<String, dynamic> credential,
    Map<String, dynamic>? issuerDidDocument,
  }) async {
    try {
      final proof = credential['proof'];
      if (proof is! Map) {
        return (verified: false, error: 'proof ausente');
      }
      final proofMap = Map<String, dynamic>.from(proof);
      final type = proofMap['type'] as String?;
      if (type != kBbsProofTypeDerived) {
        return (
          verified: false,
          error: 'verifyCredential LD suite MVP solo Proof2020 (got $type)',
        );
      }
      if (issuerDidDocument == null) {
        return (verified: false, error: 'issuerDidDocument requerido');
      }

      // Documento revelado: messages = proofStatements ++ documentStatements.
      final withoutProof = Map<String, dynamic>.from(credential)..remove('proof');
      final data = await buildBbsDeriveVerifyData(
        credential: {
          ...withoutProof,
          // Fake original proof type so helpers accept; we only need doc + proof stmts.
          'proof': {
            ...proofMap,
            'type': kBbsProofType,
            'proofValue': proofMap['proofValue'],
          },
        },
        revealDocument: {
          '@context': withoutProof['@context'],
          'type': withoutProof['type'],
          'credentialSubject': _frameFromSubject(withoutProof['credentialSubject']),
        },
        issuerDidDocument: issuerDidDocument,
      );

      final nonceB64 = proofMap['nonce'] as String?;
      if (nonceB64 == null) {
        return (verified: false, error: 'proof.nonce ausente');
      }
      final nonceBytes = Uint8List.fromList(base64.decode(nonceB64));
      final publicKey = extractBbsPublicKeyBytes(
        issuerDidDocument: issuerDidDocument,
        verificationMethodUrl: proofMap['verificationMethod'] as String,
      );
      final proofBytes = decodeBbsProofValue(proofMap);

      // Mensajes revelados en orden de índices (MATTR blsVerifyProof).
      final revealedMessages = [
        for (final i in data.revealIndices) data.messages[i],
      ];

      final ok = await pairing.blsVerifyProof(
        publicKey: publicKey,
        proof: proofBytes,
        messages: revealedMessages,
        nonce: nonceBytes,
      );
      return (verified: ok, error: ok ? null : 'blsVerifyProof=false');
    } catch (e) {
      return (verified: false, error: e.toString());
    }
  }

  Map<String, dynamic> _frameFromSubject(Object? subject) {
    if (subject is! Map) return {'@explicit': true};
    final frame = <String, dynamic>{'@explicit': true};
    for (final key in subject.keys) {
      frame[key as String] = <String, dynamic>{};
    }
    return frame;
  }

  Uint8List _randomNonce(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rnd.nextInt(256)));
  }
}
