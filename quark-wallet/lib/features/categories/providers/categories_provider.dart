import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/models/category_data.dart';
import '../../../core/providers/wallet_ux_notifier.dart';
import '../../credentials/providers/credentials_provider.dart';
import '../mappers/category_mapper.dart';
import '../models/wallet_category.dart';

/// Lista reactiva de categorías persistidas ([CategoryData]).
///
/// Ordenadas por [CategoryData.sortOrder]. Vacía si la wallet no está
/// desbloqueada o aún no hay datos guardados.
final categoryDataListProvider = Provider<List<CategoryData>>((ref) {
  final ux = ref.watch(walletUxNotifierProvider);
  return ux.maybeWhen(
    data: (data) => [...data.categories]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    orElse: () => const [],
  );
});

/// Categorías listas para renderizar en [CategoriesPanel] y [CategoryAccordion].
///
/// Combina [walletUxNotifierProvider] con [credentialsProvider] y resuelve
/// las credenciales asignadas a cada categoría mediante [CategoryMapper].
final walletCategoriesProvider = Provider<List<WalletCategory>>((ref) {
  final ux = ref.watch(walletUxNotifierProvider).valueOrNull;
  if (ux == null) return const [];

  final credentials = ref.watch(credentialsProvider).valueOrNull ?? const [];
  return CategoryMapper.toWalletCategories(
    uxData: ux,
    credentials: credentials,
  );
});

/// Atajo a [WalletUxNotifier] para operaciones de CRUD de categorías.
///
/// Ejemplo:
/// ```dart
/// await ref.read(categoriesNotifierProvider).createCategory(
///   label: 'Identidad',
///   iconIndex: 0,
///   colorArgb: kCategoryColors[0].toARGB32(),
///   credentialIds: ['sd-jwt-vc-abc'],
/// );
/// ```
final categoriesNotifierProvider = Provider<WalletUxNotifier>((ref) {
  return ref.read(walletUxNotifierProvider.notifier);
});
