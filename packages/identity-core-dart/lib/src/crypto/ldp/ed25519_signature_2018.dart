import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:json_ld_processor/json_ld_processor.dart';

import '../../kms/kms_service.dart';
import '../../record/models/key_record.dart';
import '../../utils/base64_utils.dart';
import 'ldp_document_loader.dart';

/// Firma Linked Data Proofs `Ed25519Signature2018` (jsonld-signatures).
///
/// Replica el algoritmo que usa Credo-TS al verificar:
/// 1. Canonicaliza con URDNA2015 las *proof options* (sin `jws`) usando el
///    `@context` del documento.
/// 2. Canonicaliza con URDNA2015 el documento (sin `proof`).
/// 3. `verifyData = sha256(canonProof) || sha256(canonDoc)`.
/// 4. Firma JWS detached EdDSA: `sign(utf8(headerB64 + '.') || verifyData)`.
abstract final class Ed25519Signature2018 {
  static const _jwsHeader = '{"alg":"EdDSA","b64":false,"crit":["b64"]}';

  /// Crea el nodo `proof` firmado para [document] (que no debe incluir `proof`).
  ///
  /// [challenge] y [domain] se incluyen en las proof options tal como los
  /// valida `AuthenticationProofPurpose` del verificador.
  static Future<Map<String, dynamic>> createProof({
    required Map<String, dynamic> document,
    required String verificationMethod,
    required String proofPurpose,
    required KmsService kms,
    required KeyRecord signingKey,
    String? challenge,
    String? domain,
    DateTime? created,
  }) async {
    final createdIso = _w3cDate(created ?? DateTime.now().toUtc());

    final proofOptions = <String, dynamic>{
      'type': 'Ed25519Signature2018',
      'created': createdIso,
      'verificationMethod': verificationMethod,
      'proofPurpose': proofPurpose,
      if (challenge != null) 'challenge': challenge,
      if (domain != null) 'domain': domain,
    };

    final verifyData = await _createVerifyData(
      document: document,
      proofOptions: proofOptions,
    );

    final headerB64 =
        base64UrlEncode(Uint8List.fromList(utf8.encode(_jwsHeader)));
    final signingInput = Uint8List.fromList([
      ...utf8.encode('$headerB64.'),
      ...verifyData,
    ]);
    final signature = await kms.sign(key: signingKey, payload: signingInput);

    return {
      ...proofOptions,
      'jws': '$headerB64..${base64UrlEncode(signature)}',
    };
  }

  /// `sha256(urdna2015(proofOptions con @context del doc)) || sha256(urdna2015(document))`.
  static Future<Uint8List> _createVerifyData({
    required Map<String, dynamic> document,
    required Map<String, dynamic> proofOptions,
  }) async {
    final options = JsonLdOptions(
      documentLoader: ldpDocumentLoader,
      safeMode: true,
    );

    // jsonld-signatures canonicaliza el proof con el @context del documento.
    final proofWithContext = <String, dynamic>{
      '@context': document['@context'],
      ...proofOptions,
    };

    final canonProof = await JsonLdProcessor.normalize(
      proofWithContext,
      options: options,
    );
    final canonDocument = await JsonLdProcessor.normalize(
      document,
      options: options,
    );

    final proofHash = sha256.convert(utf8.encode(canonProof)).bytes;
    final docHash = sha256.convert(utf8.encode(canonDocument)).bytes;
    return Uint8List.fromList([...proofHash, ...docHash]);
  }

  /// Fecha W3C sin microsegundos (`2026-01-01T12:00:00Z`), como `util.w3cDate`.
  static String _w3cDate(DateTime date) {
    final utc = date.toUtc();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${utc.year}-${pad(utc.month)}-${pad(utc.day)}'
        'T${pad(utc.hour)}:${pad(utc.minute)}:${pad(utc.second)}Z';
  }
}
