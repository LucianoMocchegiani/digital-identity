import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../core/providers/wallet_notifier.dart';
import '../../core/providers/wallet_ux_notifier.dart';
import '../../core/wallet_state.dart';
import '../../shared/identity_shared.dart';
import '../categories/providers/categories_provider.dart';
import '../categories/widgets/categories_panel.dart';
import '../credentials/mappers/credential_ui_mapper.dart';
import '../credentials/models/wallet_credential.dart';
import '../credentials/providers/credentials_provider.dart';
import '../credentials/widgets/credential_detail_drawer.dart';
import 'widgets/home_actions_bar.dart';
import 'widgets/home_feed.dart';

/// Pantalla principal tras desbloquear la wallet (`/home`).
///
/// Arriba: feed de guías, novedades y eventos. Abajo: credenciales por categoría.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// True cuando la barra flotante de acciones (Añadir/Presentar) está abierta.
  bool _actionsOpen = false;

  @override
  Widget build(BuildContext context) {
    final credentialsAsync = ref.watch(credentialsProvider);
    final categories = ref.watch(walletCategoriesProvider);
    final colors = context.kuatia;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: IdentityTopBar(
        onNotificationsPressed: () => context.push('/home/inbox'),
      ),
      bottomNavigationBar: IdentityBottomNav(
        currentTab: IdentityNavTab.home,
        showClose: _actionsOpen,
        onScan: () => setState(() => _actionsOpen = !_actionsOpen),
        onMenu: () => context.go('/home/menu'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: KuatiaAtmosphere()),
          credentialsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (allCredentials) {
              return Stack(
                children: [
                  const Positioned.fill(
                    child: HomeFeed(bottomPadding: 140),
                  ),
                  CategoriesPanel(
                    categories: categories,
                    onCredentialTap: (credential) => _openDetail(
                      context,
                      credential: credential,
                      allCredentials: allCredentials,
                    ),
                  ),
                  if (_actionsOpen) ...[
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _actionsOpen = false),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: HomeActionsBar(
                        onAdd: () {
                          setState(() => _actionsOpen = false);
                          context.push('/home/scan');
                        },
                        onPresent: () {
                          setState(() => _actionsOpen = false);
                          context.push('/home/scan');
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<LabeledClaim> _labeledClaimsFor(
    WalletCredential credential,
    List<CredentialRecord> allCredentials,
  ) {
    final record =
        allCredentials.where((r) => r.id == credential.id).firstOrNull;
    if (record != null) {
      final locale = Localizations.localeOf(context).languageCode;
      return CredentialUiMapper.labeledClaimsFor(record, locale: locale);
    }
    return _labeledClaimsFromDetails(credential.details);
  }

  void _openDetail(
    BuildContext context, {
    required WalletCredential credential,
    required List<CredentialRecord> allCredentials,
  }) {
    showCredentialDetail(
      context,
      credential,
      labeledClaims: _labeledClaimsFor(credential, allCredentials),
      onDelete: credential.id == null
          ? null
          : () => _deleteCredential(credential.id!),
    );
  }

  List<LabeledClaim> _labeledClaimsFromDetails(List<String> details) {
    final result = <LabeledClaim>[];
    for (var i = 0; i < details.length; i++) {
      final label = 'Dato ${i + 1}';
      result.add(LabeledClaim(label: label, key: label, value: details[i]));
    }
    return result;
  }

  Future<void> _deleteCredential(String id) async {
    try {
      final walletState = ref.read(walletNotifierProvider).valueOrNull;
      if (walletState is! WalletUnlocked) throw const WalletLockedError();
      await walletState.session.credentialStore.delete(id);
      await ref.read(walletUxNotifierProvider.notifier).onCredentialDeleted(id);
      if (!mounted) return;
      showAppSnackBar(context, 'Credencial eliminada');
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, 'No se pudo eliminar la credencial');
    }
  }
}
