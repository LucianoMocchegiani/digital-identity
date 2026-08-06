import '../protocol/openid4vc/oid4vci/models/credential_offer.dart';
import '../protocol/openid4vc/oid4vci/models/issuer_metadata.dart';
import '../protocol/openid4vc/oid4vci/models/token_response.dart';

/// Estado de una sesión OID4VCI en curso.
class SessionRecord {
  SessionRecord({
    required this.sessionId,
    required this.offerUri,
    required this.createdAt,
    required this.offer,
    required this.issuerMetadata,
    this.tokenResponse,
    this.status = SessionStatus.pending,
  });

  final String sessionId;
  final String offerUri;
  final DateTime createdAt;
  final CredentialOffer offer;
  final IssuerMetadata issuerMetadata;
  TokenResponse? tokenResponse;
  SessionStatus status;
}

/// Estado de progreso de una sesión OID4VCI.
enum SessionStatus { pending, tokenAcquired, completed, failed }

/// Store en memoria para sesiones OID4VCI activas.
///
/// Las sesiones son efímeras: no persisten entre reinicios de la app.
/// Una sesión representa el flujo completo desde la resolución del offer
/// hasta la recepción de credenciales.
class SessionRecordStore {
  final _sessions = <String, SessionRecord>{};

  /// Guarda [session] indexada por su [SessionRecord.sessionId].
  void save(SessionRecord session) {
    _sessions[session.sessionId] = session;
  }

  /// Retorna la sesión con [sessionId], o `null` si no existe.
  SessionRecord? getById(String sessionId) => _sessions[sessionId];

  /// Retorna todas las sesiones activas.
  List<SessionRecord> getAll() => _sessions.values.toList();

  /// Elimina la sesión con [sessionId].
  void delete(String sessionId) => _sessions.remove(sessionId);

  /// Elimina todas las sesiones.
  void clear() => _sessions.clear();
}
