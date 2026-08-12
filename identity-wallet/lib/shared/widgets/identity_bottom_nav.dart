import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';

/// Índices de las pestañas del navbar inferior.
enum IdentityNavTab {
  /// Pestaña Inicio (vista por defecto).
  home,

  /// Pestaña Menú (hub: actividad, conexiones, ajustes, etc.).
  menu,
}

/// Navbar inferior fijo de la app (componente `Nav`).
///
/// Barra de panel Kuatia con borde superior, dos pestañas ([IdentityNavTab]) a
/// los lados (solo ícono) y un botón QR teal central que sobresale 8px. La
/// pestaña [currentTab] usa el ícono activo (acento); la otra queda atenuada.
///
/// [onHome] y [onMenu] responden al toque de cada pestaña, y
/// [onScan] al del botón QR central.
class IdentityBottomNav extends StatelessWidget {
  const IdentityBottomNav({
    super.key,
    required this.currentTab,
    this.onHome,
    this.onMenu,
    this.onScan,
    this.showClose = false,
  });

  /// Pestaña actualmente seleccionada.
  final IdentityNavTab currentTab;

  /// Callback al tocar la pestaña Inicio.
  final VoidCallback? onHome;

  /// Callback al tocar la pestaña Menú.
  final VoidCallback? onMenu;

  /// Callback al tocar el botón QR central.
  final VoidCallback? onScan;

  /// Si el botón central muestra la cruz (barra de acciones abierta) en vez del QR.
  final bool showClose;

  static const double _barHeight = 60;
  static const double _qrSize = 50;
  static const double _qrOverflow = 8;

  @override
  Widget build(BuildContext context) {
    // Espacio inferior seguro (barra de gestos / home indicator).
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final colors = context.kuatia;

    return SizedBox(
      height: _qrOverflow + _barHeight + bottomInset,
      // Clip.none permite que el botón QR sobresalga por encima de la barra.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        semanticLabel: 'Inicio',
                        selected: currentTab == IdentityNavTab.home,
                        onTap: onHome,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.menu,
                        semanticLabel: 'Menú',
                        selected: currentTab == IdentityNavTab.menu,
                        onTap: onMenu,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botón QR centrado que sobresale hacia arriba.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: _QrButton(onTap: onScan, showClose: showClose)),
          ),
        ],
      ),
    );
  }
}

/// Pestaña del navbar: solo ícono 24px (el [semanticLabel] queda para a11y).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    this.selectedIcon,
    required this.semanticLabel,
    required this.selected,
    this.onTap,
  });

  /// Ícono cuando la pestaña no está seleccionada.
  final IconData icon;

  /// Ícono cuando está seleccionada; si es null, se reutiliza [icon].
  final IconData? selectedIcon;

  final String semanticLabel;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final iconColor = selected ? colors.accent : colors.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(
            selected ? (selectedIcon ?? icon) : icon,
            size: 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Botón central (componente `QR-Container`): círculo teal de 50px con borde,
/// sombra suave y el ícono QR, o una cruz cuando [showClose] es true.
class _QrButton extends StatelessWidget {
  const _QrButton({this.onTap, this.showClose = false});

  final VoidCallback? onTap;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: showClose ? 'Cerrar' : 'Escanear QR',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: IdentityBottomNav._qrSize,
            height: IdentityBottomNav._qrSize,
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
            child: Center(
              child: Image.asset(
                showClose
                    ? 'public/images/icons/Cross.png'
                    : 'public/images/icons/QR Code.png',
                key: const ValueKey('navCenterIcon'),
                width: 24,
                height: 24,
                color: colors.ink,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
