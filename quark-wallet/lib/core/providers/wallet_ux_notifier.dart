import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/categories/constants/category_catalog.dart';
import '../persistence/models/category_data.dart';
import '../persistence/models/credential_ux_data.dart';
import '../persistence/models/wallet_ux_data.dart';
import '../persistence/wallet_ux_repository.dart';
import '../wallet_state.dart';
import 'wallet_notifier.dart';
import 'wallet_storage_paths_provider.dart';

final _idRandom = Random.secure();

/// Genera un identificador único para una categoría nueva.
String _newCategoryId() {
  final suffix =
      List.generate(8, (_) => _idRandom.nextInt(16).toRadixString(16)).join();
  return '${DateTime.now().microsecondsSinceEpoch}-$suffix';
}

/// Notifier central de preferencias locales del wallet.
///
/// Gestiona categorías, credenciales favoritas y asignación credencial ↔ categoría.
/// Los datos viven en `{walletId}_ux.json` (ver [WalletUxRepository]) y son
/// independientes del almacenamiento SSI de `identity_core_dart`.
///
/// **Ciclo de vida**
/// - Con [WalletUnlocked]: carga el JSON y expone [WalletUxData] reactivo.
/// - Con [WalletLocked] o [WalletNotConfigured]: retorna [WalletUxData.empty]
///   y desactiva persistencia hasta el próximo desbloqueo.
/// - Al bloquear/desbloquear invalida su estado automáticamente.
///
/// **Consumo recomendado**
/// - Lectura: [categoryDataListProvider], [walletCategoriesProvider],
///   [credentialUxMapProvider], [filteredCredentialRecordsProvider].
/// - Escritura: métodos públicos de esta clase vía
///   [walletUxNotifierProvider.notifier] o los atajos
///   [categoriesNotifierProvider] / [credentialUxNotifierProvider].
class WalletUxNotifier extends AsyncNotifier<WalletUxData> {
  WalletUxRepository? _repository;

  @override
  Future<WalletUxData> build() async {
    ref.listen<AsyncValue<WalletState>>(walletNotifierProvider, (previous, next) {
      final wasUnlocked = previous?.valueOrNull is WalletUnlocked;
      final isUnlocked = next.valueOrNull is WalletUnlocked;
      if (wasUnlocked != isUnlocked) {
        ref.invalidateSelf();
      }
    });

    final walletState = ref.watch(walletNotifierProvider).valueOrNull;
    if (walletState is! WalletUnlocked) {
      _repository = null;
      return WalletUxData.empty;
    }

    final paths = await ref.watch(walletStoragePathsProvider.future);
    _repository = WalletUxRepository(paths);

    final loaded = await _repository!.load();
    return _seedDefaultsIfNeeded(loaded);
  }

  /// Siembra las categorías por defecto la primera vez (ej. "Identidad").
  ///
  /// Solo actúa si [WalletUxData.seededDefaults] es `false`, de modo que un
  /// default borrado por el usuario no reaparezca. Persiste el resultado.
  Future<WalletUxData> _seedDefaultsIfNeeded(WalletUxData data) async {
    if (data.seededDefaults) return data;

    final identidad = CategoryData(
      id: _newCategoryId(),
      label: 'Identidad',
      iconIndex: kIdentityIconIndex,
      colorArgb: kCategoryColors[0].toARGB32(),
      sortOrder: data.categories.length,
      createdAt: DateTime.now().toUtc(),
    );

    final seeded = data.copyWith(
      categories: [...data.categories, identidad],
      seededDefaults: true,
    );

    await _repository?.save(seeded);
    return seeded;
  }

  /// Actualiza el estado en memoria y persiste en disco.
  Future<void> _persist(WalletUxData data) async {
    final repo = _repository;
    if (repo == null) return;
    state = AsyncData(data);
    await repo.save(data);
  }

  WalletUxData get _current => state.requireValue;

  // — Categorías —

