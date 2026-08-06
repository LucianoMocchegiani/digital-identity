import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../credential/models/credential_record.dart';
import '../../../did/did_resolver.dart';
import '../../../trust/did_trust.dart';
import '../../../trust/eudi_rp_trust.dart';
import '../../../trust/models/trust_mechanism.dart';
import '../../../trust/models/trusted_entity.dart';
import '../../../trust/trust_config.dart';
import '../../../trust/trust_detector.dart';
import '../../../trust/x509_trust.dart';
import '../../../utils/base64_utils.dart';
import 'match_credentials.dart';
import 'models/authorization_request.dart';
import 'models/credentials_for_request.dart';
import 'models/dcql_query.dart';
import 'models/presentation_definition.dart';

/// Resuelve un URI de presentation request y hace matching con las credenciales locales.
///
/// Esquemas soportados: `openid4vp://`, `eudi-openid4vp://`, `mdoc-openid4vp://`, `haip://`.
///
/// Pasos:
/// 1. Parsear el URI y obtener el JWT del request (inline o via fetch).
/// 2. Decodificar el payload del JWT → [AuthorizationRequest].
/// 3. Determinar query type: PEX o DCQL.
/// 4. Hacer matching de credenciales locales.
/// 5. Retornar [CredentialsForRequest] con [FormattedSubmission].
Future<CredentialsForRequest> resolvePresentationRequest({
  required String uri,
  required List<CredentialRecord> credentials,
  UniversalDidResolver? didResolver,
  TrustConfig? trustConfig,
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  final (request, jwtHeader) = await _fetchAuthorizationRequest(uri, client);

  final queryType = _detectQueryType(request);
  final submission = await _matchCredentials(request, queryType, credentials);

  TrustedEntity? trustedEntity;
  if (jwtHeader != null) {
    trustedEntity = await _resolveTrust(
      header: jwtHeader,
      payload: {
        'client_id': request.clientId,
        if (request.clientMetadata != null) 'client_metadata': request.clientMetadata,
      },
      clientId: request.clientId,
      clientMetadata: request.clientMetadata,
      trustConfig: trustConfig,
      didResolver: didResolver,
      dio: client,
    );
  }

  return CredentialsForRequest(
    queryType: queryType,
    submission: submission,
    verifierClientId: request.clientId,
    nonce: request.nonce,
    responseUri: request.responseUri,
    state: request.state,
    presentationDefinitionId: request.presentationDefinition?['id'] as String?,
    trustedEntity: trustedEntity,
    responseMode: request.responseMode,
    clientMetadata: request.clientMetadata,
    authorizationEncryptedResponseEnc: request.authorizationEncryptedResponseEnc,
  );
}

Future<(AuthorizationRequest, Map<String, dynamic>?)> _fetchAuthorizationRequest(
  String uri,
  Dio client,
) async {
  // Normalizar el esquema para parsear como URI estándar
  final normalized = uri
      .replaceFirst('openid4vp://', 'https://openid4vp/')
      .replaceFirst('eudi-openid4vp://', 'https://openid4vp/')
      .replaceFirst('mdoc-openid4vp://', 'https://openid4vp/')
      .replaceFirst('haip://', 'https://openid4vp/');

  final parsed = Uri.parse(normalized);
  final params = parsed.queryParameters;

  if (params.containsKey('request_uri')) {
    final response = await client.get<String>(params['request_uri']!);
    return _decodeRequestJwt(response.data!);
  }

  if (params.containsKey('request')) {
    return _decodeRequestJwt(params['request']!);
  }

  // Fallback: parámetros directos en el URI (sin JWT — sin header disponible)
  final request = AuthorizationRequest.fromJson(params.map((k, v) => MapEntry(k, v)));
  return (request, null);
}

/// Decodifica el payload de un Request JWT y retorna también el header.
///
/// La verificación de firma queda pendiente hasta que se integre la trust chain completa.
(AuthorizationRequest, Map<String, dynamic>) _decodeRequestJwt(String jwt) {
  final parts = jwt.split('.');
  if (parts.length < 2) throw FormatException('Request JWT inválido: $jwt');

  final headerJson = utf8.decode(base64UrlDecode(parts[0]));
  final header = jsonDecode(headerJson) as Map<String, dynamic>;

  final payloadJson = utf8.decode(base64UrlDecode(parts[1]));
  final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

  _normalizeNestedJson(payload, 'presentation_definition');
  _normalizeNestedJson(payload, 'dcql_query');

  return (AuthorizationRequest.fromJson(payload), header);
}

void _normalizeNestedJson(Map<String, dynamic> payload, String key) {
  if (payload[key] is String) {
    payload[key] = jsonDecode(payload[key] as String);
  }
}

QueryType _detectQueryType(AuthorizationRequest request) {
  if (request.dcqlQuery != null) return QueryType.dcql;
  return QueryType.pex;
}

Future<TrustedEntity?> _resolveTrust({
  required Map<String, dynamic> header,
  required Map<String, dynamic> payload,
  required String clientId,
  Map<String, dynamic>? clientMetadata,
  TrustConfig? trustConfig,
  UniversalDidResolver? didResolver,
  Dio? dio,
}) async {
  try {
    final mechanism = TrustDetector.detect(
      requestHeader: header,
      requestPayload: payload,
    );

    switch (mechanism) {
      case TrustMechanismType.x509:
        final x5c = (header['x5c'] as List?)?.cast<String>();
        if (x5c == null || x5c.isEmpty) return null;
        return X509Trust.validate(
          x5cChain: x5c,
          clientId: clientId,
          trustedRootCertificates: trustConfig?.trustedRootCertificates ?? [],
        );

      case TrustMechanismType.did:
        final resolver = didResolver ?? UniversalDidResolver();
        return DidTrust(resolver).validate(
          clientId: clientId,
          requestSignatureKid: header['kid'] as String?,
          clientMetadata: clientMetadata,
        );

      case TrustMechanismType.eudiRpAuthentication:
        final anchor = trustConfig?.eudiTrustAnchorUrl ?? '';
        if (anchor.isEmpty) return null;
        return EudiRpTrust.validate(
          clientId: clientId,
          trustAnchorUrl: anchor,
          clientMetadata: clientMetadata,
          dio: dio,
        );
    }
  } catch (_) {
    return null;
  }
}

Future<FormattedSubmission> _matchCredentials(
  AuthorizationRequest request,
  QueryType queryType,
  List<CredentialRecord> credentials,
) async {
  if (queryType == QueryType.dcql && request.dcqlQuery != null) {
    final query = DcqlQuery.fromJson(request.dcqlQuery!);
    return matchDcql(query: query, credentials: credentials);
  }

  if (request.presentationDefinition != null) {
    final definition = PresentationDefinition.fromJson(request.presentationDefinition!);
    return matchPex(definition: definition, credentials: credentials);
  }

  // Sin query ni definition — submission vacía
  return const FormattedSubmission(
    areAllSatisfied: false,
    entries: [],
  );
}
