import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../credential/models/credential_record.dart';
import '../../../credential/models/sd_jwt_vc_record.dart';
import '../../../credential/models/w3c_credential_record.dart';
import '../../../did/did_service.dart';
import '../../../kms/kms_service.dart';
import '../../../record/key_record_store.dart';
import '../../../record/models/key_record.dart';
import '../../../sd_jwt/holder_binding.dart';
import '../../../sd_jwt/sd_jwt_parser.dart';
import '../../../sd_jwt/sd_jwt_selector.dart';
import '../../../utils/base64_utils.dart';
import 'models/credentials_for_request.dart';

/// Resultado de [buildPresentation].
class PresentationBundle {
  const PresentationBundle({
    required this.vpToken,
    required this.presentationSubmission,
  });

  /// VP Token a enviar al verifier.
  ///
  /// String si es una sola credencial, List si son múltiples.
  final dynamic vpToken;

  /// Presentation Submission (solo PEX). Nulo para DCQL.
  final Map<String, dynamic>? presentationSubmission;
}

/// Construye la VP Token para enviar al verifier.
///
/// - Para SD-JWT VC: selecciona disclosures → SD-JWT presentado → kb-JWT.
/// - Para W3C JWT: construye un VP JWT firmado con el holder DID.
///
/// [selectedDisclosuresByDescriptor]: `{inputDescriptorId: [claimPath, ...]}`
/// [selectedCredentialsByDescriptor]: `{inputDescriptorId: CredentialRecord}`
Future<PresentationBundle> buildPresentation({
  required CredentialsForRequest resolvedRequest,
  required Map<String, List<String>> selectedDisclosuresByDescriptor,
  required Map<String, CredentialRecord> selectedCredentialsByDescriptor,
  required KmsService kms,
  required KeyRecordStore keyStore,
  required DidService didService,
}) async {
  final uuid = const Uuid();
  final vpTokens = <String>[];
  final descriptorMap = <Map<String, dynamic>>[];

  final nonce = resolvedRequest.nonce ?? '';
  final audience = resolvedRequest.verifierClientId;

  // Resolver clave de firma (P-256 para EUDI) — fallback si no hay cnf en la credencial.
  final defaultSigningInfo = await didService.getSigningDid(KeyType.p256);
  final defaultKeyRecord = await keyStore.getById(defaultSigningInfo.keyId);
  if (defaultKeyRecord == null) {
    throw StateError('KeyRecord no encontrado para keyId=${defaultSigningInfo.keyId}');
  }

  for (final entry in selectedCredentialsByDescriptor.entries) {
    final descriptorId = entry.key;
    final credential = entry.value;
    final claimPaths = selectedDisclosuresByDescriptor[descriptorId] ?? [];

    if (credential is SdJwtVcRecord) {
      final presented = await _buildSdJwtPresentation(
        credential: credential,
        claimPaths: claimPaths,
        audience: audience,
        nonce: nonce,
        kms: kms,
        keyStore: keyStore,
        didService: didService,
        defaultSigningKey: defaultKeyRecord,
        defaultVerificationMethodId: defaultSigningInfo.verificationMethodId,
      );
      vpTokens.add(presented);

      descriptorMap.add({
        'id': descriptorId,
        'format': 'vc+sd-jwt',
        'path': vpTokens.length == 1 ? r'$' : '\$[${vpTokens.length - 1}]',
      });
    } else if (credential is W3cCredentialRecord) {
      final vpJwt = await _buildVpJwt(
        credential: credential,
        audience: audience,
        nonce: nonce,
        kms: kms,
        signingKey: defaultKeyRecord,
        holderDid: defaultSigningInfo.did,
        verificationMethodId: defaultSigningInfo.verificationMethodId,
      );
      vpTokens.add(vpJwt);

      descriptorMap.add({
        'id': descriptorId,
        'format': 'jwt_vp_json',
        'path': vpTokens.length == 1 ? r'$' : '\$[${vpTokens.length - 1}]',
        'path_nested': {
          'format': 'jwt_vc_json',
          'path': r'$.vp.verifiableCredential[0]',
        },
      });
    }
  }

  // DCQL: vp_token debe ser un objeto JSON {credentialQueryId: presentation}
  // PEX: vp_token es string (una credencial) o List (múltiples)
  final dynamic vpToken;
  if (resolvedRequest.queryType == QueryType.dcql) {
    // OID4VP §8.1: cada query id → array de presentaciones.
    final map = <String, dynamic>{};
    for (var i = 0; i < vpTokens.length; i++) {
      map[descriptorMap[i]['id'] as String] = [vpTokens[i]];
    }
    vpToken = map;
  } else {
    vpToken = vpTokens.length == 1 ? vpTokens.first : vpTokens;
  }

  Map<String, dynamic>? presentationSubmission;
  if (resolvedRequest.queryType == QueryType.pex) {
    presentationSubmission = {
      'id': uuid.v4(),
      'definition_id': resolvedRequest.presentationDefinitionId ?? '',
      'descriptor_map': descriptorMap,
    };
  }

  return PresentationBundle(
    vpToken: vpToken,
    presentationSubmission: presentationSubmission,
  );
}

