import 'invitation_normalizer.dart';
import 'models/invitation_type.dart';

/// Detecta el tipo de invitación a partir de una URL sin realizar ninguna
/// operación de red ni de parseo de payload.
///
/// Soporta QR codes, deep links y URLs copiadas desde el portapapeles.
abstract final class InvitationParser {
  /// Detecta el [InvitationType] de [url] inspeccionando el esquema y los
  /// query parameters.
  ///
  /// Retorna `null` si el formato no es reconocido.
  static InvitationType? detectType(String url) {
    final normalized = normalizeInvitationUrl(url);
    if (normalized.isEmpty) return null;

    if (isInlineCredentialOfferJson(normalized)) {
      return InvitationType.openid4vciOffer;
    }

    // — Esquemas exclusivos —
    if (_isOid4VciScheme(normalized)) return InvitationType.openid4vciOffer;
    if (_isOid4VpScheme(normalized)) return InvitationType.openid4vpRequest;
    if (_isDidCommScheme(normalized)) return InvitationType.didcommInvitation;

    // — HTTPS / HTTP: inspeccionar query params o endpoint de offer directo —
    if (_isHttpUrl(normalized)) {
      return _detectFromHttpsUrl(normalized);
    }

    return null;
  }

  /// URL lista para [InvitationResolver.resolve] (normaliza esquemas y JSON inline).
  static String canonicalizeForResolve(String url) {
    final normalized = normalizeInvitationUrl(url);
    if (isInlineCredentialOfferJson(normalized)) {
      return wrapInlineCredentialOfferJson(normalized);
    }
    return normalized;
  }

  static bool _isHttpUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('https://') || lower.startsWith('http://');
  }

  // — Comprobaciones por esquema —

  static bool _isOid4VciScheme(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('openid-credential-offer:') ||
        lower.startsWith('openid-initiate-issuance:') ||
        lower.startsWith('haip-vci:');
  }

  static bool _isOid4VpScheme(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('openid4vp:') ||
        lower.startsWith('eudi-openid4vp:') ||
        lower.startsWith('mdoc-openid4vp:') ||
        lower.startsWith('haip:');
  }

  static bool _isDidCommScheme(String url) {
    return url.toLowerCase().startsWith('didcomm:');
  }

  // — Detección por query params (solo para HTTPS) —

  static InvitationType? _detectFromHttpsUrl(String url) {
    final fromParams = _detectFromQueryParams(url);
    if (fromParams != null) return fromParams;

    // Algunos issuers (p. ej. EUDI) muestran solo la URL del offer, sin wrapper
    // openid-credential-offer://.
    if (_looksLikeCredentialOfferEndpoint(url)) {
      return InvitationType.openid4vciOffer;
    }

    return null;
  }

  static bool _looksLikeCredentialOfferEndpoint(String url) {
    final lower = url.toLowerCase();
    return lower.contains('credential-offer') ||
        lower.contains('credential_offer');
  }

  static InvitationType? _detectFromQueryParams(String url) {
    final Uri parsed;
    try {
      parsed = Uri.parse(url);
    } on FormatException {
      return null;
    }

    final params = parsed.queryParameters;

    if (params.containsKey('credential_offer') ||
        params.containsKey('credential_offer_uri')) {
      return InvitationType.openid4vciOffer;
    }

    if (params.containsKey('request_uri') ||
        params.containsKey('request') ||
        params.containsKey('presentation_definition')) {
      return InvitationType.openid4vpRequest;
    }

    if (params.containsKey('oob') ||
        params.containsKey('c_i') ||
        params.containsKey('_oobid')) {
      return InvitationType.didcommInvitation;
    }

    // Short URL RFC 0434 / Quark: `https://host/oob/{id}` (sin `oob=` embebido).
    if (_isDidCommShortPath(parsed)) {
      return InvitationType.didcommInvitation;
    }

    return null;
  }

  /// Detecta paths cortos de invitación OOB (`/oob/:id`).
  static bool _isDidCommShortPath(Uri parsed) {
    final segments =
        parsed.pathSegments.where((s) => s.isNotEmpty).toList(growable: false);
    if (segments.length < 2) return false;
    return segments[segments.length - 2].toLowerCase() == 'oob';
  }
}
