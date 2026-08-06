import 'dart:convert';

import 'package:json_ld_processor/json_ld_processor.dart';

import '../../credential/bbs/bbs_contexts.dart';
import '../../credential/bbs/constants.dart';
import 'ldp_contexts.dart';

/// Document loader offline para canonicalización URDNA2015.
///
/// Sirve los contextos JSON-LD bundled (Credo-TS LDP + `security/bbs/v1`),
/// garantizando que la firma del wallet y la verificación del verifier
/// canonicalicen de forma idéntica y sin depender de la red.
///
/// Incluye BBS porque la VP Ed25519 embebe VCs `BbsBlsSignature*` cuyo
/// `@context` referencia `https://w3id.org/security/bbs/v1`.
///
/// Lanza [JsonLdError] ante URLs desconocidas: fallar temprano es preferible
/// a firmar un documento cuya expansión diferiría de la del verificador.
Future<RemoteDocument> ldpDocumentLoader(
  Uri url,
  LoadDocumentOptions? options,
) async {
  final key = url.toString();
  final base = key.split('#').first;

  if (key == kBbsSecurityContext || base == kBbsSecurityContext) {
    return RemoteDocument(
      document: jsonDecode(kBbsV1ContextRaw),
      documentUrl: url,
      contentType: 'application/ld+json',
    );
  }

  final raw = kLdpContextsRaw[key] ?? kLdpContextsRaw[base];
  if (raw == null) {
    throw JsonLdError('Contexto JSON-LD no soportado offline: $url');
  }
  return RemoteDocument(
    document: jsonDecode(raw),
    documentUrl: url,
    contentType: 'application/ld+json',
  );
}
