import 'dart:convert';

import 'package:isar/isar.dart';

import '../crypto/wallet_crypto_context.dart';
import 'isar/key_record_isar.dart';
import 'models/key_record.dart';
import 'record_service.dart';
import 'record_store.dart';

/// Implementación de [RecordService] para pares de claves criptográficas.
///
/// El identificador lógico del record es [KeyRecord.keyId] (UUID v4).
/// Las claves hardware-backed tienen [privateJwk] nulo; el campo
/// [isHardwareBacked] distingue ambos casos.
///
/// Si [RecordStore.cryptoContext] está presente, [privateJwkJson] se persiste
/// cifrado con AES-256-GCM (`enc:v1:`).
class KeyRecordStore implements RecordService<KeyRecord> {
  /// Crea el store a partir del [RecordStore] ya abierto.
  KeyRecordStore(this._store);

  final RecordStore _store;

  IsarCollection<KeyRecordIsar> get _col => _store.db.keyRecordIsars;

  WalletCryptoContext? get _crypto => _store.cryptoContext;

  @override
  Future<void> save(KeyRecord record) async {
    await _store.db.writeTxn(() async {
      final existing =
          await _col.where().keyIdEqualTo(record.keyId).findFirst();
      if (existing != null) throw DuplicateRecordException(record.keyId);
      await _col.put(await _toIsar(record));
    });
  }

  @override
  Future<void> update(KeyRecord record) async {
    await _store.db.writeTxn(() async {
      final existing =
          await _col.where().keyIdEqualTo(record.keyId).findFirst();
      if (existing == null) throw RecordNotFoundException(record.keyId);
      final obj = await _toIsar(record);
      obj.id = existing.id;
      await _col.put(obj);
    });
  }

  @override
  Future<void> delete(String id) async {
    await _store.db.writeTxn(
      () => _col.where().keyIdEqualTo(id).deleteFirst(),
    );
  }

  @override
  Future<KeyRecord?> getById(String id) async {
    final isar = await _col.where().keyIdEqualTo(id).findFirst();
    return isar != null ? _fromIsar(isar) : null;
  }

  @override
  Future<List<KeyRecord>> getAll() async {
    final isars = await _col.where().findAll();
    return Future.wait(isars.map(_fromIsar));
  }

  @override
  Stream<List<KeyRecord>> watch() {
    return _col
        .where()
        .watch(fireImmediately: true)
        .asyncMap((isars) => Future.wait(isars.map(_fromIsar)));
  }

  Future<KeyRecordIsar> _toIsar(KeyRecord record) async {
    final privateJwkPlain = record.privateJwk != null
        ? jsonEncode(record.privateJwk)
        : null;
    final crypto = _crypto;

    return KeyRecordIsar()
      ..keyId = record.keyId
      ..keyTypeIndex = record.keyType.index
      ..publicJwkJson = jsonEncode(record.publicJwk)
      ..privateJwkJson = crypto != null
          ? await crypto.protectField(privateJwkPlain)
          : privateJwkPlain
      ..isHardwareBacked = record.isHardwareBacked
      ..createdAt = record.createdAt
      ..did = record.did;
  }

  Future<KeyRecord> _fromIsar(KeyRecordIsar isar) async {
    final crypto = _crypto;
    final privateJwkJson = crypto != null
        ? await crypto.revealField(isar.privateJwkJson)
        : isar.privateJwkJson;

    return KeyRecord(
      keyId: isar.keyId,
      keyType: KeyType.values[isar.keyTypeIndex],
      publicJwk: jsonDecode(isar.publicJwkJson) as Map<String, dynamic>,
      privateJwk: privateJwkJson != null
          ? jsonDecode(privateJwkJson) as Map<String, dynamic>
          : null,
      isHardwareBacked: isar.isHardwareBacked,
      createdAt: isar.createdAt,
      did: isar.did,
    );
  }
}
