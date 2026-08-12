import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/models/credential_ux_data.dart';
import '../../../core/providers/wallet_ux_notifier.dart';
import '../../categories/mappers/category_mapper.dart';

/// Mapa reactivo `credentialId → preferencias locales`.
///
/// Clave: [CredentialRecord.id] del SDK.
/// Valor: favorita y categorías asignadas ([CredentialUxData]).
/// Vacío si la wallet no está desbloqueada.
final credentialUxMapProvider = Provider<Map<String, CredentialUxData>>((ref) {
  final ux = ref.watch(walletUxNotifierProvider).valueOrNull;
  return ux?.credentialUx ?? const {};
});

/// Atajo a [WalletUxNotifier] para favoritas.
///
/// Ejemplo:
/// ```dart
/// await ref.read(credentialUxNotifierProvider).toggleFavorite('sd-jwt-vc-abc');
/// ```
final credentialUxNotifierProvider = Provider<WalletUxNotifier>((ref) {
  return ref.read(walletUxNotifierProvider.notifier);
});

/// Indica si la credencial [id] está marcada como favorita.
///
/// Retorna `false` si no hay datos UX o la wallet está bloqueada.
final isCredentialFavoriteProvider = Provider.family<bool, String>((ref, id) {
  final ux = ref.watch(walletUxNotifierProvider).valueOrNull;
  if (ux == null) return false;
  return CategoryMapper.isFavorite(ux, id);
});
