import 'package:isar/isar.dart';

part 'w3c_credential_isar.g.dart';

/// Schema isar para credenciales W3C (JWT y JSON-LD).
///
/// El [claimFormatIndex] almacena el índice del enum [ClaimFormat]
/// para distinguir entre `w3cJwt` (índice 1) y `w3cLdp` (índice 2).
@collection
class W3cCredentialIsar {
  Id id = Isar.autoIncrement;

  /// Identificador lógico. Formato: `'w3c-credential-{uuid}'`.
  @Index(unique: true, replace: true)
  late String recordId;

  late DateTime createdAt;

  /// Índice del enum ClaimFormat (1=w3cJwt, 2=w3cLdp).
  late int claimFormatIndex;

  /// [Map<String,dynamic>] de la credencial serializado como JSON.
  late String credentialJson;

  /// Lista de tipos de la credencial (`type` field).
  late List<String> types;

  String? issuerDid;
  String? holderDid;
  DateTime? validFrom;
  DateTime? validUntil;

  /// [Map<String,dynamic>] serializado como JSON. Nullable.
  String? displayMetadataJson;
}
