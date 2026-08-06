import 'dart:convert';
import 'dart:typed_data';

import '../../utils/multibase.dart';
import 'constants.dart';

/// Extrae la clave pública BLS12-381 G2 (96 bytes) del DID Document del issuer.
Uint8List extractBbsPublicKeyBytes({
  required Map<String, dynamic> issuerDidDocument,
  required String verificationMethodUrl,
}) {
  final vm = findDidVerificationMethod(
    issuerDidDocument,
    verificationMethodUrl,
  );
  if (vm == null) {
    throw StateError('verificationMethod no encontrada: $verificationMethodUrl');
  }

  final base58 = vm['publicKeyBase58'] as String?;
  if (base58 != null && base58.isNotEmpty) {
    final bytes = decodeBase58Btc(base58);
    if (bytes.length != 96) {
      throw StateError('publicKeyBase58 BLS G2 debe ser 96 bytes, got ${bytes.length}');
    }
    return bytes;
  }

  final jwk = vm['publicKeyJwk'];
  if (jwk is Map && jwk['x'] is String) {
    // JWK OKP / BLS: x is base64url of G2 point (MATTR).
    final x = base64Url.normalize(jwk['x'] as String);
    final bytes = base64Url.decode(x);
    if (bytes.length != 96) {
      throw StateError('publicKeyJwk.x BLS G2 debe ser 96 bytes, got ${bytes.length}');
    }
    return Uint8List.fromList(bytes);
  }

  throw StateError(
    'VM BBS sin publicKeyBase58 ni publicKeyJwk.x '
    '(type=${vm['type']})',
  );
}

/// Busca una verification method en el DID Document (por id absoluto o fragmento).
Map<String, dynamic>? findDidVerificationMethod(
  Map<String, dynamic> didDocument,
  String vmUrl,
) {
  final fragment = vmUrl.contains('#') ? '#${vmUrl.split('#').last}' : vmUrl;
  final bag = <Map<String, dynamic>>[];
  for (final key in [
    'verificationMethod',
    'assertionMethod',
    'authentication',
    'capabilityInvocation',
    'capabilityDelegation',
  ]) {
    final arr = didDocument[key];
    if (arr is! List) continue;
    for (final item in arr) {
      if (item is Map) bag.add(Map<String, dynamic>.from(item));
    }
  }
  for (final item in bag) {
    final id = '${item['id'] ?? ''}';
    if (id == vmUrl ||
        id == fragment ||
        vmUrl.endsWith(id) ||
        id.endsWith(fragment)) {
      return item;
    }
  }
  return null;
}

/// Decodifica `proof.proofValue` base64 de una VC `BbsBlsSignature2020`.
Uint8List decodeBbsProofValue(Map<String, dynamic> proof) {
  final type = proof['type'] as String?;
  if (type != kBbsProofType && type != kBbsProofTypeDerived) {
    throw ArgumentError('proof.type inesperado: $type');
  }
  final value = proof['proofValue'] as String?;
  if (value == null || value.isEmpty) {
    throw ArgumentError('proof.proofValue ausente');
  }
  return Uint8List.fromList(base64.decode(value));
}
