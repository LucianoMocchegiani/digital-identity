import 'dart:convert';

import 'package:json_ld_processor/json_ld_processor.dart';

import '../../crypto/ldp/ldp_contexts.dart';
import '../../crypto/ldp/ldp_document_loader.dart';
import 'bbs_contexts.dart';
import 'bbs_key.dart';
import 'constants.dart';

/// Document loader offline para canonización BBS (LDP contexts + bbs/v1 + DID issuer).
Future<RemoteDocument> bbsDocumentLoader(
  Uri url,
  LoadDocumentOptions? options, {
  Map<String, dynamic>? issuerDidDocument,
  Map<String, dynamic>? extraDocuments,
}) async {
  final key = url.toString();
  final base = key.split('#').first;

  if (key == kBbsSecurityContext || base == kBbsSecurityContext) {
    return RemoteDocument(
      document: jsonDecode(kBbsV1ContextRaw),
      documentUrl: url,
      contentType: 'application/ld+json',
    );
  }

  final embedded = kLdpContextsRaw[key] ?? kLdpContextsRaw[base];
  if (embedded != null) {
    return RemoteDocument(
      document: jsonDecode(embedded),
      documentUrl: url,
      contentType: 'application/ld+json',
    );
  }

  if (extraDocuments != null && extraDocuments.containsKey(key)) {
    return RemoteDocument(
      document: extraDocuments[key],
      documentUrl: url,
      contentType: 'application/ld+json',
    );
  }

  if (issuerDidDocument != null && key.startsWith('did:')) {
    final did = issuerDidDocument['id'] as String?;
    if (did != null && (base == did || key.startsWith(did))) {
      if (key.contains('#')) {
        final vm = findDidVerificationMethod(issuerDidDocument, key);
        if (vm != null) {
          final controller = vm['controller'];
          return RemoteDocument(
            document: {
              ...vm,
              'id': key,
              'controller': (controller is String &&
                      controller.startsWith('did:'))
                  ? controller
                  : issuerDidDocument['id'],
            },
            documentUrl: url,
            contentType: 'application/ld+json',
          );
        }
      }
      return RemoteDocument(
        document: issuerDidDocument,
        documentUrl: url,
        contentType: 'application/ld+json',
      );
    }
  }

  // Fallback al loader LDP (falla explícito si no está).
  return ldpDocumentLoader(url, options);
}
