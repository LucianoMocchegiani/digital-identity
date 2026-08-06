/// Tipo de formato de credencial verificable.
///
/// Espeja los formatos soportados por el ecosistema EUDI y paradym-wallet:
/// SD-JWT VC, W3C JWT, W3C JSON-LD y mDoc (ISO 18013-5).
enum ClaimFormat {
  /// SD-JWT VC (`dc+sd-jwt`) — formato principal del ecosistema EUDI.
  sdJwtVc,

  /// W3C Verifiable Credential en formato JWT.
  w3cJwt,

  /// W3C Verifiable Credential en formato JSON-LD.
  w3cLdp,

  /// mDoc según ISO 18013-5 (CBOR).
  mdoc,
}

/// Contrato base para todos los tipos de credencial almacenados en el wallet.
///
/// Implementado por [SdJwtVcRecord], [W3cCredentialRecord] y [MdocRecord].
/// Permite operar sobre credenciales de forma polimórfica sin conocer el formato.
abstract class CredentialRecord {
  /// Identificador único de la credencial dentro del wallet.
  ///
  /// Formato: `'{claimFormat}-{uuid}'` (ej. `'sd-jwt-vc-abc123'`).
  String get id;

  /// Fecha y hora en que la credencial fue almacenada.
  DateTime get createdAt;

  /// Formato de la credencial, usado para rutear operaciones de firma y presentación.
  ClaimFormat get claimFormat;
}
