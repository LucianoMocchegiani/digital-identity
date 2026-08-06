/// Estado de una actividad del wallet.
enum ActivityStatus {
  /// La operación completó exitosamente.
  success,

  /// La operación falló (error de red, credencial inválida, etc.).
  failed,

  /// El usuario canceló la operación antes de completarla.
  stopped,
}

/// Información de la entidad (issuer o verifier) involucrada en la actividad.
class ActivityEntity {
  /// Identificador de la entidad (DID o URL HTTPS).
  final String? id;

  /// Dominio o hostname de la entidad.
  final String? host;

  /// Nombre para mostrar.
  final String? name;

  const ActivityEntity({this.id, this.host, this.name});
}

/// Registro de actividad del wallet.
///
/// Jerarquía sellada: [IssuanceActivity] para credenciales recibidas,
/// [PresentationActivity] para credenciales presentadas.
sealed class Activity {
  /// Identificador único de la actividad (UUID v4).
  String get id;

  /// Fecha y hora de la actividad.
  DateTime get date;

  /// Estado de la operación.
  ActivityStatus get status;

  /// Información de la entidad involucrada (issuer o verifier).
  ActivityEntity get entity;
}

/// Actividad de emisión — credencial recibida via OID4VCI o DIDComm.
final class IssuanceActivity implements Activity {
  @override
  final String id;

  @override
  final DateTime date;

  @override
  final ActivityStatus status;

  @override
  final ActivityEntity entity;

  /// IDs de las credenciales recibidas en esta emisión.
  final List<String> credentialIds;

  const IssuanceActivity({
    required this.id,
    required this.date,
    required this.status,
    required this.entity,
    required this.credentialIds,
  });
}

/// Actividad de presentación — credencial presentada via OID4VP o DIDComm.
final class PresentationActivity implements Activity {
  @override
  final String id;

  @override
  final DateTime date;

  @override
  ActivityStatus get status => request.status;

  @override
  final ActivityEntity entity;

  /// Detalle de la presentación realizada.
  final PresentationRequest request;

  const PresentationActivity({
    required this.id,
    required this.date,
    required this.entity,
    required this.request,
  });
}

/// Detalle de una presentación de credencial.
class PresentationRequest {
  /// Nombre del request de presentación (del presentation definition).
  final String? name;

  /// Propósito declarado por el verifier.
  final String? purpose;

  /// Estado de la operación.
  final ActivityStatus status;

  /// IDs de las credenciales presentadas.
  final List<String> credentialIds;

  const PresentationRequest({
    required this.status,
    required this.credentialIds,
    this.name,
    this.purpose,
  });
}
