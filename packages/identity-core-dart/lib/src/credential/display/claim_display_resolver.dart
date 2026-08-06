import '../models/credential_record.dart';
import '../models/mdoc_record.dart';
import '../models/sd_jwt_vc_record.dart';
import '../models/w3c_credential_record.dart';
import 'labeled_claim.dart';

/// Resuelve claims de una credencial con etiquetas del metadata OID4VCI/EUDI.
///
/// Prioriza `credential_metadata.claims` (array con `path` + `display`) y hace
/// fallback a `claims` legacy (objeto o array). Los claims sin metadata usan
/// una etiqueta humanizada de la clave técnica.
class ClaimDisplayResolver {
  const ClaimDisplayResolver._();

  /// [locale] es un código BCP47 corto (`es`, `en`). Si es `null`, se usa el
  /// primer `display.name` disponible.
  static List<LabeledClaim> resolve(
    CredentialRecord record, {
    String? locale,
  }) {
    final values = _rawClaimsMap(record);
    if (values.isEmpty) return const [];

    final definitions = _claimDefinitionsFor(record);
    if (definitions.isEmpty) {
      return _fallbackFromValues(values);
    }

    final usedKeys = <String>{};
    final result = <LabeledClaim>[];

    for (final definition in definitions) {
      final value = _valueAtPath(values, definition.path);
      if (value == null) continue;

      final key = definition.path.isNotEmpty
          ? definition.path.last
          : definition.path.join('.');
      usedKeys.add(key);

      result.add(
        LabeledClaim(
          label: _labelFromDisplay(definition.display, locale: locale) ??
              humanizeClaimKey(key),
          key: key,
          value: value,
        ),
      );
    }

    for (final entry in values.entries) {
      if (usedKeys.contains(entry.key)) continue;
      result.add(
        LabeledClaim(
          label: humanizeClaimKey(entry.key),
          key: entry.key,
          value: entry.value,
        ),
      );
    }

    return result;
  }

  /// Etiquetas ordenadas del metadata OID4VCI (sin valores de credencial).
  static List<String> orderedDisplayLabels(
    Map<String, dynamic>? config, {
    String? locale,
  }) {
    return orderedDisplayClaims(config, locale: locale)
        .map((c) => c.label)
        .toList();
  }

  /// Claims de preview OID4VCI desde metadata (labels; values opcionales).
  ///
  /// Sin [values], `value` queda vacío: el offer estándar no trae datos del
  /// sujeto, solo definiciones de display.
  static List<LabeledClaim> orderedDisplayClaims(
    Map<String, dynamic>? config, {
    String? locale,
    Map<String, dynamic>? values,
  }) {
    final definitions = _parseClaimDefinitions(config);
    if (definitions.isEmpty) {
      if (values == null || values.isEmpty) return const [];
      return _fallbackFromValues(subjectClaimsForDisplay(values));
    }

    final usedKeys = <String>{};
    final result = <LabeledClaim>[];

    for (final definition in definitions) {
      final key = definition.path.isNotEmpty
          ? definition.path.last
          : definition.path.join('.');
      usedKeys.add(key);

      final value = values != null ? _valueAtPath(values, definition.path) : null;
      result.add(
        LabeledClaim(
          label: _labelFromDisplay(definition.display, locale: locale) ??
              humanizeClaimKey(key),
          key: key,
          value: value ?? '',
        ),
      );
    }

    if (values != null) {
      for (final entry in subjectClaimsForDisplay(values).entries) {
        if (usedKeys.contains(entry.key)) continue;
        result.add(
          LabeledClaim(
            label: humanizeClaimKey(entry.key),
            key: entry.key,
            value: entry.value,
          ),
        );
      }
    }

    return result;
  }

  static Map<String, dynamic> _rawClaimsMap(CredentialRecord record) {
    if (record is SdJwtVcRecord) return record.prettyClaims;
    if (record is W3cCredentialRecord) {
      return subjectClaimsForDisplay(record.credential['credentialSubject']);
    }
    if (record is MdocRecord) {
      final result = <String, dynamic>{};
      for (final ns in record.namespaces.values) {
        result.addAll(ns);
      }
      return result;
    }
    return const {};
  }

  static List<_ClaimDefinition> _claimDefinitionsFor(CredentialRecord record) {
    if (record is SdJwtVcRecord) {
      return _parseClaimDefinitions(record.issuerMetadata);
    }
    if (record is W3cCredentialRecord) {
      return _parseClaimDefinitions(record.displayMetadata);
    }
    if (record is MdocRecord) {
      return _parseClaimDefinitions(record.displayMetadata);
    }
    return const [];
  }

