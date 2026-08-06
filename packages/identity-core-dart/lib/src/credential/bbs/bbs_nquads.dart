import 'dart:convert';
import 'dart:typed_data';

import 'package:json_ld_processor/json_ld_processor.dart';

import 'bbs_document_loader.dart';

/// Partición de N-Quads (una statement por línea, como MATTR createVerify*Data).
List<String> splitNQuads(String normalized) {
  return normalized
      .split('\n')
      .map((l) => l.trimRight())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);
}

/// Canonicaliza [document] con URDNA2015 vía [json_ld_processor].
Future<List<String>> canonizeToStatements(
  Map<String, dynamic> document, {
  Map<String, dynamic>? issuerDidDocument,
  Map<String, dynamic>? extraDocuments,
}) async {
  final options = JsonLdOptions(
    documentLoader: (url, opts) => bbsDocumentLoader(
      url,
      opts,
      issuerDidDocument: issuerDidDocument,
      extraDocuments: extraDocuments,
    ),
    safeMode: true,
  );
  final normalized = await JsonLdProcessor.normalize(document, options: options);
  return splitNQuads(normalized);
}

/// Mensajes BBS = utf8(N-Quad) en el orden MATTR (proofStatements ++ documentStatements).
List<Uint8List> statementsToMessages(List<String> statements) {
  return [
    for (final s in statements) Uint8List.fromList(utf8.encode(s)),
  ];
}
