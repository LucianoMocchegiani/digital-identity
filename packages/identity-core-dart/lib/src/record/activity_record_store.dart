import 'package:isar/isar.dart';

import 'isar/activity_isar.dart';
import 'models/activity.dart';
import 'record_service.dart';
import 'record_store.dart';

/// Implementación de [RecordService] para el historial de actividad del wallet.
///
/// Almacena tanto [IssuanceActivity] como [PresentationActivity] en la misma
/// colección de isar, discriminadas por el campo `type` del schema.
class ActivityRecordStore implements RecordService<Activity> {
  /// Crea el store a partir del [RecordStore] ya abierto.
  ActivityRecordStore(this._store);

  final RecordStore _store;

  IsarCollection<ActivityIsar> get _col => _store.db.activityIsars;

  @override
  Future<void> save(Activity record) async {
    await _store.db.writeTxn(() async {
      final existing =
          await _col.where().recordIdEqualTo(record.id).findFirst();
      if (existing != null) throw DuplicateRecordException(record.id);
      await _col.put(_toIsar(record));
    });
  }

  @override
  Future<void> update(Activity record) async {
    await _store.db.writeTxn(() async {
      final existing =
          await _col.where().recordIdEqualTo(record.id).findFirst();
      if (existing == null) throw RecordNotFoundException(record.id);
      final obj = _toIsar(record);
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
  Future<Activity?> getById(String id) async {
    final isar = await _col.where().recordIdEqualTo(id).findFirst();
    return isar != null ? _fromIsar(isar) : null;
  }

  @override
  Future<List<Activity>> getAll() async {
    final isars = await _col.where().findAll();
    return isars.map(_fromIsar).toList();
  }

  @override
  Stream<List<Activity>> watch() {
    return _col
        .where()
        .watch(fireImmediately: true)
        .map((isars) => isars.map(_fromIsar).toList());
  }

  ActivityIsar _toIsar(Activity activity) {
    final isar = ActivityIsar()
      ..recordId = activity.id
      ..date = activity.date
      ..status = activity.status.name
      ..entityId = activity.entity.id
      ..entityHost = activity.entity.host
      ..entityName = activity.entity.name;

    switch (activity) {
      case IssuanceActivity():
        isar
          ..type = 'issuance'
          ..credentialIds = activity.credentialIds;
      case PresentationActivity():
        isar
          ..type = 'presentation'
          ..requestName = activity.request.name
          ..requestPurpose = activity.request.purpose
          ..presentedCredentialIds = activity.request.credentialIds;
    }

    return isar;
  }

  Activity _fromIsar(ActivityIsar isar) {
    final status = ActivityStatus.values.byName(isar.status);
    final entity = ActivityEntity(
      id: isar.entityId,
      host: isar.entityHost,
      name: isar.entityName,
    );

    if (isar.type == 'issuance') {
      return IssuanceActivity(
        id: isar.recordId,
        date: isar.date,
        status: status,
        entity: entity,
        credentialIds: isar.credentialIds ?? [],
      );
    }

    return PresentationActivity(
      id: isar.recordId,
      date: isar.date,
      entity: entity,
      request: PresentationRequest(
        status: status,
        credentialIds: isar.presentedCredentialIds ?? [],
        name: isar.requestName,
        purpose: isar.requestPurpose,
      ),
    );
  }
}
