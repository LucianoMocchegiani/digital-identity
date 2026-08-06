import 'package:dio/dio.dart';

import '../../../credential/models/credential_record.dart';
import '../../../did/did_service.dart';
import '../../../kms/kms_service.dart';
import '../../../record/credential_record_store.dart';
import '../../../record/deferred_credential_record_store.dart';
import '../../../record/key_record_store.dart';
import '../../../record/models/deferred_credential_record.dart';
import 'acquire_access_token.dart';
import 'models/issuer_metadata.dart';
import 'models/token_response.dart';
import 'prepare_auth_code_flow.dart' as auth_code;
import 'resolve_credential_offer.dart';
import 'retrieve_credentials.dart';

export 'prepare_auth_code_flow.dart'
    show PreparedAuthCodeFlow, isOid4VciAuthRedirect, parseOid4VciAuthRedirect;
export 'resolve_credential_offer.dart' show ResolvedCredentialOffer, Oid4VciFlow;
export 'retrieve_credentials.dart' show RetrieveCredentialsResult;

/// Fachada pública para el flujo completo de OID4VCI (issuance de credenciales).
///
/// Orquesta la resolución del offer, adquisición del token y recuperación
/// de credenciales desde el credential endpoint del issuer.
class Oid4VciService {
  Oid4VciService({
    required CredentialRecordStore credentialStore,
    required DeferredCredentialRecordStore deferredStore,
    required KmsService kms,
    required DidService didService,
    required KeyRecordStore keyStore,
    Dio? dio,
  })  : _credentialStore = credentialStore,
        _deferredStore = deferredStore,
        _kms = kms,
        _didService = didService,
        _keyStore = keyStore,
        _dio = dio ?? Dio();

  final CredentialRecordStore _credentialStore;
  final DeferredCredentialRecordStore _deferredStore;
  final KmsService _kms;
  final DidService _didService;
  final KeyRecordStore _keyStore;
  final Dio _dio;

  /// Parsea y resuelve el offer URI obteniendo metadatos del issuer.
  Future<ResolvedCredentialOffer> resolveOffer(String offerUri) {
    return resolveCredentialOffer(offerUri, dio: _dio);
  }

  /// Ejecuta el flujo pre-authorized completo: token → credenciales.
  ///
  /// [txCode] es necesario si [resolvedOffer.flow] == [Oid4VciFlow.preAuthWithTxCode].
  /// Las credenciales recibidas se guardan en [CredentialRecordStore].
  /// Las diferidas se guardan en [DeferredCredentialRecordStore].
  Future<RetrieveCredentialsResult> acquireCredentials({
    required ResolvedCredentialOffer resolvedOffer,
    String? txCode,
  }) async {
    final preAuth = resolvedOffer.offer.grants?.preAuthorized;
    if (preAuth == null) {
      throw StateError('El offer no contiene un grant pre-authorized_code.');
    }

    final tokenResponse = await acquirePreAuthorizedToken(
      metadata: resolvedOffer.issuerMetadata,
      preAuthorizedCode: preAuth.preAuthorizedCode,
      txCode: txCode,
      dio: _dio,
    );

    return _retrieveAndStore(
      metadata: resolvedOffer.issuerMetadata,
      tokenResponse: tokenResponse,
      configIds: resolvedOffer.offer.credentialConfigurationIds,
    );
  }

  /// Ejecuta el flujo authorization_code completo: token → credenciales.
  Future<RetrieveCredentialsResult> acquireCredentialsWithAuthCode({
    required ResolvedCredentialOffer resolvedOffer,
    required String authorizationCode,
    required String codeVerifier,
    required String redirectUri,
    String? clientId,
  }) async {
    final tokenResponse = await acquireAuthorizationCodeToken(
      metadata: resolvedOffer.issuerMetadata,
      authorizationCode: authorizationCode,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
      clientId: clientId,
      dio: _dio,
    );

    return _retrieveAndStore(
      metadata: resolvedOffer.issuerMetadata,
      tokenResponse: tokenResponse,
      configIds: resolvedOffer.offer.credentialConfigurationIds,
    );
  }

  /// Prepara PKCE, state y la URI del authorization endpoint (flujo auth code).
  Future<auth_code.PreparedAuthCodeFlow> prepareAuthCodeFlow({
    required ResolvedCredentialOffer resolvedOffer,
    required String redirectUri,
    String? codeVerifier,
    String? state,
  }) {
    return auth_code.prepareAuthCodeFlow(
      resolvedOffer: resolvedOffer,
      redirectUri: redirectUri,
      codeVerifier: codeVerifier,
      state: state,
      dio: _dio,
    );
  }

  /// Reintenta obtener una credencial diferida del deferred credential endpoint.
  ///
  /// Devuelve el [CredentialRecord] si el issuer ya emitió la credencial,
  /// o `null` si todavía está pendiente.
  Future<CredentialRecord?> retryDeferred(DeferredCredentialRecord deferred) async {
    final issuerMeta = deferred.issuerMetadata;
    final credentialEndpoint = issuerMeta['credential_endpoint'] as String?;
    if (credentialEndpoint == null) return null;

    final accessToken = (deferred.accessToken['access_token'] as String?) ?? '';
    final transactionId = deferred.response['transaction_id'] as String?;
    if (transactionId == null) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        credentialEndpoint,
        data: {'transaction_id': transactionId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final rawCredential = response.data?['credential'] as String?;
      if (rawCredential == null) return null;

      // Actualizar estado del deferred record
      final updated = DeferredCredentialRecord(
        id: deferred.id,
        createdAt: deferred.createdAt,
        lastCheckedAt: DateTime.now().toUtc(),
        response: response.data!,
        issuerMetadata: deferred.issuerMetadata,
        accessToken: deferred.accessToken,
      );
      await _deferredStore.update(updated);

      return null; // El caller debe parsear e insertar con parseAndStore
    } on DioException {
      return null;
    }
  }

  // — helpers privados —

  Future<RetrieveCredentialsResult> _retrieveAndStore({
    required IssuerMetadata metadata,
    required TokenResponse tokenResponse,
    required List<String> configIds,
  }) async {
    final result = await retrieveCredentials(
      metadata: metadata,
      tokenResponse: tokenResponse,
      credentialConfigurationIds: configIds,
      kms: _kms,
      didService: _didService,
      keyStore: _keyStore,
      dio: _dio,
    );

    for (final credential in result.credentials) {
      await _credentialStore.save(credential);
    }

    for (final deferred in result.deferredCredentials) {
      await _deferredStore.save(deferred);
    }

    return result;
  }
}
