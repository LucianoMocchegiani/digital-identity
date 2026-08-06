/// Interfaz genérica de CRUD + stream reactivo para cualquier tipo de record.
///
/// Implementada por todos los stores del wallet: [CredentialRecordStore],
/// [DidRecordStore], [KeyRecordStore], [ActivityRecordStore] y
/// [DeferredCredentialRecordStore].
abstract class RecordService<T> {
  /// Persiste un nuevo [record].
  ///
  /// Si ya existe un record con el mismo ID, lanza [DuplicateRecordException].
  Future<void> save(T record);

  /// Actualiza un [record] existente.
  ///
  /// Lanza [RecordNotFoundException] si no existe un record con el mismo ID.
  Future<void> update(T record);

  /// Elimina el record con [id].
  ///
  /// No lanza error si el record no existe.
  Future<void> delete(String id);

  /// Retorna el record con [id], o `null` si no existe.
  Future<T?> getById(String id);

  /// Retorna todos los records almacenados, sin orden garantizado.
  Future<List<T>> getAll();

  /// Emite la lista completa de records cada vez que hay cambios en el store.
  ///
  /// El stream emite la lista actual al suscribirse (`fireImmediately: true`).
  Stream<List<T>> watch();
}

/// Error lanzado al intentar guardar un record con un ID que ya existe.
class DuplicateRecordException implements Exception {
  /// El ID duplicado.
  final String id;

  const DuplicateRecordException(this.id);

  @override
  String toString() => 'DuplicateRecordException: ya existe un record con id "$id"';
}

/// Error lanzado cuando se intenta actualizar o acceder a un record inexistente.
class RecordNotFoundException implements Exception {
  /// El ID del record no encontrado.
  final String id;

  const RecordNotFoundException(this.id);

  @override
  String toString() => 'RecordNotFoundException: no se encontró el record con id "$id"';
}
