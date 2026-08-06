import 'dart:convert';

import 'package:dio/dio.dart';

import '../utils/base64_utils.dart';
import 'models/trust_mechanism.dart';
import 'models/trusted_entity.dart';

/// Valida la confianza en un verifier EUDI mediante OpenID Federation.
///
/// Implementación MVP: descarga el Entity Statement del verifier y extrae
/// la metadata disponible. La verificación de cadena completa de OpenID
/// Federation (multi-hop hasta el trust anchor) queda pendiente.
abstract final class EudiRpTrust {
  /// Intenta validar [clientId] como EUDI Relying Party.
  ///
  /// [trustAnchorUrl]: URL del trust anchor de la federación EUDI.
  /// [clientMetadata]: `client_metadata` inline del request (fallback si el
  ///   entity statement no está disponible).
  static Future<TrustedEntity> validate({
    required String clientId,
    required String trustAnchorUrl,
    Map<String, dynamic>? clientMetadata,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();

    try {
      final entityStatement = await _fetchEntityStatement(clientId, client);
      if (entityStatement != null) {
        return _fromEntityStatement(clientId, entityStatement);
      }
    } catch (_) {
      // fallback a client_metadata inline
    }

    return _fromClientMetadata(clientId, clientMetadata);
  }

  // — helpers —

  static Future<Map<String, dynamic>?> _fetchEntityStatement(
    String clientId,
    Dio client,
  ) async {
    final url = '${clientId.trimRight()}/.well-known/openid-federation';
    final response = await client.get<String>(
      url,
      options: Options(
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/entity-statement+jwt, application/jwt'},
      ),
    );

    final jwt = response.data;
    if (jwt == null || !jwt.startsWith('ey')) return null;

    // Decodificar payload del JWT (sin verificar firma — MVP)
    final parts = jwt.split('.');
    if (parts.length < 2) return null;

    final payloadJson = utf8.decode(base64UrlDecode(parts[1]));
    return jsonDecode(payloadJson) as Map<String, dynamic>?;
  }

  static TrustedEntity _fromEntityStatement(
    String clientId,
    Map<String, dynamic> payload,
  ) {
    final rpMetaRaw = _extractPath(payload, ['metadata', 'openid_relying_party']);
    final rpMap = rpMetaRaw is Map<String, dynamic> ? rpMetaRaw : null;
    final orgName = (_extractPath(payload, ['metadata', 'federation_entity', 'organization_name']) as String?) ??
        rpMap?['organization_name'] as String?;
    final logoUri = (_extractPath(payload, ['metadata', 'federation_entity', 'logo_uri']) as String?) ??
        rpMap?['logo_uri'] as String?;
    final uri = _extractPath(payload, ['metadata', 'federation_entity', 'homepage_uri']) as String?;

    return TrustedEntity(
      trustMechanism: TrustMechanismType.eudiRpAuthentication,
      isVerified: true,
      relyingParty: RelyingParty(
        entityId: clientId,
        organizationName: orgName,
        logoUri: logoUri,
        uri: uri,
      ),
    );
  }

  static TrustedEntity _fromClientMetadata(
    String clientId,
    Map<String, dynamic>? meta,
  ) {
    return TrustedEntity(
      trustMechanism: TrustMechanismType.eudiRpAuthentication,
      isVerified: false,
      relyingParty: RelyingParty(
        entityId: clientId,
        organizationName: meta?['client_name'] as String?,
        logoUri: meta?['logo_uri'] as String?,
      ),
    );
  }

  static Object? _extractPath(Map<String, dynamic> map, List<String> path) {
    Object? current = map;
    for (final key in path) {
      if (current is! Map<String, dynamic>) return null;
      current = current[key];
    }
    return current;
  }
}
