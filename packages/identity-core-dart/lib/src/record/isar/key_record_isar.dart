import 'package:isar/isar.dart';

part 'key_record_isar.g.dart';

/// Schema isar para pares de claves criptográficas.
///
/// [privateJwkJson] almacena el JWK privado completo (campo `d` incluido)
/// cifrado con AES-256-GCM (`enc:v1:`) vía [WalletCryptoContext] cuando la sesión
/// se abre con [WalletService]. Para claves hardware-backed, [privateJwkJson] es
/// null y [isHardwareBacked] es true.
@collection
class KeyRecordIsar {
  Id id = Isar.autoIncrement;

  /// UUID v4 del par de claves, usado como clave de upsert.
  @Index(unique: true, replace: true)
  late String keyId;

  /// Tipo de curva: 0=ed25519, 1=p256.
  late int keyTypeIndex;

  /// JWK público serializado como JSON (sin campo `d`).
  late String publicJwkJson;

  /// JWK privado serializado como JSON (incluye campo `d`).
  ///
  /// Null para claves hardware-backed donde la clave privada no puede exportarse.
  String? privateJwkJson;

  /// Indica si la clave reside en hardware (Android Keystore / iOS SE).
  late bool isHardwareBacked;

  late DateTime createdAt;

  /// DID asociado, si la clave fue generada como parte de una identidad.
  String? did;
}
