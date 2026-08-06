import 'package:dio/dio.dart';

import 'models/credential_offer.dart';
import 'models/issuer_metadata.dart';

/// Metadatos del authorization server OAuth2/OIDC.
class OAuthServerMetadata {
  const OAuthServerMetadata({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
  });

  final String issuer;
  final String authorizationEndpoint;
  final String tokenEndpoint;

  factory OAuthServerMetadata.fromJson(Map<String, dynamic> json) {
    final authorizationEndpoint = json['authorization_endpoint'] as String?;
    final tokenEndpoint = json['token_endpoint'] as String?;
    final issuer = json['issuer'] as String? ?? '';

    if (authorizationEndpoint == null || authorizationEndpoint.isEmpty) {
      throw StateError('authorization_endpoint ausente en metadata del AS.');
    }
    if (tokenEndpoint == null || tokenEndpoint.isEmpty) {
      throw StateError('token_endpoint ausente en metadata del AS.');
    }

    return OAuthServerMetadata(
      issuer: issuer,
      authorizationEndpoint: authorizationEndpoint,
      tokenEndpoint: tokenEndpoint,
    );
  }
}

/// Resuelve la URL base del authorization server para un offer OID4VCI.
String resolveAuthorizationServerUrl({
  required CredentialOffer offer,
  required IssuerMetadata issuerMetadata,
}) {
  final fromGrant = offer.grants?.authCode?.authorizationServer;
  if (fromGrant != null && fromGrant.isNotEmpty) return fromGrant;

  final fromMetadata = issuerMetadata.authorizationServers;
  if (fromMetadata != null && fromMetadata.isNotEmpty) {
    return fromMetadata.first;
  }

  return issuerMetadata.credentialIssuer;
}

/// Obtiene metadata OAuth del authorization server.
///
/// Intenta `/.well-known/oauth-authorization-server` y cae a
/// `/.well-known/openid-configuration`.
Future<OAuthServerMetadata> fetchAuthorizationServerMetadata(
  String authorizationServerUrl, {
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  final base = authorizationServerUrl.replaceAll(RegExp(r'/+$'), '');

  for (final path in [
    '/.well-known/oauth-authorization-server',
    '/.well-known/openid-configuration',
  ]) {
    try {
      final response = await client.get<Map<String, dynamic>>('$base$path');
      final data = response.data;
      if (data != null && data['authorization_endpoint'] != null) {
        return OAuthServerMetadata.fromJson(data);
      }
    } on DioException {
      continue;
    }
  }

  throw StateError(
    'No se pudo obtener metadata OAuth del authorization server: $authorizationServerUrl',
  );
}

/// Completa [metadata] con `token_endpoint` del AS si falta en el issuer metadata.
Future<IssuerMetadata> enrichIssuerMetadataWithAuthorizationServer({
  required IssuerMetadata metadata,
  required CredentialOffer offer,
  Dio? dio,
}) async {
  if (metadata.tokenEndpoint != null && metadata.tokenEndpoint!.isNotEmpty) {
    return metadata;
  }

  final asUrl = resolveAuthorizationServerUrl(
    offer: offer,
    issuerMetadata: metadata,
  );
  final asMeta = await fetchAuthorizationServerMetadata(asUrl, dio: dio);

  return metadata.copyWith(tokenEndpoint: asMeta.tokenEndpoint);
}
