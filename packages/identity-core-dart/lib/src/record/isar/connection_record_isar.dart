import 'package:isar/isar.dart';

part 'connection_record_isar.g.dart';

/// Schema isar para conexiones DIDComm.
@collection
class ConnectionRecordIsar {
  Id id = Isar.autoIncrement;

  /// UUID de la conexión, usado como clave de upsert.
  @Index(unique: true, replace: true)
  late String connectionId;

  late String myDid;
  late String theirDid;

  /// Índice del [ConnectionState] enum.
  late int stateIndex;

  late DateTime createdAt;
  String? label;
  String? goalCode;

  /// DID Document del par serializado como JSON.
  String? theirDidDocJson;
}
