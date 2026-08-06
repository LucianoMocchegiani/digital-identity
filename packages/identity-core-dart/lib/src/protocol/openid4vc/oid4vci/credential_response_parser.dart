/// Extrae credenciales emitidas del body JSON del credential endpoint OID4VCI.
///
/// Soporta respuesta singular (`credential`) y por lote (`credentials`), como en
/// issuer.eudiw.dev.
List<String> extractIssuedCredentials(Map<String, dynamic> json) {
  final results = <String>[];

  final single = json['credential'];
  if (single is String && single.isNotEmpty) {
    results.add(single);
  }

  final batch = json['credentials'];
  if (batch is List) {
    for (final item in batch) {
      if (item is String && item.isNotEmpty) {
        results.add(item);
        continue;
      }
      if (item is Map) {
        final nested = item['credential'];
        if (nested is String && nested.isNotEmpty) {
          results.add(nested);
        }
      }
    }
  }

  return results;
}
