import 'dart:convert';

import 'package:dio/dio.dart';

import 'models/credential_offer.dart';
import 'oauth_server_metadata.dart';
import 'pkce.dart';
import 'resolve_credential_offer.dart';

/// Parámetros listos para abrir el browser en un flujo authorization_code.
class PreparedAuthCodeFlow {
  const PreparedAuthCodeFlow({
    required this.authorizationUri,
    required this.codeVerifier,
    required this.state,
    required this.redirectUri,
    required this.resolvedOffer,
  });

  /// URL del authorization endpoint con query OAuth + authorization_details.
  final Uri authorizationUri;

  final String codeVerifier;
  final String state;
  final String redirectUri;

  /// Offer con issuer metadata enriquecida (token_endpoint del AS).
  final ResolvedCredentialOffer resolvedOffer;
}

/// Prepara el flujo authorization_code: PKCE, state y URI de autorización.
Future<PreparedAuthCodeFlow> prepareAuthCodeFlow({
  required ResolvedCredentialOffer resolvedOffer,
  required String redirectUri,
  String? codeVerifier,
  String? state,
  Dio? dio,
}) async {
  if (resolvedOffer.flow != Oid4VciFlow.authCode) {
    throw StateError(
      'prepareAuthCodeFlow requiere Oid4VciFlow.authCode; flujo actual: ${resolvedOffer.flow}',
    );
  }

  final verifier = codeVerifier ?? generateOid4VciCodeVerifier();
  final oauthState = state ?? generateOid4VciState();
  final challenge = computeOid4VciCodeChallenge(verifier);

  final enrichedMetadata = await enrichIssuerMetadataWithAuthorizationServer(
    metadata: resolvedOffer.issuerMetadata,
    offer: resolvedOffer.offer,
    dio: dio,
  );

  final offer = resolvedOffer.copyWith(issuerMetadata: enrichedMetadata);

  final asUrl = resolveAuthorizationServerUrl(
    offer: offer.offer,
    issuerMetadata: offer.issuerMetadata,
  );
  final asMeta = await fetchAuthorizationServerMetadata(asUrl, dio: dio);

  final authorizationDetails = _buildAuthorizationDetails(offer.offer);
  final scope = _buildScope(offer.offer);

  final query = <String, String>{
    'response_type': 'code',
    'redirect_uri': redirectUri,
    'state': oauthState,
    'code_challenge': challenge,
    'code_challenge_method': 'S256',
    if (scope.isNotEmpty) 'scope': scope,
    'authorization_details': jsonEncode(authorizationDetails),
  };

  final authorizationUri = Uri.parse(asMeta.authorizationEndpoint).replace(
    queryParameters: query,
  );

  return PreparedAuthCodeFlow(
    authorizationUri: authorizationUri,
    codeVerifier: verifier,
    state: oauthState,
    redirectUri: redirectUri,
    resolvedOffer: offer,
  );
}

List<Map<String, dynamic>> _buildAuthorizationDetails(CredentialOffer offer) {
  final issuerState = offer.grants?.authCode?.issuerState;
  return [
    for (final configId in offer.credentialConfigurationIds)
      {
        'type': 'openid_credential',
        'credential_configuration_id': configId,
        if (issuerState != null) 'issuer_state': issuerState,
      },
  ];
}

String _buildScope(CredentialOffer offer) {
  final scopes = <String>{'openid'};
  for (final configId in offer.credentialConfigurationIds) {
    scopes.add(configId);
  }
  return scopes.join(' ');
}

/// Indica si [callbackUri] corresponde al [redirectUri] esperado del flujo.
bool isOid4VciAuthRedirect({
  required String callbackUri,
  required String redirectUri,
}) {
  final callback = Uri.parse(callbackUri);
  final expected = Uri.parse(redirectUri);
  return callback.scheme == expected.scheme &&
      callback.host == expected.host &&
      callback.path == expected.path;
}

/// Extrae `code` y `state` de la URI de callback OAuth.
({String? code, String? state, String? error, String? errorDescription})
    parseOid4VciAuthRedirect(String callbackUri) {
  final uri = Uri.parse(callbackUri);
  return (
    code: uri.queryParameters['code'],
    state: uri.queryParameters['state'],
    error: uri.queryParameters['error'],
    errorDescription: uri.queryParameters['error_description'],
  );
}
