/// Configuración de mecanismos de confianza para el flujo OID4VP.
class TrustConfig {
  const TrustConfig({
    this.trustedRootCertificates = const [],
    this.eudiTrustAnchorUrl,
  });

  /// Certificados raíz de confianza en base64 DER.
  ///
  /// Cuando no está vacía, la validación X.509 rechaza certificados cuya CA
  /// raíz no esté en esta lista.
  final List<String> trustedRootCertificates;

  /// URL del trust anchor para OpenID Federation / EUDI.
  ///
  /// Requerido para el mecanismo [TrustMechanismType.eudiRpAuthentication].
  final String? eudiTrustAnchorUrl;
}
