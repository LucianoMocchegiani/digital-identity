import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../../credentials/models/wallet_credential.dart';
import '../../credentials/widgets/credential_card.dart';
import '../models/wallet_category.dart';
import 'category_accordion.dart';
import 'category_creation_modal.dart';

/// Pantalla de credenciales por categoría.
class CategoriesPanel extends StatefulWidget {
  const CategoriesPanel({super.key, this.categories = const [], this.onCredentialTap});

  final List<WalletCategory> categories;
  final void Function(WalletCredential credential)? onCredentialTap;

  @override
  State<CategoriesPanel> createState() => _CategoriesPanelState();
}

class _CategoriesPanelState extends State<CategoriesPanel> {
  bool _searching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WalletCredential> get _allCredentials {
    for (final category in widget.categories) {
      if (category.isSystem) return category.credentials;
    }
    final byId = <String, WalletCredential>{};
    for (final category in widget.categories) {
      for (final credential in category.credentials) {
        final id = credential.id;
        if (id != null) byId.putIfAbsent(id, () => credential);
      }
    }
    return byId.values.toList(growable: false);
  }

  List<WalletCredential> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _allCredentials.where((credential) =>
      credential.title.toLowerCase().contains(query) ||
      credential.issuer.toLowerCase().contains(query)).toList(growable: false);
  }

  bool get _isSearchActive => _searching && _searchQuery.trim().isNotEmpty;

  void _exitSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() { _searching = false; _searchQuery = ''; });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return LayoutBuilder(builder: (context, constraints) {
      final maxCredentialsHeight = (constraints.maxHeight * .6).clamp(160.0, 420.0).toDouble();
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildHeader(colors),
            const SizedBox(height: 12),
            if (_isSearchActive)
              _buildSearchResults(colors)
            else if (widget.categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Todavía no hay categorías. Creá una para organizar tus credenciales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 20 / 14, color: colors.muted),
                ),
              )
            else
              for (var i = 0; i < widget.categories.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                CategoryAccordion(
                  category: widget.categories[i],
                  maxCredentialsHeight: maxCredentialsHeight,
                  onCredentialTap: widget.onCredentialTap,
                ),
              ],
          ]),
        ),
      );
    });
  }

  Widget _buildSearchResults(KuatiaColors colors) {
    final results = _searchResults;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text('No se encontraron credenciales.', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 20 / 14, color: colors.muted)),
      );
    }
    return Column(children: [
      for (var i = 0; i < results.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        CredentialCard(
          key: ValueKey('credential-card-${results[i].id}'),
          credential: results[i],
          onTap: () => widget.onCredentialTap?.call(results[i]),
        ),
      ],
    ]);
  }

  Widget _buildHeader(KuatiaColors colors) {
    if (_searching) {
      return Row(children: [
        Expanded(child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(99),
            border: Border.all(color: colors.border)),
          child: Row(children: [
            Image.asset('public/images/icons/lupa.png', width: 18, height: 18,
              color: colors.muted, colorBlendMode: BlendMode.srcIn),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _searchQuery = value),
              cursorColor: colors.accent,
              style: TextStyle(fontSize: 16, height: 22 / 16, color: colors.text),
              decoration: InputDecoration(isCollapsed: true, border: InputBorder.none,
                hintText: 'Buscar credencial',
                hintStyle: TextStyle(fontSize: 16, height: 22 / 16,
                  fontWeight: FontWeight.w400, color: colors.muted)),
            )),
          ]),
        )),
        const SizedBox(width: 8),
        _HeaderIconButton(asset: 'public/images/icons/Cross.png', tooltip: 'Cerrar búsqueda', onTap: _exitSearch),
      ]);
    }
    return Row(children: [
      Expanded(child: Text('Credenciales', style: TextStyle(fontSize: 16, height: 22 / 16,
        fontWeight: FontWeight.w600, color: colors.text))),
      _HeaderIconButton(asset: 'public/images/icons/lupa.png', tooltip: 'Buscar credencial',
        onTap: () => setState(() => _searching = true)),
      const SizedBox(width: 8),
      Flexible(child: IdentityOutlineButton(label: 'Crear categoría',
        onTap: () => CategoryCreationModal.show(context))),
    ]);
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.asset, this.tooltip, this.onTap});
  final String asset;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.panel, shape: BoxShape.circle,
        border: Border.all(color: colors.border)),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: SizedBox(width: 38, height: 38,
          child: Center(child: Tooltip(message: tooltip ?? '', child: Image.asset(asset,
            width: 18, height: 18, color: colors.text, colorBlendMode: BlendMode.srcIn))))),
      ),
    );
  }
}