  /// Crea una categoría y sincroniza la membresía de credenciales.
  ///
  /// [label] se recorta de espacios. [iconIndex] y [colorArgb] referencian el
  /// catálogo visual de [kCategoryIconAssets] y [kCategoryColors].
  /// [credentialIds] debe contener IDs de [CredentialRecord] existentes en el SDK.
  ///
  /// Retorna la [CategoryData] creada con su [CategoryData.id] generado.
  Future<CategoryData> createCategory({
    required String label,
    required int iconIndex,
    required int colorArgb,
    List<String> credentialIds = const [],
  }) async {
    final category = CategoryData(
      id: _newCategoryId(),
      label: label.trim(),
      iconIndex: iconIndex,
      colorArgb: colorArgb,
      sortOrder: _current.categories.length,
      createdAt: DateTime.now().toUtc(),
    );

    var next = _current.copyWith(
      categories: [..._current.categories, category],
    );
    next = _syncCategoryMembership(
      data: next,
      categoryId: category.id,
      credentialIds: credentialIds.toSet(),
    );

    await _persist(next);
    return category;
  }

  /// Actualiza metadatos y reemplaza el conjunto de credenciales de una categoría.
  ///
  /// [credentialIds] es el estado final deseado: credenciales que dejaron de
  /// pertenecer se desvinculan; las nuevas se agregan en `credentialUx`.
  Future<void> updateCategory({
    required String id,
    required String label,
    required int iconIndex,
    required int colorArgb,
    required Set<String> credentialIds,
  }) async {
    final categories = _current.categories.map((category) {
      if (category.id != id) return category;
      return category.copyWith(
        label: label.trim(),
        iconIndex: iconIndex,
        colorArgb: colorArgb,
      );
    }).toList();

    var next = _current.copyWith(categories: categories);
    next = _syncCategoryMembership(
      data: next,
      categoryId: id,
      credentialIds: credentialIds,
    );

    await _persist(next);
  }

  /// Elimina una categoría y quita su ID de todas las asignaciones.
  Future<void> deleteCategory(String id) async {
    final categories =
        _current.categories.where((c) => c.id != id).toList(growable: false);

    final credentialUx = _removeCategoryFromCredentialUx(
      _current.credentialUx,
      categoryId: id,
    );

    await _persist(
      _current.copyWith(
        categories: categories,
        credentialUx: credentialUx,
      ),
    );
  }

  /// Retorna los IDs de credenciales asignadas a [categoryId].
  ///
  /// Útil para precargar el modal de edición de categoría.
  Set<String> credentialIdsForCategory(String categoryId) {
    return _current.credentialUx.entries
        .where((entry) => entry.value.categoryIds.contains(categoryId))
        .map((entry) => entry.key)
        .toSet();
  }

  // — Favoritas y asignación directa —

  /// Alterna si [credentialId] es favorita.
  Future<void> toggleFavorite(String credentialId) async {
    final ux = _uxFor(credentialId);
    await _setUx(
      credentialId,
      ux.copyWith(isFavorite: !ux.isFavorite),
    );
  }

  /// Establece explícitamente si [credentialId] es favorita.
  ///
  /// No hace nada si el valor ya coincide (evita escrituras innecesarias).
  Future<void> setFavorite(String credentialId, bool isFavorite) async {
    final ux = _uxFor(credentialId);
    if (ux.isFavorite == isFavorite) return;
    await _setUx(credentialId, ux.copyWith(isFavorite: isFavorite));
  }

  /// Reemplaza por completo las categorías de [credentialId].
  Future<void> assignCategories(
    String credentialId,
    List<String> categoryIds,
  ) async {
    final normalized = categoryIds.toSet().toList(growable: false);
    final ux = _uxFor(credentialId);
    await _setUx(credentialId, ux.copyWith(categoryIds: normalized));
  }

  /// Agrega [credentialId] a [categoryId] sin duplicar.
  Future<void> addToCategory(String credentialId, String categoryId) async {
    final ux = _uxFor(credentialId);
    if (ux.categoryIds.contains(categoryId)) return;
    await _setUx(
      credentialId,
      ux.copyWith(categoryIds: [...ux.categoryIds, categoryId]),
    );
  }

  /// Quita [credentialId] de [categoryId].
  Future<void> removeFromCategory(String credentialId, String categoryId) async {
    final ux = _uxFor(credentialId);
    if (!ux.categoryIds.contains(categoryId)) return;
    await _setUx(
      credentialId,
      ux.copyWith(
        categoryIds:
            ux.categoryIds.where((id) => id != categoryId).toList(growable: false),
      ),
    );
  }

