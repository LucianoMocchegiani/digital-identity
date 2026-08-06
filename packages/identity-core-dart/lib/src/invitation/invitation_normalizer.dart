/// Normaliza el payload crudo de un QR / deep link antes de detectar o resolver.
String normalizeInvitationUrl(String raw) {
  var value = raw.trim();

  // Artefactos frecuentes en QRs copiados o mal codificados.
  while (value.isNotEmpty) {
    final last = value.codeUnitAt(value.length - 1);
    if (last == 0x3E || last == 0x29 || last == 0x5D) {
      // '>', ')', ']'
      value = value.substring(0, value.length - 1).trimRight();
      continue;
    }
    break;
  }

  // Algunos generadores usan una sola barra: openid-credential-offer:?...
  const oid4VciSchemes = [
    'openid-credential-offer:',
    'openid-initiate-issuance:',
    'haip-vci:',
  ];
  for (final scheme in oid4VciSchemes) {
    final lower = value.toLowerCase();
    if (!lower.startsWith(scheme)) continue;
    final rest = value.substring(scheme.length);
    if (rest.startsWith('//')) return value;
    if (rest.startsWith(':/')) {
      return '$scheme/${rest.substring(2)}';
    }
    if (rest.startsWith('/')) {
      return '$scheme$rest';
    }
    if (rest.startsWith('?')) {
      return '$scheme//$rest';
    }
    return '$scheme//$rest';
  }

  return value;
}

/// Indica si [value] es un JSON de credential offer embebido en el QR.
bool isInlineCredentialOfferJson(String value) {
  final trimmed = value.trim();
  return trimmed.startsWith('{') &&
      trimmed.contains('"credential_issuer"') &&
      trimmed.contains('"credential_configuration_ids"');
}

/// Convierte un offer JSON inline al URI canónico OID4VCI.
String wrapInlineCredentialOfferJson(String json) {
  final encoded = Uri.encodeComponent(json.trim());
  return 'openid-credential-offer://?credential_offer=$encoded';
}
