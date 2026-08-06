import 'dart:typed_data';

import '../../utils/base64_utils.dart';
import '../../utils/multibase.dart';

/// Extrae la clave Ed25519 del emisor (formato `did:key`) desde un DID Document.
///
/// Tras `didexchange/response`, Credo crea un `did:peer` nuevo y asocia la
/// conexión a ese DID. Los mensajes posteriores (p. ej. `complete`) deben
/// cifrarse con las claves del documento de respuesta, no las de la invitación.
abstract final class DidDocRecipientKey {
  /// Retorna `did:key:z…` para la clave de firma Ed25519 del DID remoto.
  static String? extractEd25519KeyDid(Map<String, dynamic> didDoc) {
    final fromService = _fromServiceRecipientKeys(didDoc);
    if (fromService != null) return fromService;

    final authentication = didDoc['authentication'] as List?;
    if (authentication != null) {
      for (final entry in authentication) {
        final didKey = _verificationEntryToDidKey(didDoc, entry);
        if (didKey != null) return didKey;
      }
    }

    final verificationMethod = didDoc['verificationMethod'] as List?;
    if (verificationMethod != null) {
      for (final vm in verificationMethod) {
        if (vm is! Map<String, dynamic>) continue;
        final didKey = _verificationMethodToDidKey(vm);
        if (didKey != null) return didKey;
      }
    }

    return null;
  }

  static String? _fromServiceRecipientKeys(Map<String, dynamic> didDoc) {
    final services = didDoc['service'] as List?;
    if (services == null || services.isEmpty) return null;

    for (final service in services) {
      if (service is! Map<String, dynamic>) continue;
      final recipientKeys = service['recipientKeys'] as List?;
      if (recipientKeys == null || recipientKeys.isEmpty) continue;

      for (final keyRef in recipientKeys) {
        if (keyRef is! String) continue;
        final didKey = _verificationEntryToDidKey(didDoc, keyRef);
        if (didKey != null) return didKey;
      }
    }
    return null;
  }

  static String? _verificationEntryToDidKey(
    Map<String, dynamic> didDoc,
    Object? entry,
  ) {
    if (entry is String) {
      if (entry.startsWith('did:key:')) return entry;
      return _verificationMethodToDidKey(_resolveVmRef(didDoc, entry));
    }
    if (entry is Map<String, dynamic>) {
      return _verificationMethodToDidKey(entry);
    }
    return null;
  }

  static Map<String, dynamic>? _resolveVmRef(
    Map<String, dynamic> didDoc,
    String ref,
  ) {
    if (ref.startsWith('did:key:')) {
      return {'type': 'Ed25519VerificationKey2018', 'id': ref};
    }

    final didId = didDoc['id'] as String?;
    final vmId = ref.startsWith('#') && didId != null ? '$didId$ref' : ref;

    final verificationMethod = didDoc['verificationMethod'] as List?;
    if (verificationMethod != null) {
      for (final vm in verificationMethod) {
        if (vm is Map<String, dynamic> && vm['id'] == vmId) return vm;
      }
    }

    final authentication = didDoc['authentication'] as List?;
    if (authentication != null) {
      for (final entry in authentication) {
        if (entry is Map<String, dynamic> && entry['id'] == vmId) return entry;
      }
    }

    return null;
  }

  static String? _verificationMethodToDidKey(Map<String, dynamic>? vm) {
    if (vm == null) return null;

    final publicKeyJwk = vm['publicKeyJwk'] as Map<String, dynamic>?;
    if (publicKeyJwk != null && publicKeyJwk['crv'] == 'Ed25519') {
      final x = publicKeyJwk['x'] as String?;
      if (x != null) {
        return _didKeyFromRawEd25519(Uint8List.fromList(base64UrlDecode(x)));
      }
    }

    final publicKeyBase58 = vm['publicKeyBase58'] as String?;
    if (publicKeyBase58 != null) {
      try {
        return _didKeyFromRawEd25519(decodeBase58Btc(publicKeyBase58));
      } catch (_) {}
    }

    return null;
  }

  static String _didKeyFromRawEd25519(Uint8List rawKey) {
    final multicodec = Uint8List.fromList([0xed, 0x01, ...rawKey]);
    return 'did:key:z${encodeBase58Btc(multicodec)}';
  }
}
