import 'package:freezed_annotation/freezed_annotation.dart';

part 'dcql_query.freezed.dart';
part 'dcql_query.g.dart';

/// DCQL Query: Digital Credentials Query Language.
///
/// Alternativa moderna a PEX para selección de credenciales.
@freezed
class DcqlQuery with _$DcqlQuery {
  const factory DcqlQuery({
    /// Lista de queries individuales de credencial.
    required List<DcqlCredentialQuery> credentials,
  }) = _DcqlQuery;

  factory DcqlQuery.fromJson(Map<String, dynamic> json) =>
      _$DcqlQueryFromJson(json);
}

/// Query para una credencial específica dentro de una [DcqlQuery].
@freezed
class DcqlCredentialQuery with _$DcqlCredentialQuery {
  const factory DcqlCredentialQuery({
    /// Identificador único de esta query (referenciado en la presentación).
    required String id,

    /// Formato de credencial requerido: `'dc+sd-jwt'`, `'mso_mdoc'`, etc.
    required String format,

    /// Metadatos de matching: `vct_values`, `doctype_value`, etc.
    Map<String, dynamic>? meta,

    /// Claims requeridos para esta credencial.
    List<DcqlClaim>? claims,
  }) = _DcqlCredentialQuery;

  factory DcqlCredentialQuery.fromJson(Map<String, dynamic> json) =>
      _$DcqlCredentialQueryFromJson(json);
}

/// Claim requerido dentro de una [DcqlCredentialQuery].
@freezed
class DcqlClaim with _$DcqlClaim {
  const factory DcqlClaim({
    /// Ruta del claim. `null` en el último segmento indica contenedor de array (DCQL).
    @JsonKey(fromJson: _dcqlPathFromJson, toJson: _dcqlPathToJson)
    List<String?>? path,

    /// Namespace para mDoc (reemplaza [path] en formato ISO 18013-5).
    String? namespace,

    /// Nombre del claim en el namespace mDoc.
    @JsonKey(name: 'claim_name') String? claimName,

    /// Si el claim es opcional o requerido.
    @JsonKey(defaultValue: false) bool? optional,
  }) = _DcqlClaim;

  factory DcqlClaim.fromJson(Map<String, dynamic> json) =>
      _$DcqlClaimFromJson(json);
}

List<String?>? _dcqlPathFromJson(dynamic json) {
  if (json is! List) return null;
  return json.map((e) => e == null ? null : e.toString()).toList();
}

List<dynamic>? _dcqlPathToJson(List<String?>? path) => path;

/// Convierte path DCQL a notación con puntos. `["nationalities", null]` → `nationalities`.
String dcqlClaimPathToDotNotation(List<String?>? path) {
  if (path == null || path.isEmpty) return '';
  final segments = <String>[];
  for (final segment in path) {
    if (segment == null) break;
    segments.add(segment);
  }
  return segments.join('.');
}
