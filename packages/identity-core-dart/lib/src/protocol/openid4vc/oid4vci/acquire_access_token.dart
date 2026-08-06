import 'package:dio/dio.dart';

import 'models/issuer_metadata.dart';
import 'models/token_response.dart';

/// Solicita un access token usando el flujo pre-authorized_code.
///
/// [txCode] es requerido cuando el offer incluye `tx_code` (e.g. PIN de 4 dígitos).
/// Lanza [DioException] si el token endpoint responde con error HTTP.
Future<TokenResponse> acquirePreAuthorizedToken({
  required IssuerMetadata metadata,
  required String preAuthorizedCode,
  String? txCode,
  Dio? dio,
}) async {
  final tokenEndpoint = _resolveTokenEndpoint(metadata);
  final client = dio ?? Dio();

  final response = await client.post<Map<String, dynamic>>(
    tokenEndpoint,
    data: {
      'grant_type': 'urn:ietf:params:oauth:grant-type:pre-authorized_code',
      'pre-authorized_code': preAuthorizedCode,
      if (txCode != null) 'tx_code': txCode,
    },
    options: Options(contentType: Headers.formUrlEncodedContentType),
  );

  return TokenResponse.fromJson(response.data!);
}

/// Solicita un access token usando el flujo authorization_code con PKCE.
///
/// Lanza [DioException] si el token endpoint responde con error HTTP.
Future<TokenResponse> acquireAuthorizationCodeToken({
  required IssuerMetadata metadata,
  required String authorizationCode,
  required String codeVerifier,
  required String redirectUri,
  String? clientId,
  Dio? dio,
}) async {
  final tokenEndpoint = _resolveTokenEndpoint(metadata);
  final client = dio ?? Dio();

  final response = await client.post<Map<String, dynamic>>(
    tokenEndpoint,
    data: {
      'grant_type': 'authorization_code',
      'code': authorizationCode,
      'code_verifier': codeVerifier,
      'redirect_uri': redirectUri,
      if (clientId != null) 'client_id': clientId,
    },
    options: Options(contentType: Headers.formUrlEncodedContentType),
  );

  return TokenResponse.fromJson(response.data!);
}

String _resolveTokenEndpoint(IssuerMetadata metadata) {
  final endpoint = metadata.tokenEndpoint;
  if (endpoint == null || endpoint.isEmpty) {
    throw StateError(
      'tokenEndpoint no disponible en los metadatos del issuer ${metadata.credentialIssuer}. '
      'Verificar el authorization server metadata.',
    );
  }
  return endpoint;
}
