import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../core/providers/wallet_notifier.dart';
import '../../../core/wallet_state.dart';

/// Conexiones DIDComm del holder como stream reactivo ([StreamProvider]).
///
/// Mientras [walletNotifierProvider] está en carga o en error, emite un stream
/// vacío. Si la wallet no está desbloqueada, también vacío. Con [WalletUnlocked],
/// delega en [DidCommService.connections] de la sesión (lista de [ConnectionRecord]
/// actualizada desde el almacén local).
///
/// Consumido por [InboxScreen].

final inboxProvider = StreamProvider<List<ConnectionRecord>>((ref) {
  final walletState = ref.watch(walletNotifierProvider);
  return walletState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (ws) {
      if (ws is WalletUnlocked) return ws.session.didcomm.connections;
      return const Stream.empty();
    },
  );
});
