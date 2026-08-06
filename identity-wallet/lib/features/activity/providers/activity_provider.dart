import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../core/providers/wallet_notifier.dart';
import '../../../core/wallet_state.dart';

/// Actividad del holder como stream reactivo ([StreamProvider]).
///
/// Mientras [walletNotifierProvider] está cargando o en error, emite un stream
/// vacío. Si la wallet no está desbloqueada, también vacío. Con [WalletUnlocked],
/// delega en [ActivityRecordStore.watch] de la sesión para listar [Activity]
/// actualizadas en tiempo real.

final activityProvider = StreamProvider<List<Activity>>((ref) {
  final walletState = ref.watch(walletNotifierProvider);
  return walletState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (ws) {
      if (ws is WalletUnlocked) return ws.session.activityStore.watch();
      return const Stream.empty();
    },
  );
});
