import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/credentials_filter_bar.dart';

/// Estado del filtro de credenciales en el home.
///
/// Agrupa la pestaña activa ([CredentialsFilter]) y el texto de búsqueda.
/// Pensado para ser actualizado por [CredentialsFilterBar] en la fase de
/// conexión UI; por ahora solo lo consumen los providers derivados de filtrado.
class CredentialsFilterState {
  const CredentialsFilterState({
    this.filter = CredentialsFilter.credenciales,
    this.searchQuery = '',
  });

  /// Pestaña seleccionada: todas las credenciales o solo las favoritas.
  final CredentialsFilter filter;

  /// Texto ingresado en el campo de búsqueda (case-insensitive al filtrar).
  final String searchQuery;

  /// Devuelve una copia con [filter] y/o [searchQuery] reemplazados.
  CredentialsFilterState copyWith({
    CredentialsFilter? filter,
    String? searchQuery,
  }) {
    return CredentialsFilterState(
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Provider del filtro activo en home.
///
/// Actualizar con:
/// ```dart
/// ref.read(credentialsFilterStateProvider.notifier).state =
///     const CredentialsFilterState(filter: CredentialsFilter.favoritas);
/// ```
final credentialsFilterStateProvider =
    StateProvider<CredentialsFilterState>((ref) {
  return const CredentialsFilterState();
});
