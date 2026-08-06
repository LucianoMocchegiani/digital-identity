import 'dart:convert';

import 'package:isar/isar.dart';

import 'isar/connection_record_isar.dart';
import 'models/connection_record.dart';
import 'record_store.dart';

/// Store de persistencia para conexiones DIDComm.
class ConnectionRecordStore {
  ConnectionRecordStore(this._store);

  final RecordStore _store;

  IsarCollection<ConnectionRecordIsar> get _col =>
      _store.db.connectionRecordIsars;

  Future<ConnectionRecord?> getById(String connectionId) async {
    final isar =
        await _col.where().connectionIdEqualTo(connectionId).findFirst();
    return isar == null ? null : _toDomain(isar);
  }

  Future<List<ConnectionRecord>> getAll() async {
    final records = await _col.where().findAll();
    return records.map(_toDomain).toList();
  }

  Future<void> save(ConnectionRecord record) async {
    await _store.db.writeTxn(() async {
      await _col.put(_toIsar(record));
    });
  }

  Future<void> delete(String connectionId) async {
    await _store.db.writeTxn(() async {
      await _col.where().connectionIdEqualTo(connectionId).deleteAll();
    });
  }

  Stream<List<ConnectionRecord>> watchAll() {
    return _col
        .where()
        .watch(fireImmediately: true)
        .map((records) => records.map(_toDomain).toList());
  }

  // — mapeo —

  ConnectionRecord _toDomain(ConnectionRecordIsar isar) {
    return ConnectionRecord(
      connectionId: isar.connectionId,
      myDid: isar.myDid,
      theirDid: isar.theirDid,
      state: ConnectionState.values[isar.stateIndex],
      createdAt: isar.createdAt,
      label: isar.label,
      goalCode: isar.goalCode,
      theirDidDoc: isar.theirDidDocJson != null
          ? jsonDecode(isar.theirDidDocJson!) as Map<String, dynamic>
          : null,
    );
  }

  ConnectionRecordIsar _toIsar(ConnectionRecord record) {
    return ConnectionRecordIsar()
      ..connectionId = record.connectionId
      ..myDid = record.myDid
      ..theirDid = record.theirDid
      ..stateIndex = record.state.index
      ..createdAt = record.createdAt
      ..label = record.label
      ..goalCode = record.goalCode
      ..theirDidDocJson =
          record.theirDidDoc != null ? jsonEncode(record.theirDidDoc) : null;
  }
}
