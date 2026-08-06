import 'package:isar/isar.dart';

part 'did_isar.g.dart';

/// Schema isar para DIDs controlados por el wallet.
@collection
class DidIsar {
  Id id = Isar.autoIncrement;

  /// El DID completo, usado como clave de upsert.
  @Index(unique: true, replace: true)
  late String did;

  /// Método DID (`'key'`, `'jwk'`, `'peer'`, `'web'`).
  late String method;

  /// DID Document serializado como JSON.
  late String documentJson;

  /// IDs de claves en [KeyRecordIsar] asociadas a este DID.
  late List<String> keyIds;

  late DateTime createdAt;
}