  /// Elimina la entrada UX tras borrar una credencial del SDK.
  ///
  /// Invocado desde el drawer de detalle ([showCredentialDetail]) tras
  /// [CredentialRecordStore.delete] para evitar referencias huérfanas.
  Future<void> onCredentialDeleted(String credentialId) async {
    if (!_current.credentialUx.containsKey(credentialId)) return;
    final credentialUx = Map<String, CredentialUxData>.from(_current.credentialUx)
      ..remove(credentialId);
    await _persist(_current.copyWith(credentialUx: credentialUx));
  }

  /// Elimina entradas UX cuyos IDs ya no existen en [CredentialRecordStore].
  ///
  /// [validCredentialIds] debe ser el conjunto actual de `CredentialRecord.id`
  /// emitido por [credentialsProvider].
  Future<void> purgeOrphanCredentials(Set<String> validCredentialIds) async {
    final credentialUx = Map<String, CredentialUxData>.from(_current.credentialUx)
      ..removeWhere((id, _) => !validCredentialIds.contains(id));

    if (credentialUx.length == _current.credentialUx.length) return;
    await _persist(_current.copyWith(credentialUx: credentialUx));
  }

  // — helpers —

  CredentialUxData _uxFor(String credentialId) {
    return _current.credentialUx[credentialId] ?? const CredentialUxData();
  }

  /// Guarda o elimina la entrada según si quedó vacía (sin favorita ni categorías).
  Future<void> _setUx(String credentialId, CredentialUxData ux) async {
    final credentialUx = Map<String, CredentialUxData>.from(_current.credentialUx);

    final isEmpty = !ux.isFavorite && ux.categoryIds.isEmpty;
    if (isEmpty) {
      credentialUx.remove(credentialId);
    } else {
      credentialUx[credentialId] = ux;
    }

    await _persist(_current.copyWith(credentialUx: credentialUx));
  }

  /// Sincroniza `credentialUx` con el conjunto final de [credentialIds] de una categoría.
  WalletUxData _syncCategoryMembership({
    required WalletUxData data,
    required String categoryId,
    required Set<String> credentialIds,
  }) {
    final credentialUx = Map<String, CredentialUxData>.from(data.credentialUx);

    for (final entry in credentialUx.entries.toList()) {
      final hasCategory = entry.value.categoryIds.contains(categoryId);
      final shouldHave = credentialIds.contains(entry.key);

      if (hasCategory && !shouldHave) {
        final nextIds = entry.value.categoryIds
            .where((id) => id != categoryId)
            .toList(growable: false);
        _upsertCredentialUx(credentialUx, entry.key, entry.value, nextIds);
      }
    }

    for (final credentialId in credentialIds) {
      final current = credentialUx[credentialId] ?? const CredentialUxData();
      if (current.categoryIds.contains(categoryId)) continue;
      _upsertCredentialUx(
        credentialUx,
        credentialId,
        current,
        [...current.categoryIds, categoryId],
      );
    }

    return data.copyWith(credentialUx: credentialUx);
  }

  void _upsertCredentialUx(
    Map<String, CredentialUxData> credentialUx,
    String credentialId,
    CredentialUxData current,
    List<String> categoryIds,
  ) {
    final next = current.copyWith(categoryIds: categoryIds);
    final isEmpty = !next.isFavorite && next.categoryIds.isEmpty;
    if (isEmpty) {
      credentialUx.remove(credentialId);
    } else {
      credentialUx[credentialId] = next;
    }
  }

  Map<String, CredentialUxData> _removeCategoryFromCredentialUx(
    Map<String, CredentialUxData> credentialUx, {
    required String categoryId,
  }) {
    final next = <String, CredentialUxData>{};
    for (final entry in credentialUx.entries) {
      final ids = entry.value.categoryIds
          .where((id) => id != categoryId)
          .toList(growable: false);
      final updated = entry.value.copyWith(categoryIds: ids);
      if (!updated.isFavorite && updated.categoryIds.isEmpty) continue;
      next[entry.key] = updated;
    }
    return next;
  }
}

/// Provider principal de preferencias locales del wallet.
///
/// Expone [WalletUxData] y el notifier [WalletUxNotifier] para mutaciones.
final walletUxNotifierProvider =
    AsyncNotifierProvider<WalletUxNotifier, WalletUxData>(WalletUxNotifier.new);
