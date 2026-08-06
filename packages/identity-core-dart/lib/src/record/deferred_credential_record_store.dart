import 'dart:convert';

import 'package:isar/isar.dart';

import '../crypto/wallet_crypto_context.dart';
import 'isar/deferred_credential_isar.dart';
import 'models/deferred_credential_record.dart';
import 'record_service.dart';
import 'record_store.dart';

/// Implementación de [RecordService] para credenciales diferidas pendientes.
///
/// Persiste los [DeferredCredentialRecord] necesarios para reintentar la
/// recuperación de credenciales cuyo issuer devolvió un `transaction_id`
/// en lugar de la credencial inmediata (flujo OID4VCI deferred).
///
/// Si [RecordStore.cryptoContext] está presente, [accessTokenJson] y
/// [responseJson] se persisten cifrados (`enc:v1:`). [issuerMetadataJson]
/// queda en claro (metadatos del issuer).
class DeferredCredentialRecordStore
    implements RecordService<DeferredCredentialRecord> {
  /// Crea el store a partir del [RecordStore] ya abierto.
  DeferredCredentialRecordStore(this._store);

  final RecordStore _store;

  IsarCollection<DeferredCredentialIsar> get _col =>
      _store.db.deferredCredentialIsars;

  WalletCryptoContext? get _crypto => _store.cryptoContext;

  @override
  Future<void> save(DeferredCredentialRecord record) async {
    await _store.db.writeTxn(() async {
      final existing =
          await _col.where().recordIdEqualTo(record.id).findFirst();
      if (existing != null) throw DuplicateRecordException(record.id);
      await _col.put(await _toIsar(record));
    });
  }

  @override
  Future<void> update(DeferredCredentialRecord record) async {
    await _store.db.writeTxn(() async {
      final existing =
          await _col.where().recordIdEqualTo(record.id).findFirst();
      if (existing == null) throw RecordNotFoundException(record.id);
      final obj = await _toIsar(record);
      obj.id = existing.id;
      await _col.put(obj);
    });
  }

  @override
  Future<void> delete(String id) async {
    await _store.db.writeTxn(
      () => _col.where().recordIdEqualTo(id).deleteFirst(),
    );
  }

  @override
  Future<DeferredCredentialRecord?> getById(String id) async {
    final isar = await _col.where().recordIdEqualTo(id).findFirst();
    return isar != null ? _fromIsar(isar) : null;
  }

  @override
  Future<List<DeferredCredentialRecord>> getAll() async {
    final isars = await _col.where().findAll();
    return Future.wait(isars.map(_fromIsar));
  }

  @override
  Stream<List<DeferredCredentialRecord>> watch() {
    return _col
        .where()
        .watch(fireImmediately: true)
        .asyncMap((isars) => Future.wait(isars.map(_fromIsar)));
  }

  Future<DeferredCredentialIsar> _toIsar(DeferredCredentialRecord record) async {
    final crypto = _crypto;
    final responseJson = jsonEncode(record.response);
    final accessTokenJson = jsonEncode(record.accessToken);

    return DeferredCredentialIsar()
      ..recordId = record.id
      ..createdAt = record.createdAt
      ..lastCheckedAt = record.lastCheckedAt
      ..lastErroredAt = record.lastErroredAt
      ..responseJson = crypto != null
          ? await crypto.protectFieldRequired(responseJson)
          : responseJson
      ..issuerMetadataJson = jsonEncode(record.issuerMetadata)
      ..accessTokenJson = crypto != null
          ? await crypto.protectFieldRequired(accessTokenJson)
          : accessTokenJson;
  }

  Future<DeferredCredentialRecord> _fromIsar(DeferredCredentialIsar isar) async {
    final crypto = _crypto;
    final responseJson = crypto != null
        ? await crypto.revealField(isar.responseJson) ?? isar.responseJson
        : isar.responseJson;
    final accessTokenJson = crypto != null
        ? await crypto.revealField(isar.accessTokenJson) ?? isar.accessTokenJson
        : isar.accessTokenJson;

    return DeferredCredentialRecord(
      id: isar.recordId,
      createdAt: isar.createdAt,
      lastCheckedAt: isar.lastCheckedAt,
      lastErroredAt: isar.lastErroredAt,
      response: jsonDecode(responseJson) as Map<String, dynamic>,
      issuerMetadata:
          jsonDecode(isar.issuerMetadataJson) as Map<String, dynamic>,
      accessToken: jsonDecode(accessTokenJson) as Map<String, dynamic>,
    );
  }
}
