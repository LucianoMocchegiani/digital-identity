import 'package:isar/isar.dart';

part 'mdoc_isar.g.dart';

/// Schema isar para credenciales mDoc (ISO 18013-5).
///
/// [issuerSignedBase64] almacena los bytes CBOR del IssuerSigned en base64url,
/// ya que isar no soporta [Uint8List] directamente como campo de colección.
/// [namespacesJson] almacena los namespaces decodificados como JSON anidado.
@collection
class MdocIsar {
  Id id = Isar.autoIncrement;

  /// Identificador lógico. Formato: `'mdoc-{uuid}'`.
  @Index(unique: true, replace: true)
  late String recordId;

  late DateTime createdAt;

  /// Tipo de documento (ej. `'eu.europa.ec.eudi.pid_mdoc'`).
  late String docType;

  /// `Map<String, Map<String, dynamic>>` serializado como JSON.
  late String namespacesJson;

  /// Bytes CBOR del IssuerSigned codificados en base64url.
  late String issuerSignedBase64;

  /// [Map<String,dynamic>] serializado como JSON. Nullable.
  String? displayMetadataJson;
}
