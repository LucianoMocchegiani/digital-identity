import 'models/trust_mechanism.dart';

/// Detecta el mecanismo de confianza a partir del request JWT y su estado de verificación.
///
/// Lógica equivalente a `detectTrustMechanism` del Paradym SDK:
/// 1. Si [signatureVerified] no es null → EUDI RP Authentication.
/// 2. Si el header contiene `x5c` → X.509.
/// 3. Si `client_id` empieza con `'did:'` → DID.
/// 4. Default → DID (trust mínima).
abstract final class TrustDetector {
  /// Detecta el [TrustMechanismType] apropiado.
  ///
  /// [requestHeader]: payload del header del request JWT decodificado.
  /// [requestPayload]: payload del body del request JWT decodificado.
  /// [signatureVerified]: resultado de la verificación EUDI Federation. Si no
  ///   es null significa que ya se verificó contra una trust list.
  static TrustMechanismType detect({
    required Map<String, dynamic> requestHeader,
    required Map<String, dynamic> requestPayload,
    bool? signatureVerified,
  }) {
    if (signatureVerified != null) return TrustMechanismType.eudiRpAuthentication;

    if (requestHeader.containsKey('x5c')) return TrustMechanismType.x509;

    final clientId = requestPayload['client_id'] as String? ?? '';
    if (clientId.startsWith('did:')) return TrustMechanismType.did;

    return TrustMechanismType.did;
  }
}
