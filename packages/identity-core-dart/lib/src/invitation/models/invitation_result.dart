import '../../protocol/openid4vc/oid4vci/resolve_credential_offer.dart';
import '../../protocol/openid4vc/oid4vp/models/credentials_for_request.dart';

export 'invitation_type.dart';

/// Flujo DIDComm detectado en la invitación.
///
/// Placeholder para Fase 7 — los valores reflejan los goal codes de OOB.
enum DidCommFlowType {
  /// El invitador quiere emitir una credencial.
  issue,

  /// El invitador quiere verificar una credencial.
  verify,

  /// Solicitud de conexión sin flujo específico.
  connect,
}

/// Categoría de error al resolver una invitación.
enum InvitationErrorType {
  /// El formato de la URL no es reconocido.
  unknownFormat,

  /// Falló el fetch del request_uri / credential_offer_uri.
  fetchFailed,

  /// El payload descargado no es parseable.
  invalidPayload,

  /// No hay credenciales locales que satisfagan la solicitud OID4VP.
  noMatchingCredentials,
}

/// Resultado sellado del procesamiento de una invitación.
///
/// Usar con `switch` exhaustivo:
/// ```dart
/// switch (result) {
///   case Oid4VciInvitationResult():  // navegar a issuance
///   case Oid4VpInvitationResult():   // navegar a presentación
///   case DidCommInvitationResult():  // navegar a DIDComm (Fase 7)
///   case InvitationErrorResult():    // mostrar error
/// }
/// ```
sealed class InvitationResult {}

/// La URL era una oferta OID4VCI ya resuelta.
final class Oid4VciInvitationResult implements InvitationResult {
  const Oid4VciInvitationResult(this.offer);

  final ResolvedCredentialOffer offer;
}

/// La URL era una solicitud OID4VP ya resuelta con credenciales disponibles.
final class Oid4VpInvitationResult implements InvitationResult {
  const Oid4VpInvitationResult(this.request);

  final CredentialsForRequest request;
}

/// La URL era una invitación DIDComm (procesamiento completo en Fase 7).
final class DidCommInvitationResult implements InvitationResult {
  const DidCommInvitationResult({
    required this.invitation,
    required this.flowType,
  });

  /// Payload JSON decodificado de la invitación OOB.
  final Map<String, dynamic> invitation;

  final DidCommFlowType flowType;
}

/// La resolución falló.
final class InvitationErrorResult implements InvitationResult {
  const InvitationErrorResult({
    required this.message,
    required this.type,
  });

  final String message;
  final InvitationErrorType type;
}
