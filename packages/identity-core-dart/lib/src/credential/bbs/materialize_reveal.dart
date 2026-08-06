/// Materializa el documento revelado a partir de un frame Quark (MVP sin jsonld.frame).
///
/// Para VCs sin blank nodes en el grafo del subject (caso Quark `@vocab` + IRI subject),
/// eliminar claims no pedidos y re-canonizar produce los mismos N-Quads que MATTR frame
/// (verificado con `tool/bbs_derive_debug.mjs`). Credenciales con blank nodes anidados
/// requieren port completo de frame/fromRDF — fuera de este MVP.
library;

/// Aplica [revealDocument] (frame con `@explicit`) sobre [credential] (sin proof).
///
/// Solo soporta `credentialSubject` plano: keys presentes en el frame se copian;
/// el resto se omite. Metadatos de la VC (`@context`, `type`, `issuer`, etc.) se
/// preservan del credential original.
Map<String, dynamic> materializeRevealDocument({
  required Map<String, dynamic> credential,
  required Map<String, dynamic> revealDocument,
}) {
  final out = Map<String, dynamic>.from(credential)..remove('proof');

  final frameSubject = revealDocument['credentialSubject'];
  final credSubject = credential['credentialSubject'];
  if (frameSubject is Map && credSubject is Map) {
    final revealed = <String, dynamic>{};
    for (final entry in frameSubject.entries) {
      final key = entry.key;
      if (key == '@explicit') continue;
      if (credSubject.containsKey(key)) {
        revealed[key] = credSubject[key];
      }
    }
    out['credentialSubject'] = revealed;
  }

  // Si el frame fija type/@context, preferir el del credential firmado.
  return out;
}
