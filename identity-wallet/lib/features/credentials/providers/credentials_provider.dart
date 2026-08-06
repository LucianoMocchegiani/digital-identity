import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../core/providers/wallet_notifier.dart';
import '../../../core/wallet_state.dart';

/// Credenciales del holder como stream reactivo ([StreamProvider]).
///
/// Mientras [walletNotifierProvider] está en carga o en error, emite un stream
/// vacío. Si la wallet no está desbloqueada, también vacío. Con [WalletUnlocked],
/// delega en [CredentialRecordStore.watch] de la sesión para listar [CredentialRecord]
/// actualizados en tiempo real.
///
/// Consumido por [HomeScreen] y por el drawer de detalle de credencial.

final credentialsProvider = StreamProvider<List<CredentialRecord>>((ref) {
  final walletState = ref.watch(walletNotifierProvider);
  return walletState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (ws) {
      if (ws is WalletUnlocked) return ws.session.credentialStore.watch();
      return const Stream.empty();
    },
  );
});
