import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../core/providers/wallet_ux_notifier.dart';
import '../../categories/mappers/category_mapper.dart';
import '../mappers/credential_ui_mapper.dart';
import '../models/wallet_credential.dart';
import '../widgets/credentials_filter_bar.dart';
import 'credentials_filter_state_provider.dart';
import 'credentials_provider.dart';

/// Credenciales del SDK filtradas por pestaña y búsqueda.
///
/// Combina tres fuentes:
/// - [credentialsProvider]: lista real emitida por [CredentialRecordStore]
/// - [credentialsFilterStateProvider]: pestaña (todas / favoritas) y query
/// - [walletUxNotifierProvider]: estado de favoritas en el JSON local
///
/// La búsqueda matchea título y emisor (case-insensitive) vía [CredentialUiMapper].
final filteredCredentialRecordsProvider =
    Provider<List<CredentialRecord>>((ref) {
  final credentials = ref.watch(credentialsProvider).valueOrNull ?? const [];
  final filterState = ref.watch(credentialsFilterStateProvider);
  final ux = ref.watch(walletUxNotifierProvider).valueOrNull;

  var result = credentials;

  if (filterState.filter == CredentialsFilter.favoritas) {
    result = result
        .where(
          (record) => ux != null && CategoryMapper.isFavorite(ux, record.id),
        )
        .toList(growable: false);
  }

  final query = filterState.searchQuery.trim().toLowerCase();
  if (query.isNotEmpty) {
    result = result
        .where((record) {
          final title = CredentialUiMapper.credentialTitle(record).toLowerCase();
          final issuer =
              CredentialUiMapper.credentialIssuer(record)?.toLowerCase() ?? '';
          return title.contains(query) || issuer.contains(query);
        })
        .toList(growable: false);
  }

  return result;
});

/// Credenciales filtradas como [WalletCredential] listas para [CredentialCard].
///
/// Derivado de [filteredCredentialRecordsProvider]; usar en [HomeScreen]
/// cuando se cablee la UI del listado principal.
final filteredWalletCredentialsProvider = Provider<List<WalletCredential>>((ref) {
  final records = ref.watch(filteredCredentialRecordsProvider);
  return records.map(CredentialUiMapper.toWalletCredential).toList(growable: false);
});