// — SD-JWT —

Future<String> _buildSdJwtPresentation({
  required SdJwtVcRecord credential,
  required List<String> claimPaths,
  required String audience,
  required String nonce,
  required KmsService kms,
  required KeyRecordStore keyStore,
  required DidService didService,
  required KeyRecord defaultSigningKey,
  required String defaultVerificationMethodId,
}) async {
  final token = await SdJwtParser.parse(credential.compactSdJwt);

  final presentablePaths = claimPaths.isEmpty
      ? claimPaths
      : SdJwtSelector.filterPresentableClaimPaths(
          token: token,
          requestedPaths: claimPaths,
        );

  final bindingKey = await _resolveHolderBindingKey(
    token: token,
    keyStore: keyStore,
    defaultKey: defaultSigningKey,
  );

  final selected = presentablePaths.isEmpty
      ? token.disclosures
      : SdJwtSelector.selectDisclosuresForPaths(token, presentablePaths);

  final presented = SdJwtSelector.buildPresented(token, selected);

  final requiresKb = HolderBinding.requiresHolderBinding(token.payload);
  if (!requiresKb) return presented;

  final kbJwt = await HolderBinding.buildKeyBindingJwt(
    audience: audience,
    nonce: nonce,
    sdJwtPresented: presented,
    kms: kms,
    signingKey: bindingKey,
    verificationMethodId: defaultVerificationMethodId,
  );

  return SdJwtSelector.buildWithKeyBinding(token, selected, kbJwt);
}

/// Resuelve la clave privada que coincide con `cnf.jwk` de la credencial.
Future<KeyRecord> _resolveHolderBindingKey({
  required SdJwtToken token,
  required KeyRecordStore keyStore,
  required KeyRecord defaultKey,
}) async {
  final cnf = token.payload['cnf'];
  if (cnf is Map) {
    final jwk = cnf['jwk'];
    if (jwk is Map) {
      final x = jwk['x'] as String?;
      final y = jwk['y'] as String?;
      if (x != null && y != null) {
        final keys = await keyStore.getAll();
        for (final key in keys) {
          if (key.privateJwk == null) continue;
          if (key.publicJwk['x'] == x && key.publicJwk['y'] == y) {
            return key;
          }
        }
      }
    }
  }
  return defaultKey;
}

// — W3C JWT VP —

Future<String> _buildVpJwt({
  required W3cCredentialRecord credential,
  required String audience,
  required String nonce,
  required KmsService kms,
  required KeyRecord signingKey,
  required String holderDid,
  required String verificationMethodId,
}) async {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  final header = <String, dynamic>{
    'alg': signingKey.keyType == KeyType.p256 ? 'ES256' : 'EdDSA',
    'typ': 'JWT',
    'kid': verificationMethodId,
  };

  final payload = <String, dynamic>{
    'iss': holderDid,
    'aud': audience,
    'iat': now,
    'nonce': nonce,
    'vp': {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': ['VerifiablePresentation'],
      'verifiableCredential': [credential.credential],
    },
  };

  return _signJwt(header: header, payload: payload, key: signingKey, kms: kms);
}

Future<String> _signJwt({
  required Map<String, dynamic> header,
  required Map<String, dynamic> payload,
  required KeyRecord key,
  required KmsService kms,
}) async {
  final headerB64 = base64UrlEncode(Uint8List.fromList(utf8.encode(jsonEncode(header))));
  final payloadB64 = base64UrlEncode(Uint8List.fromList(utf8.encode(jsonEncode(payload))));
  final signingInput = '$headerB64.$payloadB64';
  final signature = await kms.sign(
    key: key,
    payload: Uint8List.fromList(utf8.encode(signingInput)),
  );
  return '$signingInput.${base64UrlEncode(signature)}';
}
