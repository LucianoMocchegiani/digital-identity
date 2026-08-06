import 'dart:convert';

import 'package:isar/isar.dart';

import 'isar/did_isar.dart';
import 'models/did_record.dart';
import 'record_service.dart';
import 'record_store.dart';

/// Implementación de [RecordService] para DIDs controlados por el wallet.
///
/// El identificador lógico del record es el DID completo (ej. `'did:key:z6Mk...'`),
/// por lo que [getById] y [delete] reciben el DID string como [id].
class DidRecordStore implements RecordService<DidRecord> {
  /// Crea el store a partir del [RecordStore] ya abierto.
  DidRecordStore(this._store);

  final RecordStore _store;

  IsarCollection<DidIsar> get _col => _store.db.didIsars;

  @override
  Future<void> save(DidRecord record) async {
    await _store.db.writeTxn(() async {
      final existing = await _col.where().didEqualTo(record.did).findFirst();
      if (existing != null) throw DuplicateRecordException(record.did);
      await _col.put(_toIsar(record));
    });
  }

  @override
  Future<void> update(DidRecord record) async {
    await _store.db.writeTxn(() async {
      final existing = await _col.where().didEqualTo(record.did).findFirst();
      if (existing == null) throw RecordNotFoundException(record.did);
      final obj = _toIsar(record);
      obj.id = existing.id;
      await _col.put(obj);
    });
  }

  @override
  Future<void> delete(String id) async {
    await _store.db.writeTxn(
      () => _col.where().didEqualTo(id).deleteFirst(),
    );
  }

  @override
  Future<DidRecord?> getById(String id) async {
    final isar = await _col.where().didEqualTo(id).findFirst();
    return isar != null ? _fromIsar(isar) : null;
  }

  @override
  Future<List<DidRecord>> getAll() async {
    final isars = await _col.where().findAll();
    return isars.map(_fromIsar).toList();
  }

  @override
  Stream<List<DidRecord>> watch() {
    return _col
        .where()
        .watch(fireImmediately: true)
        .map((isars) => isars.map(_fromIsar).toList());
  }

  DidIsar _toIsar(DidRecord record) => DidIsar()
    ..did = record.did
    ..method = record.method
    ..documentJson = jsonEncode(record.document)
    ..keyIds = record.keyIds
    ..createdAt = record.createdAt;

  DidRecord _fromIsar(DidIsar isar) => DidRecord(
        did: isar.did,
        method: isar.method,
        document: jsonDecode(isar.documentJson) as Map<String, dynamic>,
        keyIds: isar.keyIds,
        createdAt: isar.createdAt,
      );
}
