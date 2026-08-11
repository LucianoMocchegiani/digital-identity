import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';

enum CredentialsFilter {
  credenciales,
  favoritas,
}

/// Barra flotante de filtros (tabs + búsqueda).
class CredentialsFilterBar extends StatefulWidget {
  const CredentialsFilterBar({
    super.key,
    this.initial = CredentialsFilter.credenciales,
    this.onSelect,
    this.onSearchChanged,
  });

  final CredentialsFilter initial;
  final ValueChanged<CredentialsFilter>? onSelect;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<CredentialsFilterBar> createState() => _CredentialsFilterBarState();
}

class _CredentialsFilterBarState extends State<CredentialsFilterBar> {
  late CredentialsFilter _selected = widget.initial;
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _select(CredentialsFilter filter) {
    if (filter == _selected) return;
    setState(() => _selected = filter);
    widget.onSelect?.call(filter);
  }

  void _exitSearch() {
    _searchController.clear();
    widget.onSearchChanged?.call('');
    FocusScope.of(context).unfocus();
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _searching ? _buildSearch(context) : _buildTabs(context),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final colors = context.kuatia;
    return Row(
      key: const ValueKey('tabs'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            height: 38,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: _Tag(
                    iconAsset: 'public/images/icons/credenciales.png',
                    label: 'Credenciales',
                    selected: _selected == CredentialsFilter.credenciales,
                    onTap: () => _select(CredentialsFilter.credenciales),
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: _Tag(
                    iconAsset: 'public/images/icons/favoritos.png',
                    label: 'Favoritas',
                    selected: _selected == CredentialsFilter.favoritas,
                    onTap: () => _select(CredentialsFilter.favoritas),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _circleButton(
          context,
          iconAsset: 'public/images/icons/lupa.png',
          onTap: () => setState(() => _searching = true),
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    final colors = context.kuatia;
    return Row(
      key: const ValueKey('search'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 198,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: colors.panel,
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
                    onChanged: widget.onSearchChanged,
                    cursorColor: colors.accent,
                    style: TextStyle(
                      fontSize: 16,
                      height: 22 / 16,
                      color: colors.text,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Buscar....',
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
        const SizedBox(width: 10),
        _circleButton(
          context,
          iconAsset: 'public/images/icons/Cross.png',
          onTap: _exitSearch,
        ),
      ],
    );
  }

  Widget _circleButton(
    BuildContext context, {
    required String iconAsset,
    VoidCallback? onTap,
  }) {
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
            width: 34,
            height: 34,
            child: Center(
              child: Image.asset(
                iconAsset,
                width: 18,
                height: 18,
                color: colors.text,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.iconAsset,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final fg = selected ? colors.accent : colors.muted;
    final bg = selected ? colors.accentSurface : Colors.transparent;
    final radius = BorderRadius.circular(16);

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconAsset,
                width: 16,
                height: 16,
                color: fg,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 18 / 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
