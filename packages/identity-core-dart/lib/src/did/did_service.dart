import '../kms/kms_service.dart';
import '../record/did_record_store.dart';
import '../record/key_record_store.dart';
import '../record/models/did_record.dart';
import '../record/models/key_record.dart';
import 'did_jwk.dart';
import 'did_key.dart';
import 'did_resolver.dart';

/// Resultado de [DidService.getSigningDid]: DID y keyId listos para firmar.
typedef SigningDidInfo = ({String did, String keyId, String verificationMethodId});

/// Fachada de alto nivel para operaciones con DIDs.
///
/// Orquesta la creación, almacenamiento y resolución de DIDs locales,
/// asociando cada DID con su clave criptográfica en el [KeyRecordStore].
class DidService {
  DidService({
    required KmsService kms,
    required KeyRecordStore keyStore,
    required DidRecordStore didStore,
    required DidResolver resolver,
  })  : _kms = kms,
        _keyStore = keyStore,
        _didStore = didStore,
        _resolver = resolver;

  final KmsService _kms;
  final KeyRecordStore _keyStore;
  final DidRecordStore _didStore;
  final DidResolver _resolver;

  /// Retorna un DID existente del [method] dado con una clave de [keyType], o
  /// crea uno nuevo si todavía no existe.
  ///
  /// [method] debe ser `'key'` o `'jwk'`.
  Future<String> ensureDid({
    required KeyType keyType,
    required String method,
  }) async {
    final existing = await _findExistingDid(keyType: keyType, method: method);
    if (existing != null) return existing;

    return _createDid(keyType: keyType, method: method);
  }

  /// Retorna el DID y la clave para firmar en flujos OID4VC.
  ///
  /// Prefiere `did:jwk` para P-256 y `did:key` para Ed25519.
  /// Crea el DID si no existe.
  Future<SigningDidInfo> getSigningDid(KeyType keyType) async {
    final preferredMethod = keyType == KeyType.p256 ? 'jwk' : 'key';
    final did = await ensureDid(keyType: keyType, method: preferredMethod);

    final allDids = await _didStore.getAll();
    final didRecord = allDids.firstWhere((d) => d.did == did);
    final vmId = _extractFirstVmId(didRecord.document);

    return (did: did, keyId: didRecord.keyIds.first, verificationMethodId: vmId);
  }

  /// Resuelve [did] a su DID Document usando el resolvedor universal.
  Future<Map<String, dynamic>?> resolve(String did) => _resolver.resolve(did);

  // — helpers privados —

  Future<String?> _findExistingDid({
    required KeyType keyType,
    required String method,
  }) async {
    final allKeys = await _keyStore.getAll();
    final matchingKeyIds = allKeys
        .where((k) => k.keyType == keyType)
        .map((k) => k.keyId)
        .toSet();

    if (matchingKeyIds.isEmpty) return null;

    final allDids = await _didStore.getAll();
    for (final didRecord in allDids) {
      if (didRecord.method != method) continue;
      if (didRecord.keyIds.any(matchingKeyIds.contains)) {
        return didRecord.did;
      }
    }

    return null;
  }

  Future<String> _createDid({
    required KeyType keyType,
    required String method,
  }) async {
    final keyRecord = await _kms.generateKey(keyType);
    await _keyStore.save(keyRecord);

    final did = switch (method) {
      'key' => DidKey.fromPublicJwk(keyRecord.publicJwk),
      'jwk' => DidJwk.fromPublicJwk(keyRecord.publicJwk),
      _ => throw UnsupportedError('Método DID no soportado: $method'),
    };

    final document = switch (method) {
      'key' => DidKey.resolve(did),
      'jwk' => DidJwk.resolve(did),
      _ => throw UnsupportedError('Método DID no soportado: $method'),
    };

    await _didStore.save(
      DidRecord(
        did: did,
        method: method,
        document: document,
        keyIds: [keyRecord.keyId],
        createdAt: DateTime.now().toUtc(),
      ),
    );

    return did;
  }

  /// Extrae el `id` del primer verification method del DID Document.
  String _extractFirstVmId(Map<String, dynamic> document) {
    final vms = document['verificationMethod'] as List<dynamic>?;
    if (vms == null || vms.isEmpty) return '';
    return (vms.first as Map<String, dynamic>)['id'] as String? ?? '';
  }
}
