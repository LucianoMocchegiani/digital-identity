import 'dart:convert';

import '../../../utils/base64_utils.dart';

/// Utilidades para adjuntos de credencial en mensajes DIDComm v2 (RFC 0453).
///
/// Credo usa `offers~attach` en el offer y `requests~attach` en el request;
/// `issue-credential` sigue usando `credentials~attach`.
abstract final class DidCommCredentialAttach {
  /// Lee adjuntos de offer (`offers~attach`) o issue (`credentials~attach`).
  static List<Map<String, dynamic>> listFromMessage(
    Map<String, dynamic> message, {
    bool forOffer = true,
  }) {
    final keys = forOffer
        ? ['offers~attach', 'credentials~attach']
        : ['credentials~attach'];
    for (final key in keys) {
      final raw = message[key];
      if (raw is List && raw.isNotEmpty) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  /// Decodifica el payload JSON de un adjunto DIDComm (`data.json` o `data.base64`).
  static Map<String, dynamic>? jsonFromAttach(Map<String, dynamic>? attach) {
    if (attach == null) return null;

    final data = attach['data'];
    if (data is! Map) return null;

    final json = data['json'];
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);

    final encoded = data['base64'] as String?;
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = utf8.decode(base64UrlDecode(encoded));
      final parsed = jsonDecode(decoded);
      return parsed is Map<String, dynamic>
          ? parsed
          : parsed is Map
              ? Map<String, dynamic>.from(parsed)
              : null;
    } catch (_) {
      try {
        final decoded = utf8.decode(base64.decode(encoded));
        final parsed = jsonDecode(decoded);
        return parsed is Map<String, dynamic>
            ? parsed
            : parsed is Map
                ? Map<String, dynamic>.from(parsed)
                : null;
      } catch (_) {
        return null;
      }
    }
  }

  /// Extrae la credencial W3C desde un adjunto json-ld (`credential` dentro del detail).
  static Map<String, dynamic>? credentialFromAttach(
    Map<String, dynamic>? attach,
  ) {
    final payload = jsonFromAttach(attach);
    if (payload == null) return null;

    final wrapped = payload['verifiableCredential'] ?? payload['vc'];
    if (wrapped is Map<String, dynamic>) return wrapped;
    if (wrapped is Map) return Map<String, dynamic>.from(wrapped);

    final credential = payload['credential'];
    if (credential is Map<String, dynamic>) return credential;
    if (credential is Map) return Map<String, dynamic>.from(credential);

    // Adjunto ya es la VC (p. ej. issue-credential firmado).
    if (payload.containsKey('credentialSubject') ||
        payload.containsKey('@context') ||
        payload.containsKey('type')) {
      return payload;
    }
    return null;
  }

  /// VC del primer adjunto de un mensaje `offer-credential`.
  static Map<String, dynamic>? credentialFromOfferMessage(
    Map<String, dynamic>? offerMessage,
  ) {
    if (offerMessage == null) return null;
    final attaches = listFromMessage(offerMessage, forOffer: true);
    if (attaches.isEmpty) return null;
    return credentialFromAttach(attaches.first);
  }

  /// Atributos de `credential_preview` (RFC 0453) → mapa plano de claims.
  static Map<String, dynamic> attributesFromCredentialPreview(
    Map<String, dynamic>? message,
  ) {
    if (message == null) return const {};
    final preview =
        message['credential_preview'] ?? message['credentialPreview'];
    if (preview is! Map) return const {};

    final attributes = preview['attributes'];
    if (attributes is! List) return const {};

    final result = <String, dynamic>{};
    for (final item in attributes) {
      if (item is! Map) continue;
      final name = item['name']?.toString();
      if (name == null || name.isEmpty || name == 'id') continue;
      result[name] = item['value'];
    }
    return result;
  }

