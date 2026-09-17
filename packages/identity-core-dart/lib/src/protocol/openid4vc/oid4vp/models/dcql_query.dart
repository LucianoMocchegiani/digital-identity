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

/// Conjunto DCQL (`credential_sets`): una option satisfecha alcanza (OR).
///
/// OpenID4VP §6.2. Fuera del freezed de [DcqlQuery] para no regenerar generated.
/// Sin este campo el JSON se parsea igual; el matching lo lee del mapa crudo.
class DcqlCredentialSet {
  /// Crea un set. [options] vacías no satisfacen un set `required`.
  const DcqlCredentialSet({
    required this.options,
    this.required = true,
  });

  /// Combinaciones válidas de ids de [DcqlCredentialQuery].
  final List<List<String>> options;

  /// Si es `false`, no bloquear el request cuando ninguna option matchea.
  final bool required;

  /// Parsea un objeto `{ options, required? }` del JSON DCQL.
  factory DcqlCredentialSet.fromJson(Map<String, dynamic> json) {
    final raw = json['options'];
    final options = <List<String>>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is! List || item.isEmpty) continue;
        options.add(item.map((e) => e.toString()).toList());
      }
    }
    return DcqlCredentialSet(
      options: options,
      required: json['required'] as bool? ?? true,
    );
  }
}

/// Lee `credential_sets` del JSON DCQL. `null` o lista vacía → AND de todas las credentials.
List<DcqlCredentialSet>? parseDcqlCredentialSets(Map<String, dynamic> json) {
  final raw = json['credential_sets'];
  if (raw is! List || raw.isEmpty) return null;
  final sets = <DcqlCredentialSet>[];
  for (final item in raw) {
    if (item is Map<String, dynamic>) {
      sets.add(DcqlCredentialSet.fromJson(item));
    } else if (item is Map) {
      sets.add(DcqlCredentialSet.fromJson(Map<String, dynamic>.from(item)));
    }
  }
  return sets.isEmpty ? null : sets;
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
