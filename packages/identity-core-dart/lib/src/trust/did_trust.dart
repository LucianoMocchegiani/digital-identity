import '../did/did_resolver.dart';
import 'models/trust_mechanism.dart';
import 'models/trusted_entity.dart';

/// Valida la confianza en un verifier cuyo `client_id` es un DID.
///
/// Resuelve el DID y verifica que el kid de firma esté en el DID Document.
/// DID trust es el mecanismo más débil: solo garantiza que el DID es resolvible,
/// no que pertenece a una entidad registrada en un trust framework.
class DidTrust {
  DidTrust(this._resolver);

  final UniversalDidResolver _resolver;

  /// Valida [clientId] como DID y retorna el [TrustedEntity] correspondiente.
  ///
  /// [requestSignatureKid]: kid del header del request JWT. Si se provee, se
  ///   verifica que esté presente en el DID Document como verification method.
  ///
  /// [clientMetadata]: `client_metadata` del request payload para extraer
  ///   `client_name` y `logo_uri`.
  Future<TrustedEntity> validate({
    required String clientId,
    String? requestSignatureKid,
    Map<String, dynamic>? clientMetadata,
  }) async {
    final orgName = clientMetadata?['client_name'] as String?;
    final logoUri = clientMetadata?['logo_uri'] as String?;

    Map<String, dynamic>? didDocument;
    try {
      didDocument = await _resolver.resolve(clientId);
    } catch (_) {
      return _build(
        clientId: clientId,
        isVerified: false,
        organizationName: orgName,
        logoUri: logoUri,
      );
    }

    if (didDocument == null) {
      return _build(
        clientId: clientId,
        isVerified: false,
        organizationName: orgName,
        logoUri: logoUri,
      );
    }

    bool kidFound = true;
    if (requestSignatureKid != null) {
      kidFound = _kidExistsInDocument(didDocument, requestSignatureKid);
    }

    return _build(
      clientId: clientId,
      isVerified: kidFound,
      organizationName: orgName,
      logoUri: logoUri,
    );
  }

  bool _kidExistsInDocument(Map<String, dynamic> didDoc, String kid) {
    final vms = didDoc['verificationMethod'] as List?;
    if (vms == null) return false;
    return vms.any((vm) => vm is Map && vm['id'] == kid);
  }

  TrustedEntity _build({
    required String clientId,
    required bool isVerified,
    String? organizationName,
    String? logoUri,
  }) {
    return TrustedEntity(
      trustMechanism: TrustMechanismType.did,
      isVerified: isVerified,
      did: clientId,
      relyingParty: RelyingParty(
        entityId: clientId,
        organizationName: organizationName,
        logoUri: logoUri,
      ),
    );
  }
}
