import 'package:uuid/uuid.dart';

import '../../../credential/bbs/bbs_credential.dart';
import '../../../credential/models/credential_record.dart';
import '../../../credential/models/w3c_credential_record.dart';
import '../../../crypto/ldp/ed25519_signature_2018.dart';
import '../../../did/did_service.dart';
import '../../../kms/kms_service.dart';
import '../../../record/key_record_store.dart';
import '../../../record/models/key_record.dart';
import '../../openid4vc/oid4vp/models/credentials_for_request.dart';
import '../../openid4vc/oid4vp/match_credentials.dart';
import '../../openid4vc/oid4vp/models/presentation_definition.dart';

/// Resultado de construir una VP JSON-LD firmada para DIDComm present-proof.
class DidCommPresentationBundle {
  const DidCommPresentationBundle({
    required this.vpDocument,
    required this.presentationDefinitionId,
    required this.descriptorMap,
  });

  final Map<String, dynamic> vpDocument;
  final String presentationDefinitionId;
  final List<Map<String, dynamic>> descriptorMap;
}

/// Construye y firma una Verifiable Presentation JSON-LD (LDP) para Credo.
abstract final class DidCommPresentationBuilder {
  static const _uuid = Uuid();

  /// Evalúa credenciales locales contra el PD del request.
  static Future<FormattedSubmission> matchCredentials({
    required Map<String, dynamic> presentationDefinitionJson,
    required List<CredentialRecord> credentials,
  }) async {
    final definition =
        PresentationDefinition.fromJson(presentationDefinitionJson);
    final w3cOnly = credentials.whereType<W3cCredentialRecord>().toList();
    return matchPex(definition: definition, credentials: w3cOnly);
  }

  /// Construye la VP firmada con `Ed25519Signature2018`.
  ///
  /// Si alguna VC seleccionada es `BbsBlsSignature2020`, deriva
  /// `BbsBlsSignatureProof2020` según paths del PD antes de embeberla.
  ///
  /// [selectedByDescriptor]: `{inputDescriptorId: W3cCredentialRecord}`.
  /// [issuerDidDocument]: opcional; ayuda al bridge MATTR a resolver la VM BLS.
  static Future<DidCommPresentationBundle> build({
    required Map<String, dynamic> presentationDefinitionJson,
    required Map<String, W3cCredentialRecord> selectedByDescriptor,
    required String challenge,
    required KmsService kms,
    required KeyRecordStore keyStore,
    required DidService didService,
    Map<String, dynamic>? issuerDidDocument,
  }) async {
    final definition =
        PresentationDefinition.fromJson(presentationDefinitionJson);
    final signingInfo = await didService.getSigningDid(KeyType.ed25519);
    final signingKey = await keyStore.getById(signingInfo.keyId);
    if (signingKey == null) {
      throw StateError('KeyRecord no encontrado para ${signingInfo.keyId}');
    }

    final selectedCredentialJsons = <Map<String, dynamic>>[
      for (final c in selectedByDescriptor.values)
        Map<String, dynamic>.from(c.credential),
    ];
    final pdForVp = presentationDefinitionForHolderVpSigning(
      presentationDefinitionJson,
      selectedCredentialJsons,
    );
    final definitionForMap = PresentationDefinition.fromJson(pdForVp);

    final verifiableCredentials = <Map<String, dynamic>>[];
    final descriptorMap = <Map<String, dynamic>>[];

    for (final descriptor in definition.inputDescriptors) {
      final credential = selectedByDescriptor[descriptor.id];
      if (credential == null) continue;

      final raw = Map<String, dynamic>.from(credential.credential);
      final proofType = (raw['proof'] is Map)
          ? (raw['proof'] as Map)['type'] as String?
          : null;

      Map<String, dynamic> toEmbed = raw;
      if (proofType == kBbsProofType) {
        try {
          toEmbed = await maybeDeriveBbsCredentialForPex(
            credential: raw,
            presentationDefinition: presentationDefinitionJson,
            nonce: challenge,
            issuerDidDocument: issuerDidDocument,
          );
        } catch (e) {
          throw StateError(
            'No se pudo derivar selective disclosure BBS+ para '
            '${descriptor.id}: $e',
          );
        }
      }

      verifiableCredentials.add(toEmbed);
      final idx = verifiableCredentials.length - 1;
      descriptorMap.add({
        'id': descriptor.id,
        'format': 'ldp_vc',
        'path': '\$.verifiableCredential[$idx]',
      });
    }

    if (verifiableCredentials.isEmpty) {
      throw StateError('No hay credenciales seleccionadas para la presentación.');
    }

    final submissionId = _uuid.v4();
    final presentationSubmission = {
      'id': submissionId,
      'definition_id': definitionForMap.id,
      'descriptor_map': descriptorMap,
    };

    final vpWithoutProof = <String, dynamic>{
      '@context': [
        'https://www.w3.org/2018/credentials/v1',
        'https://identity.foundation/presentation-exchange/submission/v1',
      ],
      'type': ['VerifiablePresentation', 'PresentationSubmission'],
      'holder': signingInfo.did,
      'presentation_submission': presentationSubmission,
      'verifiableCredential': verifiableCredentials,
    };

    final proof = await Ed25519Signature2018.createProof(
      document: vpWithoutProof,
      verificationMethod: signingInfo.verificationMethodId,
      proofPurpose: 'authentication',
      challenge: challenge,
      kms: kms,
      signingKey: signingKey,
    );

    final vpDocument = Map<String, dynamic>.from(vpWithoutProof)
      ..['proof'] = proof;

    return DidCommPresentationBundle(
      vpDocument: vpDocument,
      presentationDefinitionId: definitionForMap.id,
      descriptorMap: descriptorMap,
    );
  }
}
