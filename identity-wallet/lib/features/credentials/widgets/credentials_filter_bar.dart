import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';

/// Filtros disponibles en la barra flotante de credenciales.
enum CredentialsFilter {
  /// Todas las credenciales.
  credenciales,

  /// Solo las credenciales marcadas como favoritas.
  favoritas,
}

/// Barra flotante de credenciales (componente `Tag-group`).
///
/// Tiene dos modos:
/// - **Tabs**: pill segmentado ("Credenciales" / "Favoritas") + botón de lupa.
/// - **Búsqueda**: al tocar la lupa se expande a un campo "Buscar...."; la X
///   vuelve al modo tabs.
///
/// Gestiona su estado internamente y notifica el filtro con [onSelect] y el
/// texto buscado con [onSearchChanged].
class CredentialsFilterBar extends StatefulWidget {
  const CredentialsFilterBar({
    super.key,
    this.initial = CredentialsFilter.credenciales,
    this.onSelect,
    this.onSearchChanged,
  });

  /// Filtro seleccionado inicialmente.
  final CredentialsFilter initial;

  /// Callback al cambiar de filtro.
  final ValueChanged<CredentialsFilter>? onSelect;

  /// Callback al cambiar el texto de búsqueda.
  final ValueChanged<String>? onSearchChanged;

  @override
  State<CredentialsFilterBar> createState() => _CredentialsFilterBarState();
}

class _CredentialsFilterBarState extends State<CredentialsFilterBar> {
  late CredentialsFilter _selected = widget.initial;
  final _searchController = TextEditingController();
  bool _searching = false;

  // Sombra suave compartida (drop-shadow del diseño).
  static const _shadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

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
        child: _searching ? _buildSearch() : _buildTabs(),
      ),
    );
  }

  /// Modo tabs: pill segmentado + botón de lupa.
  ///
  /// El pill se envuelve en [Flexible] y los tags pueden truncar su texto para
  /// que, en pantallas angostas o con fuente del sistema grande, el contenido
  /// se ajuste al ancho disponible en vez de desbordar la fila.
  Widget _buildTabs() {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
              boxShadow: _shadow,
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
          iconAsset: 'public/images/icons/lupa.png',
          onTap: () => setState(() => _searching = true),
        ),
      ],
    );
  }

  /// Modo búsqueda: campo "Buscar...." expandido + botón X.
  Widget _buildSearch() {
    return Row(
      key: const ValueKey('search'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ancho fijo (no se estira): conserva el tamaño compacto de la barra.
        SizedBox(
          width: 198,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.borderNeutral),
              boxShadow: _shadow,
            ),
            child: Row(
              children: [
                Image.asset(
                  'public/images/icons/lupa.png',
                  width: 18,
                  height: 18,
                  color: const Color(0xFF181D27),
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: widget.onSearchChanged,
                    cursorColor: AppColors.accentBlue,
                    // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
                    style: const TextStyle(
                      fontSize: 16,
                      height: 22 / 16,
                      color: AppColors.textNeutralPrimary,
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Buscar....',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        height: 22 / 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textNeutralSecondary,
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
          iconAsset: 'public/images/icons/Cross.png',
          onTap: _exitSearch,
        ),
      ],
    );
  }

  /// Botón circular blanco (34px) con un ícono negro centrado.
  Widget _circleButton({required String iconAsset, VoidCallback? onTap}) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: _shadow,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.borderNeutral),
        ),
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
                color: const Color(0xFF181D27),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab individual del pill segmentado (componente `Tag`).
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
    // Azul de acento al seleccionar; negro en estado normal.
    final color =
        selected ? AppColors.accentBlue : AppColors.textNeutralPrimary;
    final radius = BorderRadius.circular(16);

    return Material(
      color: selected ? AppColors.accentBlueSurface : const Color(0xFFFDFDFD),
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
                color: color,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 4),
              // Flexible + ellipsis: el label cede ancho y trunca antes de
              // desbordar la barra en pantallas angostas o con fuente grande.
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
                  style: TextStyle(
                    fontSize: 14,
                    height: 18 / 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
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
