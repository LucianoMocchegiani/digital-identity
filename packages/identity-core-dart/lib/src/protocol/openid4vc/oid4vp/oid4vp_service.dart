import 'package:dio/dio.dart';

import '../../../credential/models/credential_record.dart';
import '../../../did/did_resolver.dart';
import '../../../did/did_service.dart';
import '../../../kms/kms_service.dart';
import '../../../record/activity_record_store.dart';
import '../../../record/credential_record_store.dart';
import '../../../record/key_record_store.dart';
import '../../../record/models/activity.dart' show
    ActivityEntity, ActivityStatus, PresentationActivity, PresentationRequest;
import '../../../trust/trust_config.dart';
import 'build_presentation.dart';
import 'models/credentials_for_request.dart';
import 'resolve_presentation_request.dart';
import 'submit_presentation.dart';

export 'build_presentation.dart' show PresentationBundle;
export 'models/authorization_request.dart';
export 'models/credentials_for_request.dart';
export 'submit_presentation.dart' show SubmitPresentationResult;

/// Fachada pública para el flujo completo de OID4VP (presentación de credenciales).
///
/// Orquesta la resolución del request, el matching de credenciales, la construcción
/// de la VP Token con selective disclosure y el envío al verifier.
class Oid4VpService {
  Oid4VpService({
    required CredentialRecordStore credentialStore,
    required ActivityRecordStore activityStore,
    required KmsService kms,
    required DidService didService,
    required KeyRecordStore keyStore,
    UniversalDidResolver? didResolver,
    TrustConfig? trustConfig,
    Dio? dio,
  })  : _credentialStore = credentialStore,
        _activityStore = activityStore,
        _kms = kms,
        _didService = didService,
        _keyStore = keyStore,
        _didResolver = didResolver,
        _trustConfig = trustConfig,
        _dio = dio ?? Dio();

  final CredentialRecordStore _credentialStore;
  final ActivityRecordStore _activityStore;
  final KmsService _kms;
  final DidService _didService;
  final KeyRecordStore _keyStore;
  final UniversalDidResolver? _didResolver;
  final TrustConfig? _trustConfig;
  final Dio _dio;

  /// Resuelve el [uri] de presentation request y retorna las credenciales disponibles.
  ///
  /// El resultado incluye la [FormattedSubmission] para mostrar en UI y
  /// toda la información necesaria para ejecutar la presentación.
  Future<CredentialsForRequest> resolveRequest(String uri) async {
    final all = await _credentialStore.getAll();
    return resolvePresentationRequest(
      uri: uri,
      credentials: all,
      didResolver: _didResolver,
      trustConfig: _trustConfig,
      dio: _dio,
    );
  }

  /// Ejecuta la presentación de credenciales al verifier.
  ///
  /// [selectedCredentials]: `{inputDescriptorId: credentialId}` — qué credencial
  /// usar para cada descriptor.
  ///
  /// [selectedDisclosures]: `{inputDescriptorId: [claimPath, ...]}` — qué claims
  /// revelar. Si está vacío para un descriptor, se revelan todos los claims.
  ///
  /// Guarda una [PresentationActivity] en el [ActivityRecordStore] al completar.
  Future<SubmitPresentationResult> shareCredentials({
    required CredentialsForRequest resolvedRequest,
    required Map<String, String> selectedCredentials,
    required Map<String, List<String>> selectedDisclosures,
  }) async {
    if (!resolvedRequest.submission.areAllSatisfied) {
      throw StateError(
        'No se puede compartir: no todas las credenciales requeridas están disponibles.',
      );
    }

    final credentialRecords = await _resolveCredentialRecords(selectedCredentials);
    final bundle = await buildPresentation(
      resolvedRequest: resolvedRequest,
      selectedDisclosuresByDescriptor: selectedDisclosures,
      selectedCredentialsByDescriptor: credentialRecords,
      kms: _kms,
      keyStore: _keyStore,
      didService: _didService,
    );

    if (resolvedRequest.responseUri == null) {
      throw StateError('El authorization request no tiene response_uri.');
    }

    final result = await submitPresentation(
      responseUri: resolvedRequest.responseUri!,
      vpToken: bundle.vpToken,
      presentationSubmission: bundle.presentationSubmission,
      state: resolvedRequest.state,
      responseMode: resolvedRequest.responseMode,
      clientMetadata: resolvedRequest.clientMetadata,
      nonce: resolvedRequest.nonce,
      encAlg: resolvedRequest.authorizationEncryptedResponseEnc ?? 'A128GCM',
      dio: _dio,
    );

    if (result.success) {
      await _recordPresentationActivity(resolvedRequest, credentialRecords);
    }

    return result;
  }

  // — helpers privados —

  Future<Map<String, CredentialRecord>> _resolveCredentialRecords(
    Map<String, String> selectedCredentialIds,
  ) async {
    final result = <String, CredentialRecord>{};
    for (final entry in selectedCredentialIds.entries) {
      final credential = await _credentialStore.getById(entry.value);
      if (credential == null) {
        throw StateError(
          'Credencial no encontrada: ${entry.value} (descriptor=${entry.key})',
        );
      }
      result[entry.key] = credential;
    }
    return result;
  }

  Future<void> _recordPresentationActivity(
    CredentialsForRequest request,
    Map<String, CredentialRecord> credentials,
  ) async {
    final credentialIds = credentials.values.map((c) => c.id).toList();
    final verifier = request.verifierClientId;

    await _activityStore.save(
      PresentationActivity(
        id: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
        date: DateTime.now().toUtc(),
        entity: ActivityEntity(id: verifier),
        request: PresentationRequest(
          status: ActivityStatus.success,
          credentialIds: credentialIds,
        ),
      ),
    );
  }
}
