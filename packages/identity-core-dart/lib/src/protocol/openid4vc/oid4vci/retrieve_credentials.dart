import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../credential/models/credential_record.dart';
import '../../../credential/models/sd_jwt_vc_record.dart';
import '../../../credential/models/w3c_credential_record.dart';
import '../../../did/did_service.dart';
import '../../../kms/kms_service.dart';
import '../../../record/key_record_store.dart';
import '../../../record/models/deferred_credential_record.dart';
import '../../../record/models/key_record.dart';
import '../../../utils/base64_utils.dart';
import '../../../sd_jwt/sd_jwt_pretty_claims.dart';
import 'credential_binding_resolver.dart';
import 'credential_response_parser.dart';
import 'models/credential_response.dart';
import 'models/issuer_metadata.dart';
import 'models/token_response.dart';

part 'retrieve_credentials.freezed.dart';

/// Resultado de la recuperación de credenciales del credential endpoint.
@freezed
class RetrieveCredentialsResult with _$RetrieveCredentialsResult {
  const factory RetrieveCredentialsResult({
    required List<CredentialRecord> credentials,
    required List<DeferredCredentialRecord> deferredCredentials,
  }) = _RetrieveCredentialsResult;
}

/// Solicita todas las credenciales del offer al credential endpoint.
///
/// Por cada [credentialConfigurationId]:
/// 1. Construye el proof JWT via [buildCredentialProof].
/// 2. POST al credential endpoint con el access token y el proof.
/// 3. Si la respuesta incluye `credential` inmediato, parsea y retorna [CredentialRecord].
/// 4. Si la respuesta incluye `transaction_id`, retorna [DeferredCredentialRecord].
Future<RetrieveCredentialsResult> retrieveCredentials({
  required IssuerMetadata metadata,
  required TokenResponse tokenResponse,
  required List<String> credentialConfigurationIds,
  required KmsService kms,
  required DidService didService,
  required KeyRecordStore keyStore,
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  final uuid = const Uuid();

  final credentials = <CredentialRecord>[];
  final deferredCredentials = <DeferredCredentialRecord>[];

  // Determinar tipo de clave preferido (P-256 para EUDI/SD-JWT, Ed25519 como fallback)
  final signingInfo = await _resolveSigningInfo(
    metadata: metadata,
    credentialConfigurationIds: credentialConfigurationIds,
    didService: didService,
    keyStore: keyStore,
  );

  final cNonce = tokenResponse.cNonce ?? '';

  final supportedConfigIds = credentialConfigurationIds
      .where((id) => isWalletSupportedCredentialConfig(metadata, id))
      .toList();

  if (supportedConfigIds.isEmpty) {
    throw StateError(
      'La oferta no incluye credenciales SD-JWT compatibles. '
      'En issuer.eudiw.dev elegí solo formatos SD-JWT (no mDoc).',
    );
  }

  for (final configId in supportedConfigIds) {
    final format = credentialFormatForConfig(metadata, configId);

    final proof = await buildCredentialProof(
      holderDid: signingInfo.did,
      verificationMethodId: signingInfo.verificationMethodId,
      signingKey: signingInfo.keyRecord,
      kms: kms,
      issuerUrl: metadata.credentialIssuer,
      cNonce: cNonce,
    );

    final response = await client.post<Map<String, dynamic>>(
      metadata.credentialEndpoint,
      data: {
        'credential_configuration_id': configId,
        if (format != null) 'format': format,
        'proof': {'proof_type': 'jwt', 'jwt': proof},
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${tokenResponse.accessToken}'},
      ),
    );

    final credResponse = CredentialResponse.fromJson(response.data!);
    final issued = extractIssuedCredentials(response.data!);

    for (final raw in issued) {
      final record = await _parseCredential(
        raw: raw,
        configId: configId,
        metadata: metadata,
        holderDid: signingInfo.did,
        uuid: uuid,
      );
      if (record != null) credentials.add(record);
    }

    if (issued.isEmpty && credResponse.transactionId != null) {
      final now = DateTime.now().toUtc();
      deferredCredentials.add(
        DeferredCredentialRecord(
          id: uuid.v4(),
          createdAt: now,
          lastCheckedAt: now,
          response: response.data!,
          issuerMetadata: {
            'credential_issuer': metadata.credentialIssuer,
            'credential_endpoint': metadata.credentialEndpoint,
            if (metadata.tokenEndpoint != null) 'token_endpoint': metadata.tokenEndpoint!,
          },
          accessToken: {
            'access_token': tokenResponse.accessToken,
            'token_type': tokenResponse.tokenType,
            if (tokenResponse.cNonce != null) 'c_nonce': tokenResponse.cNonce!,
          },
        ),
      );
    }
  }

  if (credentials.isEmpty && deferredCredentials.isEmpty) {
    throw StateError(
      'El emisor respondió sin credenciales que la wallet pueda guardar. '
      'Verificá que elegiste formato SD-JWT en el issuer EUDI.',
    );
  }

  return RetrieveCredentialsResult(
    credentials: credentials,
    deferredCredentials: deferredCredentials,
  );
}

/// Formato OID4VCI de una configuración en metadata del issuer.
String? credentialFormatForConfig(IssuerMetadata metadata, String configId) {
  final config = metadata.credentialConfigurationsSupported[configId];
  if (config is Map<String, dynamic>) {
    return config['format'] as String?;
  }
  return null;
}

/// Indica si la wallet puede solicitar y almacenar esta configuración.
bool isWalletSupportedCredentialConfig(IssuerMetadata metadata, String configId) {
  final format = credentialFormatForConfig(metadata, configId);
  if (format == null) return false;
  final normalized = format.toLowerCase();
  if (normalized.contains('mdoc') || normalized == 'mso_mdoc') return false;
  return normalized.contains('sd-jwt') ||
      normalized == 'jwt_vc_json' ||
      normalized == 'jwt_vc';
}

/// Determina la clave de firma preferida en función de los formatos del offer.
///
/// Prefiere P-256 (para SD-JWT VC / EUDI) si alguna configuración usa ese formato.
Future<_SigningContext> _resolveSigningInfo({
  required IssuerMetadata metadata,
  required List<String> credentialConfigurationIds,
  required DidService didService,
  required KeyRecordStore keyStore,
}) async {
  final formats = credentialConfigurationIds.map((id) {
    final config = metadata.credentialConfigurationsSupported[id];
    if (config is Map<String, dynamic>) return config['format'] as String?;
    return null;
  }).whereType<String>().toSet();

  final keyType = formats.any((f) => f.contains('sd-jwt') || f == 'mso_mdoc')
      ? KeyType.p256
      : KeyType.ed25519;

  final signingInfo = await didService.getSigningDid(keyType);
  final keyRecord = await keyStore.getById(signingInfo.keyId);

  if (keyRecord == null) {
    throw StateError('KeyRecord no encontrado para keyId=${signingInfo.keyId}');
  }

  return _SigningContext(
    did: signingInfo.did,
    verificationMethodId: signingInfo.verificationMethodId,
    keyRecord: keyRecord,
  );
}

/// Parsea una credencial cruda al modelo de dominio correspondiente.
///
/// Soporta SD-JWT VC (`~`-separated) y JWT VC (W3C JSON-LD).
/// Retorna `null` para formatos no reconocidos (ej. mDoc CBOR — TODO Fase 4).
Future<CredentialRecord?> _parseCredential({
  required String raw,
  required String configId,
  required IssuerMetadata metadata,
  required String holderDid,
  required Uuid uuid,
}) async {
  // SD-JWT VC: disclosures con '~' o issuer JWT con claim vct
  if (raw.contains('~') || _looksLikeSdJwtIssuerJwt(raw)) {
    final normalized = raw.contains('~') ? raw : '$raw~';
    return _parseSdJwtVc(
      raw: normalized,
      uuid: uuid,
      metadata: metadata,
      configId: configId,
    );
  }

  // JWT VC (W3C): JWT con claim vc
  if (raw.contains('.')) {
    return _parseJwtVc(raw: raw, uuid: uuid, holderDid: holderDid);
  }

  return null;
}

bool _looksLikeSdJwtIssuerJwt(String raw) {
  if (!raw.contains('.')) return false;
  try {
    final parts = raw.split('.');
    if (parts.length < 2) return false;
    final payload = jsonDecode(utf8.decode(base64UrlDecode(parts[1])));
    return payload is Map<String, dynamic> && payload.containsKey('vct');
  } catch (_) {
    return false;
  }
}

Future<SdJwtVcRecord?> _parseSdJwtVc({
  required String raw,
  required Uuid uuid,
  required IssuerMetadata metadata,
  required String configId,
}) async {
  try {
    // Parte 0 del SD-JWT es el Issuer JWT (header.payload.signature)
    final issuerJwt = raw.split('~').first;
    final parts = issuerJwt.split('.');
    if (parts.length < 2) return null;

    final payloadJson = utf8.decode(base64UrlDecode(parts[1]));
    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

    final vct = payload['vct'] as String? ?? configId;
    final issuer = payload['iss'] as String? ?? metadata.credentialIssuer;

    Map<String, dynamic> prettyClaims;
    try {
      prettyClaims = await buildPrettyClaimsFromCompactSdJwt(raw);
    } catch (_) {
      prettyClaims = Map<String, dynamic>.fromEntries(
        payload.entries.where(
          (e) => !reservedSdJwtPayloadClaims.contains(e.key),
        ),
      );
    }

    final config = metadata.credentialConfigurationsSupported[configId];
    final issuerMeta = config is Map<String, dynamic>
        ? {'issuer': issuer, ...config}
        : <String, dynamic>{'issuer': issuer};

    return SdJwtVcRecord(
      id: uuid.v4(),
      createdAt: DateTime.now().toUtc(),
      compactSdJwt: raw,
      vct: vct,
      prettyClaims: prettyClaims,
      issuerMetadata: issuerMeta,
    );
  } catch (_) {
    return null;
  }
}

W3cCredentialRecord? _parseJwtVc({
  required String raw,
  required Uuid uuid,
  required String holderDid,
}) {
  try {
    final parts = raw.split('.');
    if (parts.length < 2) return null;

    final payloadJson = utf8.decode(base64UrlDecode(parts[1]));
    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
    final vc = payload['vc'] as Map<String, dynamic>?;
    if (vc == null) return null;

    final types = (vc['type'] as List<dynamic>?)?.cast<String>() ?? [];
    final issuerDid = payload['iss'] as String? ?? '';

    return W3cCredentialRecord(
      id: uuid.v4(),
      createdAt: DateTime.now().toUtc(),
      claimFormat: ClaimFormat.w3cJwt,
      credential: vc,
      types: types,
      issuerDid: issuerDid,
      holderDid: holderDid,
    );
  } catch (_) {
    return null;
  }
}

/// Contexto de firma resuelto para el credential request.
class _SigningContext {
  const _SigningContext({
    required this.did,
    required this.verificationMethodId,
    required this.keyRecord,
  });

  final String did;
  final String verificationMethodId;
  final KeyRecord keyRecord;
}
