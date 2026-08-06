/// Mecanismo de confianza detectado para un verifier o issuer.
enum TrustMechanismType {
  /// Certificado X.509 embebido en el header `x5c` del request JWT.
  x509,

  /// El `client_id` es un DID resolvible.
  did,

  /// OpenID Federation / EUDI RP Authentication (trust list europea).
  eudiRpAuthentication,
}
