import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/kuatia_colors.dart';

/// Pestañas del navbar inferior (Inicio · QR · Menú).
enum IdentityNavTab {
  home,
  scan,
  menu,
}

/// Navbar inferior fijo de la app.
///
/// Tres ítems al mismo nivel. La pestaña [currentTab] usa el indicador circular
/// accent; el resto queda muted. Preferí [IdentityBottomNav.forTab] en pantallas.
class IdentityBottomNav extends StatelessWidget {
  const IdentityBottomNav({
    super.key,
    required this.currentTab,
    this.onHome,
    this.onMenu,
    this.onScan,
  });

  /// Construye el nav cableado a `/home`, `/home/scan` y `/home/menu`.
  factory IdentityBottomNav.forTab(
    BuildContext context,
    IdentityNavTab currentTab,
  ) {
    return IdentityBottomNav(
      currentTab: currentTab,
      onHome: () => context.go('/home'),
      onScan: () => context.go('/home/scan'),
      onMenu: () => context.go('/home/menu'),
    );
  }

  final IdentityNavTab currentTab;
  final VoidCallback? onHome;
  final VoidCallback? onMenu;
  final VoidCallback? onScan;

  static const double _barHeight = 60;
  static const double _iconSize = 24;
  static const double _selectedSlot = 50;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final colors = context.kuatia;
    final homeSelected = currentTab == IdentityNavTab.home;

    return Container(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: _barHeight,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                semanticLabel: 'Inicio',
                selected: homeSelected,
                onTap: onHome,
                iconBuilder: (color) => Icon(
                  homeSelected ? Icons.home : Icons.home_outlined,
                  size: _iconSize,
                  color: color,
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                semanticLabel: 'Escanear QR',
                selected: currentTab == IdentityNavTab.scan,
                onTap: onScan,
                iconBuilder: (color) => Image.asset(
                  'public/images/icons/QR Code.png',
                  key: const ValueKey('navScanIcon'),
                  width: _iconSize,
                  height: _iconSize,
                  color: color,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                semanticLabel: 'Menú',
                selected: currentTab == IdentityNavTab.menu,
                onTap: onMenu,
                iconBuilder: (color) => Icon(
                  Icons.menu,
                  size: _iconSize,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ítem del nav: muted o círculo accent según [selected].
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.semanticLabel,
    required this.selected,
    required this.iconBuilder,
    this.onTap,
  });

  final String semanticLabel;
  final bool selected;
  final Widget Function(Color color) iconBuilder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = selected ? colors.ink : colors.muted;
    final icon = iconBuilder(tint);

    final child = selected
        ? Container(
            width: IdentityBottomNav._selectedSlot,
            height: IdentityBottomNav._selectedSlot,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: dark ? 0.22 : 0.28),
                  offset: const Offset(0, 4),
                  blurRadius: dark ? 10 : 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: icon,
          )
        : icon;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}
