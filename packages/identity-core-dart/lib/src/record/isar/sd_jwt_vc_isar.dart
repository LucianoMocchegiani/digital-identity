import 'package:isar/isar.dart';

part 'sd_jwt_vc_isar.g.dart';

/// Schema isar para credenciales SD-JWT VC.
///
/// Los campos [Map<String,dynamic>] se almacenan como JSON serializado.
/// El campo [recordId] es el identificador lógico (string) y actúa
/// como clave de upsert via `putByRecordId`.
@collection
class SdJwtVcIsar {
  Id id = Isar.autoIncrement;

  /// Identificador lógico de la credencial. Formato: `'sd-jwt-vc-{uuid}'`.
  @Index(unique: true, replace: true)
  late String recordId;

  late DateTime createdAt;

  /// Token SD-JWT compacto completo.
  late String compactSdJwt;

  /// Tipo de credencial (`vct` claim).
  late String vct;

  /// [Map<String,dynamic>] serializado como JSON.
  late String prettyClaimsJson;

  /// [Map<String,dynamic>] serializado como JSON. Nullable.
  String? issuerMetadataJson;

  /// [Map<String,dynamic>] serializado como JSON. Nullable.
  String? displayMetadataJson;
}
