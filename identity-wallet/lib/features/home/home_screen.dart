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
import '../credentials/providers/credentials_filter_state_provider.dart';
import '../credentials/providers/credentials_provider.dart';
import '../credentials/providers/filtered_credentials_provider.dart';
import '../credentials/widgets/credential_card.dart';
import '../credentials/widgets/credential_detail_drawer.dart';
import '../credentials/widgets/credentials_filter_bar.dart';
import '../credentials/widgets/empty_credentials_view.dart';
import 'widgets/home_actions_bar.dart';

/// Pantalla principal tras desbloquear la wallet (`/home`).
///
/// Lista unificada de credenciales con [CredentialCard], [CredentialsFilterBar]
/// y [CategoriesPanel]. Los datos vienen de [filteredWalletCredentialsProvider]
/// (SDK + favoritas/búsqueda). El detalle abre como drawer sobre el home.

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// True cuando el panel de categorías está expandido (oculta el flotante).
  bool _panelExpanded = false;

  /* TODO(animación): "epoch" que recrea el listado para re-reproducir la
     animación de entrada. Se incrementa al montar la pantalla. */
  int _animationEpoch = 0;

  @override
  void initState() {
    super.initState();
    _animationEpoch = DateTime.now().microsecondsSinceEpoch;
  }

  /// True cuando la barra flotante de acciones (Añadir/Presentar) está abierta.
  bool _actionsOpen = false;

  @override
  Widget build(BuildContext context) {
    final credentialsAsync = ref.watch(credentialsProvider);
    final filteredCredentials = ref.watch(filteredWalletCredentialsProvider);
    final categories = ref.watch(walletCategoriesProvider);
    final filterState = ref.watch(credentialsFilterStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      appBar: IdentityTopBar(
        onNotificationsPressed: () => context.push('/home/inbox'),
      ),
      bottomNavigationBar: IdentityBottomNav(
        currentTab: IdentityNavTab.credentials,
        showClose: _actionsOpen,
        onScan: () => setState(() => _actionsOpen = !_actionsOpen),
        onConfiguration: () => context.go('/home/menu'),
      ),
      body: credentialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
        data: (allCredentials) {
          return Stack(
            children: [
              _buildCredentialList(
                context,
                allCredentials: allCredentials,
                filteredCredentials: filteredCredentials,
                filterState: filterState,
              ),
              CategoriesPanel(
                categories: categories,
                onCredentialTap: (credential) => _openDetail(
                  context,
                  credential: credential,
                  allCredentials: allCredentials,
                ),
                onExpandedChanged: (expanded) =>
                    setState(() => _panelExpanded = expanded),
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: _panelExpanded,
                  child: AnimatedOpacity(
                    opacity: _panelExpanded ? 0 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: CredentialsFilterBar(
                      initial: filterState.filter,
                      onSelect: (filter) {
                        ref.read(credentialsFilterStateProvider.notifier).state =
                            filterState.copyWith(filter: filter);
                      },
                      onSearchChanged: (query) {
                        ref.read(credentialsFilterStateProvider.notifier).state =
                            filterState.copyWith(searchQuery: query);
                      },
                    ),
                  ),
                ),
              ),

              // Barra flotante de acciones (Añadir / Presentar) + velo de cierre.
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
                      // Abre la cámara: el escaneo del QR del verificador (OID4VP)
                      // dispara el flujo de presentación en Oid4VpNotificationScreen.
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
    );
  }

  Widget _buildCredentialList(
    BuildContext context, {
    required List<CredentialRecord> allCredentials,
    required List<WalletCredential> filteredCredentials,
    required CredentialsFilterState filterState,
  }) {
    if (allCredentials.isEmpty) {
      // Sin credenciales: estado vacío con acceso al escaneo (alta por QR).
      return EmptyCredentialsView(
        onAddCredential: () => context.push('/home/scan'),
      );
    }

    if (filteredCredentials.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 64, 12, 120),
        child: Center(
          child: Text(
            _emptyFilterMessage(filterState),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textNeutralSecondary,
            ),
          ),
        ),
      );
    }

    return ListView(
      // La key ligada al "epoch" recrea las cards al abrir la pantalla, para que
      // la animación de entrada (slide-up escalonado) se vuelva a reproducir.
      key: ValueKey(_animationEpoch),
      padding: const EdgeInsets.fromLTRB(12, 64, 12, 120),
      children: [
        for (var i = 0; i < filteredCredentials.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StaggeredSlideIn(
              index: i,
              child: CredentialCard(
                credential: filteredCredentials[i],
                labeledClaims: _labeledClaimsFor(
                  filteredCredentials[i],
                  allCredentials,
                ),
                onTap: () => _openDetail(
                  context,
                  credential: filteredCredentials[i],
                  allCredentials: allCredentials,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Claims etiqueta/valor para expandir la card o abrir el drawer.
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

  /// Abre el drawer de detalle de una credencial real: extrae sus claims del
  /// SDK y cablea el botón eliminar.
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

  /// Deriva claims etiquetados a partir de los [details] de una credencial
  /// sin record en el SDK (mock), para poblar el detalle.
  List<LabeledClaim> _labeledClaimsFromDetails(List<String> details) {
    final result = <LabeledClaim>[];
    for (var i = 0; i < details.length; i++) {
      final label = 'Dato ${i + 1}';
      result.add(LabeledClaim(label: label, key: label, value: details[i]));
    }
    return result;
  }

  /// Elimina la credencial [id] del SDK y limpia sus preferencias UX.
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

  String _emptyFilterMessage(CredentialsFilterState filterState) {
    if (filterState.filter == CredentialsFilter.favoritas) {
      return 'No tenés credenciales favoritas aún.';
    }
    if (filterState.searchQuery.trim().isNotEmpty) {
      return 'No se encontraron credenciales para tu búsqueda.';
    }
    return 'No hay credenciales para mostrar.';
  }
}