  static List<_ClaimDefinition> _parseClaimDefinitions(
    Map<String, dynamic>? source,
  ) {
    if (source == null) return const [];

    final fromCredentialMetadata = source['credential_metadata'];
    if (fromCredentialMetadata is Map) {
      final parsed = _parseClaimsNode(fromCredentialMetadata['claims']);
      if (parsed.isNotEmpty) return parsed;
    }

    final fromRoot = _parseClaimsNode(source['claims']);
    if (fromRoot.isNotEmpty) return fromRoot;

    final display = source['display'];
    if (display is List) {
      for (final entry in display) {
        if (entry is! Map) continue;
        final parsed = _parseClaimsNode(entry['claims']);
        if (parsed.isNotEmpty) return parsed;
      }
    } else if (display is Map) {
      return _parseClaimsNode(display['claims']);
    }

    return const [];
  }

  static List<_ClaimDefinition> _parseClaimsNode(dynamic claims) {
    if (claims is List) return _parseArrayClaims(claims);
    if (claims is Map) return _parseObjectClaims(claims);
    return const [];
  }

  static List<_ClaimDefinition> _parseArrayClaims(List<dynamic> claims) {
    final result = <_ClaimDefinition>[];
    for (final claim in claims) {
      if (claim is! Map) continue;
      final map = Map<String, dynamic>.from(claim);
      final path = _pathFromClaim(map);
      if (path.isEmpty) continue;
      result.add(
        _ClaimDefinition(
          path: path,
          display: map['display'],
        ),
      );
    }
    return result;
  }

  static List<_ClaimDefinition> _parseObjectClaims(
    Map<dynamic, dynamic> claims,
  ) {
    final result = <_ClaimDefinition>[];
    for (final entry in claims.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is! Map) {
        result.add(_ClaimDefinition(path: [key]));
        continue;
      }
      final map = Map<String, dynamic>.from(value);
      final path = _pathFromClaim(map, fallbackKey: key);
      result.add(
        _ClaimDefinition(
          path: path,
          display: map['display'],
        ),
      );
    }
    return result;
  }

  static List<String> _pathFromClaim(
    Map<String, dynamic> claim, {
    String? fallbackKey,
  }) {
    final path = claim['path'];
    if (path is List && path.isNotEmpty) {
      return path.map((e) => e.toString()).toList();
    }
    if (fallbackKey != null) return [fallbackKey];
    return const [];
  }

  static String? _labelFromDisplay(
    dynamic display, {
    String? locale,
  }) {
    if (display is! List || display.isEmpty) return null;

    Map<String, dynamic>? fallback;
    for (final entry in display) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final name = map['name'] as String?;
      if (name == null || name.isEmpty) continue;

      final entryLocale = map['locale'] as String?;
      if (locale != null &&
          entryLocale != null &&
          _localeMatches(entryLocale, locale)) {
        return name;
      }
      fallback ??= map;
    }

    final name = fallback?['name'] as String?;
    return name?.isNotEmpty == true ? name : null;
  }

  static bool _localeMatches(String entryLocale, String locale) {
    final normalized = locale.toLowerCase();
    final entry = entryLocale.toLowerCase();
    return entry == normalized || entry.startsWith('$normalized-');
  }

  static dynamic _valueAtPath(Map<String, dynamic> root, List<String> path) {
    dynamic current = root;
    for (final segment in path) {
      if (current is Map) {
        current = current[segment];
      } else {
        return null;
      }
    }
    return current;
  }

  static List<LabeledClaim> _fallbackFromValues(Map<String, dynamic> values) {
    return subjectClaimsForDisplay(values)
        .entries
        .map(
          (e) => LabeledClaim(
            label: humanizeClaimKey(e.key),
            key: e.key,
            value: e.value,
          ),
        )
        .toList();
  }

  /// Claims del `credentialSubject` W3C aptos para UI (sin `id` / DID del titular).
  static Map<String, dynamic> subjectClaimsForDisplay(dynamic subject) {
    final map = _subjectAsMap(subject);
    return Map.fromEntries(
      map.entries.where((e) => e.key != 'id' && !_isEmptyValue(e.value)),
    );
  }

  static Map<String, dynamic> _subjectAsMap(dynamic subject) {
    if (subject is Map<String, dynamic>) return subject;
    if (subject is Map) return Map<String, dynamic>.from(subject);
    return const {};
  }

  static bool _isEmptyValue(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    return false;
  }

  /// Convierte `given_name` en `Given Name` para UI sin metadata.
  static String humanizeClaimKey(String key) {
    if (key.isEmpty) return key;
    return key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _ClaimDefinition {
  const _ClaimDefinition({required this.path, this.display});

  final List<String> path;
  final dynamic display;
}
