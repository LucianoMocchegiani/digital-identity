import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../providers/inbox_provider.dart';

/// Lista de conexiones DIDComm bajo `/home/inbox`.
///
/// Observa [inboxProvider] (stream de listas de [ConnectionRecord]). Estados de
/// carga y error explícitos; lista vacía con [IdentityEmptyState]. Las filas van en
/// una [IdentityCard]: cada [_ConnectionTile] muestra etiqueta, `goalCode` o estado
/// textual y un [_StateChip] teñido según [ConnectionState].
///
/// [ConnectionState] de `identity_core_dart` choca con el de Material; por eso el
/// import de Flutter usa `hide ConnectionState`.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inboxProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      appBar: IdentityPageAppBar.build(title: 'Conexiones'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (connections) {
          if (connections.isEmpty) {
            return const IdentityEmptyState(
              icon: Icons.people_outline,
              title: 'Sin conexiones aún',
              description:
                  'Acá vas a ver los emisores y verificadores con los que te '
                  'conectaste por DIDComm.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
            children: [
              IdentityCard(
                child: Column(
                  children: [
                    for (var i = 0; i < connections.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          color: AppColors.borderNeutral,
                        ),
                      _ConnectionTile(connection: connections[i]),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Fila de una conexión: avatar, nombre o DID acortado, subtítulo y chip de estado.
class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({required this.connection});

  final ConnectionRecord connection;

  @override
  Widget build(BuildContext context) {
    final name = connection.label ?? _shortenDid(connection.theirDid);
    final stateLabel = _stateLabel(connection.state);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentBlueSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 18 / 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textNeutralPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  connection.goalCode ?? stateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textNeutralSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StateChip(state: connection.state),
        ],
      ),
    );
  }

  /// Acorta un DID largo para el subtítulo cuando no hay [ConnectionRecord.label].
  String _shortenDid(String did) {
    if (did.length > 20) return '${did.substring(0, 12)}…${did.substring(did.length - 6)}';
    return did;
  }

  /// Texto en español para el estado de la conexión en el subtítulo.
  String _stateLabel(ConnectionState state) => switch (state) {
        ConnectionState.invited => 'Invitado',
        ConnectionState.requested => 'Solicitado',
        ConnectionState.responded => 'Respondido',
        ConnectionState.complete => 'Conectado',
      };
}

/// Insignia compacta con los tokens de estado (activo, pendiente, conectando).
class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final ConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (label, surface, text) = switch (state) {
      ConnectionState.complete => (
          'Activo',
          AppColors.successSurface,
          AppColors.successText,
        ),
      ConnectionState.responded => (
          'Pendiente',
          AppColors.warningSurface,
          AppColors.warningText,
        ),
      _ => (
          'Conectando',
          AppColors.borderNeutral,
          AppColors.textNeutralSecondary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }
}
