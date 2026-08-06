import '../../../credential/models/credential_record.dart';
import '../../../credential/models/sd_jwt_vc_record.dart';
import '../../../credential/models/w3c_credential_record.dart';
import '../../../sd_jwt/sd_jwt_parser.dart';
import '../../../sd_jwt/sd_jwt_selector.dart';
import 'filter_claim_paths.dart';
import 'models/credentials_for_request.dart';
import 'models/dcql_query.dart';
import 'models/presentation_definition.dart';

/// Evalúa las credenciales locales contra una [PresentationDefinition] (PEX).
///
/// Para cada [InputDescriptor] determina qué credenciales satisfacen
/// las `constraints.fields` definidas.
Future<FormattedSubmission> matchPex({
  required PresentationDefinition definition,
  required List<CredentialRecord> credentials,
}) async {
  final entries = <FormattedSubmissionEntry>[];

  for (final descriptor in definition.inputDescriptors) {
    final fields = _extractFields(descriptor.constraints);
    final matching = <CredentialRecord>[];

    for (final credential in credentials) {
      final claims = await _extractClaims(credential);
      if (claims != null && _satisfiesFields(fields, claims)) {
        matching.add(credential);
      }
    }

    final claimPaths = fields
        .map((f) => (f['path'] as List?)?.first as String? ?? '')
        .toList();

    entries.add(FormattedSubmissionEntry(
      inputDescriptorId: descriptor.id,
      isSatisfied: matching.isNotEmpty,
      name: descriptor.name,
      purpose: descriptor.purpose,
      matchingCredentials: matching.isEmpty ? null : matching,
      requestedClaimPaths: claimPaths.where((p) => p.isNotEmpty).toList(),
    ));
  }

  return FormattedSubmission(
    name: definition.name,
    purpose: definition.purpose,
    areAllSatisfied: entries.every((e) => e.isSatisfied),
    entries: entries,
  );
}

/// Evalúa las credenciales locales contra una [DcqlQuery].
///
/// Para cada [DcqlCredentialQuery] filtra por formato y metadatos (vct, doctype).
Future<FormattedSubmission> matchDcql({
  required DcqlQuery query,
  required List<CredentialRecord> credentials,
}) async {
  final entries = <FormattedSubmissionEntry>[];

  for (final credQuery in query.credentials) {
    final matching = <CredentialRecord>[];

    for (final credential in credentials) {
      if (_matchesDcqlFormat(credQuery, credential)) {
        matching.add(credential);
      }
    }

    final requestedPaths = credQuery.claims
            ?.map((c) => dcqlClaimPathToDotNotation(c.path))
            .where((p) => p.isNotEmpty)
            .toList() ??
        [];

    var presentablePaths = requestedPaths;
    if (requestedPaths.isNotEmpty && matching.isNotEmpty) {
      presentablePaths = await filterClaimPathsForCredential(
        matching.first,
        requestedPaths,
      );
    }

    entries.add(FormattedSubmissionEntry(
      inputDescriptorId: credQuery.id,
      isSatisfied: matching.isNotEmpty,
      matchingCredentials: matching.isEmpty ? null : matching,
      requestedClaimPaths: presentablePaths.isEmpty ? null : presentablePaths,
    ));
  }

  return FormattedSubmission(
    areAllSatisfied: entries.every((e) => e.isSatisfied),
    entries: entries,
  );
}

// — PEX helpers —

List<Map<String, dynamic>> _extractFields(Map<String, dynamic> constraints) {
  final fields = constraints['fields'];
  if (fields is! List) return [];
  return fields.whereType<Map<String, dynamic>>().toList();
}

