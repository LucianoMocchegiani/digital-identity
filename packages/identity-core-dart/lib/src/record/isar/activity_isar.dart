import 'package:isar/isar.dart';

part 'activity_isar.g.dart';

/// Schema isar para el historial de actividad del wallet.
///
/// Almacena tanto issuance activities como presentation activities en la misma
/// colección, discriminadas por [type]. Los campos opcionales son específicos
/// de cada tipo de actividad.
@collection
class ActivityIsar {
  Id id = Isar.autoIncrement;

  /// Identificador único de la actividad.
  @Index(unique: true, replace: true)
  late String recordId;

  /// Tipo de actividad: `'issuance'` o `'presentation'`.
  late String type;

  /// Estado: `'success'`, `'failed'` o `'stopped'`.
  late String status;

  late DateTime date;

  // — Entidad involucrada —
  String? entityId;
  String? entityHost;
  String? entityName;

  // — Específico de issuance —
  List<String>? credentialIds;

  // — Específico de presentation —

  /// Nombre del presentation request.
  String? requestName;

  /// Propósito declarado por el verifier.
  String? requestPurpose;

  /// IDs de credenciales presentadas.
  List<String>? presentedCredentialIds;
}
