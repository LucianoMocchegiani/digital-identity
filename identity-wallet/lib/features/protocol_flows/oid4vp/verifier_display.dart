import 'package:identity_core_dart/identity_core.dart';

/// Nombre + dominio legibles del verificador para la UI (sin strings técnicos).
class VerifierDisplay {
  const VerifierDisplay({required this.name, this.domain});

  /// Nombre a mostrar; nunca vacío (cae a etiqueta genérica).
  final String name;

  /// Dominio legible como texto secundario; `null` si no aporta o duplicaría el nombre.
  final String? domain;
}

/// Etiqueta cuando no se puede identificar al verificador.
const _unknownVerifier = 'Verificador no identificado';

/// Prefijos de esquema de `client_id` de OpenID4VP que no debe ver el usuario.
const _schemePrefixes = [
  'decentralized_identifier:',
  'x509_hash:',
  'x509_san_dns:',
  'verifier_attestation:',
  'redirect_uri:',
  'pre-registered:',
  'web-origin:',
];

/// Deriva nombre + dominio legibles a partir del `clientId` crudo del request
/// OID4VP y de la metadata de confianza [rp].
///
/// Prioriza `organizationName`; si no hay, usa el dominio derivado (did:web,
/// URL https o SAN DNS del certificado); si nada es legible, cae a
/// [_unknownVerifier]. Nunca expone el prefijo de esquema ni un hash opaco.
VerifierDisplay verifierDisplay(String clientId, RelyingParty? rp) {
  final derived = _domainFromClientId(clientId) ?? _emptyToNull(rp?.domain);
  final org = _emptyToNull(rp?.organizationName);

  if (org != null) {
    return VerifierDisplay(name: org, domain: derived);
  }
  if (derived != null) {
    // El nombre ES el dominio: sin secundario para no duplicar.
    return VerifierDisplay(name: derived, domain: null);
  }
  return const VerifierDisplay(name: _unknownVerifier, domain: null);
}

/// Devuelve `null` si [value] es nulo o vacío (tras `trim`).
String? _emptyToNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Extrae un dominio legible del `client_id`, o `null` si es opaco.
String? _domainFromClientId(String clientId) {
  var id = clientId.trim();
  for (final prefix in _schemePrefixes) {
    if (id.startsWith(prefix)) {
      id = id.substring(prefix.length);
      break;
    }
  }

  if (id.startsWith('did:web:')) {
    final rest = id.substring('did:web:'.length);
    // El primer segmento (hasta el siguiente `:`) es el host; `%3A` = puerto.
    final host = rest.split(':').first;
    final decoded = host.replaceAll('%3A', ':');
    return decoded.isEmpty ? null : decoded;
  }

  if (id.startsWith('http://') || id.startsWith('https://')) {
    final host = Uri.tryParse(id)?.host;
    return (host != null && host.isNotEmpty) ? host : null;
  }

  // did:key, did:jwk, hashes opacos, etc.: sin dominio legible.
  return null;
}
