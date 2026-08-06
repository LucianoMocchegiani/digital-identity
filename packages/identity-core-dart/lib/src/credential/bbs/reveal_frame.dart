import 'constants.dart';

/// Reveal frames y helpers de selective disclosure BBS+ (port de reveal-frame.ts).

/// Extrae paths JSONPath de los `constraints.fields` de una Presentation Definition DIF PEX.
List<String> extractRevealPathsFromPresentationDefinition(
  Map<String, dynamic> presentationDefinition,
) {
  final descriptors = presentationDefinition['input_descriptors'];
  if (descriptors is! List) return const [];

  final paths = <String>{};
  for (final desc in descriptors) {
    if (desc is! Map) continue;
    final constraints = desc['constraints'];
    if (constraints is! Map) continue;
    final fields = constraints['fields'];
    if (fields is! List) continue;
    for (final field in fields) {
      if (field is! Map) continue;
      final p = field['path'];
      if (p is String) {
        paths.add(p);
      } else if (p is List) {
        for (final item in p) {
          if (item is String) paths.add(item);
        }
      }
    }
  }
  return paths.toList(growable: false);
}

bool _isValidJsonLdType(Object? value) {
  if (value is String && value.isNotEmpty) return true;
  if (value is List && value.every((t) => t is String)) return true;
  return false;
}

/// Construye un JSON-LD frame (MATTR / BbsBlsSignatureProof2020) a partir de paths PEX.
///
/// MVP: solo paths bajo `credentialSubject` con un nivel de propiedad.
/// Siempre revela `credentialSubject.id` si existe (holder binding de la VP).
Map<String, dynamic> buildRevealFrame(
  Map<String, dynamic> credential,
  List<String> requestedPaths,
) {
  final subject = (credential['credentialSubject'] is Map)
      ? Map<String, dynamic>.from(credential['credentialSubject'] as Map)
      : <String, dynamic>{};

  final revealedSubject = <String, dynamic>{
    '@explicit': true,
  };

  final subjectId = subject['id'];
  if (subjectId is String && subjectId.isNotEmpty) {
    revealedSubject['id'] = <String, dynamic>{};
  }

  if (_isValidJsonLdType(subject['type'])) {
    revealedSubject['type'] = subject['type'];
  }

  for (final path in requestedPaths) {
    final match = RegExp(r'^\$\.credentialSubject\.([A-Za-z0-9_]+)$').firstMatch(path);
    if (match == null) continue;
    final key = match.group(1)!;
    if (key == 'id' || key == 'type') continue;
    if (subject.containsKey(key)) {
      revealedSubject[key] = <String, dynamic>{};
    }
  }

  final frame = <String, dynamic>{
    '@context': credential['@context'],
    'type': credential['type'],
    'credentialSubject': revealedSubject,
  };

  if (!_isValidJsonLdType(frame['type'])) {
    frame['type'] = ['VerifiableCredential'];
  }

  return frame;
}

/// Reescribe el PD para permitir firmar la VP con Ed25519 aunque el descriptor liste solo BBS.
Map<String, dynamic> presentationDefinitionForHolderVpSigning(
  Map<String, dynamic> presentationDefinition,
  Iterable<Map<String, dynamic>> selectedCredentials,
) {
  final hasBbs = selectedCredentials.any((vc) {
    final proof = vc['proof'];
    if (proof is! Map) return false;
    return isBbsProofType(proof['type'] as String?);
  });
  if (!hasBbs) return presentationDefinition;

  final pd = _deepCopyMap(presentationDefinition);

  List<String> mergeVpProofTypes(Object? proofTypes) {
    final next = <String>[
      if (proofTypes is List) ...proofTypes.whereType<String>(),
    ];
    for (final t in kHolderVpProofTypes) {
      if (!next.contains(t)) next.add(t);
    }
    return next;
  }

  final format = pd['format'];
  if (format is Map) {
    final formatMap = Map<String, dynamic>.from(format);
    final ldpVc = formatMap['ldp_vc'];
    if (ldpVc is Map) {
      final ldp = Map<String, dynamic>.from(ldpVc);
      ldp['proof_type'] = mergeVpProofTypes(ldp['proof_type']);
      formatMap['ldp_vc'] = ldp;
    } else {
      formatMap['ldp_vc'] = {'proof_type': List<String>.from(kHolderVpProofTypes)};
    }
    pd['format'] = formatMap;
  }

  final descriptors = pd['input_descriptors'];
  if (descriptors is List) {
    final nextDescriptors = <dynamic>[];
    for (final desc in descriptors) {
      if (desc is! Map) {
        nextDescriptors.add(desc);
        continue;
      }
      final d = Map<String, dynamic>.from(desc);
      final df = d['format'];
      if (df is Map) {
        final dfMap = Map<String, dynamic>.from(df);
        final ldpVc = dfMap['ldp_vc'];
        if (ldpVc is Map) {
          final ldp = Map<String, dynamic>.from(ldpVc);
          ldp['proof_type'] = mergeVpProofTypes(ldp['proof_type']);
          dfMap['ldp_vc'] = ldp;
        } else {
          dfMap['ldp_vc'] = {
            'proof_type': List<String>.from(kHolderVpProofTypes),
          };
        }
        d['format'] = dfMap;
      }
      nextDescriptors.add(d);
    }
    pd['input_descriptors'] = nextDescriptors;
  }

  return pd;
}

Map<String, dynamic> _deepCopyMap(Map<String, dynamic> source) {
  final out = <String, dynamic>{};
  for (final entry in source.entries) {
    final v = entry.value;
    if (v is Map) {
      out[entry.key] = _deepCopyMap(Map<String, dynamic>.from(v));
    } else if (v is List) {
      out[entry.key] = [
        for (final item in v)
          if (item is Map)
            _deepCopyMap(Map<String, dynamic>.from(item))
          else
            item,
      ];
    } else {
      out[entry.key] = v;
    }
  }
  return out;
}
