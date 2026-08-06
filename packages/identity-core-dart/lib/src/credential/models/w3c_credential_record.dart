import 'package:freezed_annotation/freezed_annotation.dart';

import 'credential_record.dart';

part 'w3c_credential_record.freezed.dart';

/// Credencial verificable en formato W3C Verifiable Credentials (JWT o JSON-LD).
///
/// Soporta tanto el formato JWT (`jwt_vc_json`) como JSON-LD (`ldp_vc`),
/// discriminados por [claimFormat]. El JSON completo de la credencial se
/// almacena en [credential] para permitir su re-verificación offline.
@freezed
class W3cCredentialRecord with _$W3cCredentialRecord implements CredentialRecord {
  const W3cCredentialRecord._();

  const factory W3cCredentialRecord({
    /// Identificador único. Formato: `'w3c-credential-{uuid}'`.
    required String id,

    /// Fecha de almacenamiento en el wallet.
    required DateTime createdAt,

    /// Formato exacto de la credencial (JWT o JSON-LD).
    required ClaimFormat claimFormat,

    /// Objeto JSON completo de la W3C Verifiable Credential.
    required Map<String, dynamic> credential,

    /// Tipos declarados en el campo `type` de la credencial.
    ///
    /// Ejemplo: `['VerifiableCredential', 'UniversityDegreeCredential']`
    required List<String> types,

    /// DID del issuer.
    String? issuerDid,

    /// DID del holder (claim `credentialSubject.id`).
    String? holderDid,

    /// Inicio de validez (`validFrom` o `issuanceDate`).
    DateTime? validFrom,

    /// Fin de validez (`validUntil` o `expirationDate`).
    DateTime? validUntil,

    /// Metadata de visualización extraída de la credencial.
    Map<String, dynamic>? displayMetadata,
  }) = _W3cCredentialRecord;
}
