import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../../credentials/models/wallet_credential.dart';
import '../../credentials/widgets/credential_card.dart';
import '../models/wallet_category.dart';
import 'category_accordion.dart';
import 'category_creation_modal.dart';

/// Pantalla de credenciales por categoría y detalle animado de cada categoría.
class CategoriesPanel extends StatefulWidget {
  const CategoriesPanel({
    super.key,
    this.categories = const [],
    this.onCredentialTap,
  });

  final List<WalletCategory> categories;
  final void Function(WalletCredential credential)? onCredentialTap;

  @override
  State<CategoriesPanel> createState() => _CategoriesPanelState();
}

class _CategoriesPanelState extends State<CategoriesPanel> {
  bool _searching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

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
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _allCredentials
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.issuer.toLowerCase().contains(q))
        .toList(growable: false);
  }

  bool get _isSearchActive => _searching && _searchQuery.trim().isNotEmpty;

  void _exitSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = false;
      _searchQuery = '';
    });
  }

  void _backToCategories() => setState(() => _selectedCategoryId = null);

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final selectedCategory = widget.categories
        .where((category) => category.id == _selectedCategoryId)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      child: Column(
        children: [
          if (selectedCategory == null)
            _buildHeader(colors)
          else
            Row(
              children: [
                IconButton(
                  tooltip: 'Volver a categorías',
                  onPressed: _backToCategories,
                  icon: Icon(Icons.arrow_back, color: colors.text),
                ),
                Expanded(
                  child: Text(
                    'Credenciales',
                    style: TextStyle(
                      fontSize: 16,
                      height: 22 / 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
              child: selectedCategory == null
                  ? _buildCategoryList(colors)
                  : _buildCategoryDetail(selectedCategory),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(KuatiaColors colors) {
    if (_isSearchActive) {
      final results = _searchResults;
      if (results.isEmpty) {
        return Center(
          key: const ValueKey('credential-search-results'),
          child: Text(
            'No se encontraron credenciales.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 20 / 14, color: colors.muted),
          ),
        );
      }
      return ListView.separated(
        key: const ValueKey('credential-search-results'),
        padding: const EdgeInsets.only(bottom: 12),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => CredentialCard(
          key: ValueKey('credential-card-${results[index].id}'),
          credential: results[index],
          onTap: () => widget.onCredentialTap?.call(results[index]),
        ),
      );
    }

    if (widget.categories.isEmpty) {
      return Center(
        key: const ValueKey('credential-categories-empty'),
        child: Text(
          'Todavía no hay categorías. Creá una para organizar tus credenciales.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 20 / 14, color: colors.muted),
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey('credential-category-list'),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: widget.categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return CategoryAccordion(
          category: category,
          onCategoryTap: () => setState(() => _selectedCategoryId = category.id),
          onCredentialTap: widget.onCredentialTap,
        );
      },
    );
  }

  Widget _buildCategoryDetail(WalletCategory category) => LayoutBuilder(
        builder: (context, constraints) => ListView(
          key: ValueKey('credential-category-${category.id}'),
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            CategoryAccordion(
              key: ValueKey('selected-category-${category.id}'),
              category: category,
              initiallyExpanded: true,
              minimumHeight: constraints.maxHeight - 12,
              onClose: _backToCategories,
              onCredentialTap: widget.onCredentialTap,
            ),
          ],
        ),
      );

  Widget _buildHeader(KuatiaColors colors) {
    if (_searching) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'public/images/icons/lupa.png',
                    width: 18,
                    height: 18,
                    color: colors.muted,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      cursorColor: colors.accent,
                      style: TextStyle(fontSize: 16, height: 22 / 16, color: colors.text),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Buscar credencial',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          height: 22 / 16,
                          fontWeight: FontWeight.w400,
                          color: colors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            asset: 'public/images/icons/Cross.png',
            tooltip: 'Cerrar búsqueda',
            onTap: _exitSearch,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            'Credenciales',
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
        _HeaderIconButton(
          asset: 'public/images/icons/lupa.png',
          tooltip: 'Buscar credencial',
          onTap: () => setState(() => _searching = true),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: IdentityOutlineButton(
            label: 'Crear categoría',
            onTap: () => CategoryCreationModal.show(context),
          ),
        ),
      ],
    );
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
      decoration: BoxDecoration(
        color: colors.panel,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Center(
              child: Tooltip(
                message: tooltip ?? '',
                child: Image.asset(
                  asset,
                  width: 18,
                  height: 18,
                  color: colors.text,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
