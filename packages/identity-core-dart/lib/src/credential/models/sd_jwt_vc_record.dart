import 'package:freezed_annotation/freezed_annotation.dart';

import 'credential_record.dart';

part 'sd_jwt_vc_record.freezed.dart';

/// Credencial verificable en formato SD-JWT VC (`dc+sd-jwt`).
///
/// Es el formato principal del ecosistema EUDI. Almacena el token compacto
/// completo y los claims decodificados para su visualización sin necesidad
/// de volver a parsear el JWT en cada operación de UI.
///
/// La selección de disclosures para OID4VP se realiza sobre [compactSdJwt]
/// en [SdJwtSelector] (Fase 4).
@freezed
class SdJwtVcRecord with _$SdJwtVcRecord implements CredentialRecord {
  const SdJwtVcRecord._();

  const factory SdJwtVcRecord({
    /// Identificador único de la credencial. Formato: `'sd-jwt-vc-{uuid}'`.
    required String id,

    /// Fecha de almacenamiento en el wallet.
    required DateTime createdAt,

    /// Token SD-JWT compacto completo, incluyendo todas las disclosures del issuer.
    ///
    /// Formato: `{issuer-jwt}~{disclosure1}~{disclosure2}~...~`
    required String compactSdJwt,

    /// Tipo de credencial declarado por el issuer en el claim `vct`.
    ///
    /// Ejemplo: `'eu.europa.ec.eudi.pid_vc_sd_jwt'`
    required String vct,

    /// Claims decodificados con todas las disclosures aplicadas.
    ///
    /// Listo para mostrar en UI sin re-parsear el SD-JWT.
    required Map<String, dynamic> prettyClaims,

    /// Metadata del issuer obtenida del endpoint `/.well-known/openid-credential-issuer`.
    Map<String, dynamic>? issuerMetadata,

    /// Metadata de visualización (nombre, colores, logo) extraída de [issuerMetadata].
    Map<String, dynamic>? displayMetadata,
  }) = _SdJwtVcRecord;

  @override
  ClaimFormat get claimFormat => ClaimFormat.sdJwtVc;
}
