import 'package:isar/isar.dart';

part 'deferred_credential_isar.g.dart';

/// Schema isar para credenciales diferidas pendientes de recuperación.
///
/// El issuer devuelve un `transaction_id` cuando la credencial no está disponible
/// de inmediato. Este registro persiste el estado necesario para reintentar.
@collection
class DeferredCredentialIsar {
  Id id = Isar.autoIncrement;

  /// Identificador único del registro.
  @Index(unique: true, replace: true)
  late String recordId;

  late DateTime createdAt;
  late DateTime lastCheckedAt;
  DateTime? lastErroredAt;

  /// Respuesta del credential endpoint serializada como JSON.
  late String responseJson;

  /// Metadata del issuer serializada como JSON.
  late String issuerMetadataJson;

  /// Access token serializado como JSON.
  late String accessTokenJson;
}