bool _satisfiesFields(
  List<Map<String, dynamic>> fields,
  Map<String, dynamic> claims,
) {
  for (final field in fields) {
    final paths = (field['path'] as List?)?.cast<String>() ?? [];
    final filter = field['filter'] as Map<String, dynamic>?;
    final optional = field['optional'] as bool? ?? false;

    dynamic foundValue;
    var pathFound = false;

    for (final path in paths) {
      final value = _evaluateJsonPath(path, claims);
      if (value != null) {
        foundValue = value;
        pathFound = true;
        break;
      }
    }

    if (!pathFound) {
      if (!optional) return false;
      continue;
    }

    if (filter != null && !_evaluateFilter(filter, foundValue)) {
      if (!optional) return false;
    }
  }

  return true;
}

/// Evalúa un JSONPath simple sobre [json].
///
/// Soporta: `$`, `$.field`, `$.field.subfield`, `$.field[0]`.
dynamic _evaluateJsonPath(String path, Map<String, dynamic> json) {
  if (path == r'$') return json;

  final normalized =
      path.startsWith(r'$.') ? path.substring(2) : path.replaceFirst(r'$', '');

  dynamic current = json;
  for (final segment in normalized.split('.')) {
    if (current == null) return null;

    final bracketIdx = segment.indexOf('[');
    if (bracketIdx >= 0) {
      final field = segment.substring(0, bracketIdx);
      final indexStr = segment.substring(bracketIdx + 1, segment.indexOf(']'));
      final index = int.tryParse(indexStr);

      if (current is Map) {
        current = current[field];
      }
      if (current is List && index != null && index < current.length) {
        current = current[index];
      } else {
        return null;
      }
    } else {
      current = current is Map ? current[segment] : null;
    }
  }

  return current;
}

/// Evalúa un filtro PEX sobre [value].
///
/// Soporta: `const`, `type`, `pattern`, `enum` y `contains`.
bool _evaluateFilter(Map<String, dynamic> filter, dynamic value) {
  if (filter.containsKey('const')) return value == filter['const'];

  if (filter.containsKey('enum')) {
    final options = filter['enum'] as List?;
    return options?.contains(value) ?? false;
  }

  if (filter.containsKey('type')) {
    final type = filter['type'] as String;
    final typeOk = switch (type) {
      'string' => value is String,
      'number' || 'integer' => value is num,
      'boolean' => value is bool,
      'array' => value is List,
      'object' => value is Map,
      _ => true,
    };
    if (!typeOk) return false;
  }

  if (filter.containsKey('pattern') && value is String) {
    final pattern = RegExp(filter['pattern'] as String);
    if (!pattern.hasMatch(value)) return false;
  }

  if (filter.containsKey('contains')) {
    final contains = filter['contains'];
    if (value is! List || contains is! Map) return false;
    final itemFilter = Map<String, dynamic>.from(contains);
    if (!value.any((item) => _evaluateFilter(itemFilter, item))) {
      return false;
    }
  }

  return true;
}

/// Extrae los claims de una credencial para evaluación PEX.
///
/// Para SD-JWT VC: reconstruye claims vía [SdJwtSelector.reconstructClaims].
/// Para W3C JWT: usa el claim `vc` del record.
Future<Map<String, dynamic>?> _extractClaims(
    CredentialRecord credential) async {
  if (credential is SdJwtVcRecord) {
    final token = await SdJwtParser.parse(credential.compactSdJwt);
    return SdJwtSelector.reconstructClaims(token);
  }

  if (credential is W3cCredentialRecord) {
    return credential.credential;
  }

  return null;
}

// — DCQL helpers —

bool _matchesDcqlFormat(
    DcqlCredentialQuery query, CredentialRecord credential) {
  final format = query.format;

  if (credential is SdJwtVcRecord) {
    if (format != 'dc+sd-jwt' && format != 'vc+sd-jwt') return false;

    // Verificar vct_values si están especificados
    final meta = query.meta;
    if (meta != null) {
      final vctValues = meta['vct_values'] as List?;
      if (vctValues != null && !vctValues.contains(credential.vct))
        return false;
    }

    return true;
  }

  if (credential is W3cCredentialRecord) {
    if (format != 'jwt_vc_json' && format != 'ldp_vc') return false;
    return true;
  }

  return false;
}
