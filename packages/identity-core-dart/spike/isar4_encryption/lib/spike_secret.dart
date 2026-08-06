import 'package:isar/isar.dart';

part 'spike_secret.g.dart';

/// Registro mínimo para probar cifrado SQLite en Isar 4.
@collection
class SpikeSecret {
  late int id;

  @Index(unique: true, hash: true)
  late String secretId;

  late String payload;
}
