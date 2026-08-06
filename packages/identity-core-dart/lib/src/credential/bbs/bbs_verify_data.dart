import 'dart:typed_data';

import 'bbs_nquads.dart';
import 'constants.dart';
import 'materialize_reveal.dart';

/// Datos de verify/derive alineados al pipeline MATTR (mensajes + índices).
class BbsDeriveVerifyData {
  const BbsDeriveVerifyData({
    required this.proofStatements,
    required this.documentStatements,
    required this.revealStatements,
    required this.revealIndices,
    required this.messages,
    required this.revealedDocument,
  });

  final List<String> proofStatements;
  final List<String> documentStatements;
  final List<String> revealStatements;

  /// Índices revelados sobre [messages] = proofStatements ++ documentStatements.
  final List<int> revealIndices;
  final List<Uint8List> messages;
  final Map<String, dynamic> revealedDocument;
}

/// Construye el documento de proof options como tras `getProofs` MATTR
/// (compact a `https://w3id.org/security/v2`, sin `proofValue`).
Map<String, dynamic> bbsProofOptionsForCanonize(Map<String, dynamic> proof) {
  return {
    '@context': 'https://w3id.org/security/v2',
    // Tras compact MATTR el type queda prefijado `sec:`.
    'type': 'sec:$kBbsProofType',
    'created': proof['created'],
    'proofPurpose': proof['proofPurpose'] ?? 'assertionMethod',
    'verificationMethod': proof['verificationMethod'],
  };
}

/// Construye mensajes + índices de selective disclosure (fase 2 LD).
///
/// Alineado a MATTR `deriveProof`: proofStatements (canonize proof options con
/// security/v2) ++ documentStatements (documento sin proof).
Future<BbsDeriveVerifyData> buildBbsDeriveVerifyData({
  required Map<String, dynamic> credential,
  required Map<String, dynamic> revealDocument,
  Map<String, dynamic>? issuerDidDocument,
  Map<String, dynamic>? extraDocuments,
  List<String>? proofStatementsOverride,
  List<String>? documentStatementsOverride,
  List<String>? revealStatementsOverride,
}) async {
  final proofRaw = credential['proof'];
  if (proofRaw is! Map) {
    throw ArgumentError('credential.proof ausente');
  }
  final proof = Map<String, dynamic>.from(proofRaw);

  final withoutProof = Map<String, dynamic>.from(credential)..remove('proof');
  final revealed = materializeRevealDocument(
    credential: withoutProof,
    revealDocument: revealDocument,
  );

  final proofStatements = proofStatementsOverride ??
      await canonizeToStatements(
        bbsProofOptionsForCanonize(proof),
        issuerDidDocument: issuerDidDocument,
        extraDocuments: extraDocuments,
      );
  final documentStatements = documentStatementsOverride ??
      await canonizeToStatements(
        withoutProof,
        issuerDidDocument: issuerDidDocument,
        extraDocuments: extraDocuments,
      );
  final revealStatements = revealStatementsOverride ??
      await canonizeToStatements(
        revealed,
        issuerDidDocument: issuerDidDocument,
        extraDocuments: extraDocuments,
      );

  final proofCount = proofStatements.length;
  final revealIndices = <int>[
    for (var i = 0; i < proofCount; i++) i,
  ];
  for (final stmt in revealStatements) {
    final idx = documentStatements.indexOf(stmt);
    if (idx < 0) {
      throw StateError(
        'Statement del reveal no encontrada en el documento firmado: $stmt',
      );
    }
    revealIndices.add(idx + proofCount);
  }

  final allStatements = [...proofStatements, ...documentStatements];
  return BbsDeriveVerifyData(
    proofStatements: proofStatements,
    documentStatements: documentStatements,
    revealStatements: revealStatements,
    revealIndices: revealIndices,
    messages: statementsToMessages(allStatements),
    revealedDocument: revealed,
  );
}