  /// Completa un detail de offer con claims del `credential_preview` si faltan.
  static Map<String, dynamic>? enrichOfferDetailWithPreview({
    Map<String, dynamic>? offerDetail,
    Map<String, dynamic>? offerMessage,
  }) {
    final previewClaims = attributesFromCredentialPreview(offerMessage);
    if (offerDetail == null && previewClaims.isEmpty) return null;
    if (previewClaims.isEmpty) return offerDetail;

    final base = offerDetail ?? <String, dynamic>{};
    final subject = normalizeSubjectMap(base['credentialSubject']);
    return {
      ...base,
      'credentialSubject': {...previewClaims, ...subject},
    };
  }

  /// Copia los adjuntos del offer para armar `requests~attach` (holder acceptOffer).
  static List<Map<String, dynamic>> requestAttachmentsFromOffer(
    Map<String, dynamic> offerMessage,
  ) {
    return listFromMessage(offerMessage, forOffer: true);
  }

  /// Fusiona el subject del offer (sin firmar) con la VC emitida.
  static Map<String, dynamic> mergeIssuedCredentialWithOfferDetail({
    required Map<String, dynamic> issued,
    Map<String, dynamic>? offerDetail,
  }) {
    if (offerDetail == null) return _withNormalizedSubject(issued);

    final issuedSubject = normalizeSubjectMap(issued['credentialSubject']);
    final offerSubject = normalizeSubjectMap(offerDetail['credentialSubject']);
    if (offerSubject.isEmpty) return _withNormalizedSubject(issued);

    final mergedSubject = <String, dynamic>{...offerSubject, ...issuedSubject};
    return _withNormalizedSubject({...issued, 'credentialSubject': mergedSubject});
  }

  /// Normaliza `credentialSubject` (string DID, lista JSON-LD, claves expandidas).
  static Map<String, dynamic> normalizeSubjectMap(dynamic subject) {
    final map = _subjectMap(subject);
    if (map.isEmpty) return const {};

    final normalized = <String, dynamic>{};
    for (final entry in map.entries) {
      if (entry.key == '@type') continue;
      normalized[_compactJsonLdKey(entry.key)] = entry.value;
    }
    return normalized;
  }

  static Map<String, dynamic> _withNormalizedSubject(Map<String, dynamic> vc) {
    final subject = normalizeSubjectMap(vc['credentialSubject']);
    if (subject.isEmpty) return vc;
    return {...vc, 'credentialSubject': subject};
  }

  static Map<String, dynamic> _subjectMap(dynamic subject) {
    if (subject is String && subject.isNotEmpty) {
      return {'id': subject};
    }
    if (subject is List && subject.isNotEmpty) {
      return _subjectMap(subject.first);
    }
    if (subject is Map<String, dynamic>) return Map.from(subject);
    if (subject is Map) return Map<String, dynamic>.from(subject);
    return const {};
  }

  static String _compactJsonLdKey(String key) {
    if (!key.contains(':') && !key.contains('/')) return key;
    if (key.startsWith('http')) {
      final hashIdx = key.lastIndexOf('#');
      if (hashIdx >= 0 && hashIdx < key.length - 1) {
        return key.substring(hashIdx + 1);
      }
      final slashIdx = key.lastIndexOf('/');
      if (slashIdx >= 0 && slashIdx < key.length - 1) {
        final last = key.substring(slashIdx + 1);
        final colonIdx = last.lastIndexOf(':');
        return colonIdx >= 0 ? last.substring(colonIdx + 1) : last;
      }
    }
    final colonIdx = key.lastIndexOf(':');
    if (colonIdx >= 0) return key.substring(colonIdx + 1);
    return key;
  }

  /// `thid` del offer: Credo enlaza el credential exchange por este valor, no por `@id`.
  static String? threadIdFromOfferMessage(Map<String, dynamic> offerMessage) {
    final thread = offerMessage['~thread'] ?? offerMessage['thread'];
    if (thread is Map) {
      final thid = thread['thid'];
      if (thid is String && thid.isNotEmpty) return thid;
    }
    return null;
  }
}
