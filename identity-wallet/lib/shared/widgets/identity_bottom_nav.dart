import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/kuatia_colors.dart';

/// Índices de las pestañas del navbar inferior.
enum IdentityNavTab {
  /// Pestaña de credenciales (vista por defecto).
  credentials,

  /// Pestaña de configuración.
  configuration,
}

/// Navbar inferior fijo de la app (componente `Nav`).
///
/// Barra de panel Kuatia con borde superior, dos pestañas ([IdentityNavTab]) a los
/// lados y un botón QR teal central que sobresale 8px hacia arriba. La
/// pestaña indicada por [currentTab] muestra su ícono en la variante activa
/// (seleccionada), con texto en negrita y opacidad completa; la otra usa la
/// variante inactiva y queda atenuada.
///
/// [onCredentials] y [onConfiguration] responden al toque de cada pestaña, y
/// [onScan] al del botón QR central.
class IdentityBottomNav extends StatelessWidget {
  const IdentityBottomNav({
    super.key,
    required this.currentTab,
    this.onCredentials,
    this.onConfiguration,
    this.onScan,
    this.showClose = false,
  });

  /// Pestaña actualmente seleccionada.
  final IdentityNavTab currentTab;

  /// Callback al tocar la pestaña Credenciales.
  final VoidCallback? onCredentials;

  /// Callback al tocar la pestaña Configuración.
  final VoidCallback? onConfiguration;

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
                        selectedIcon: 'public/images/icons/Folder.png',
                        unselectedIcon: 'public/images/icons/Folder-Open.png',
                        label: 'Credenciales',
                        selected: currentTab == IdentityNavTab.credentials,
                        onTap: onCredentials,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selectedIcon: 'public/images/icons/Settings-pulse.png',
                        unselectedIcon: 'public/images/icons/Settings.png',
                        label: 'Configuración',
                        selected: currentTab == IdentityNavTab.configuration,
                        onTap: onConfiguration,
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

/// Pestaña individual del navbar inferior (componente `Btn-Navbar`): ícono 24px
/// y label de 10px.
///
/// Según [selected] muestra el ícono [selectedIcon] (variante azul) o
/// [unselectedIcon] (variante blanca); además, seleccionada va a opacidad
/// completa y en negrita, y sin seleccionar queda levemente atenuada (0.9).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  /// Ícono cuando la pestaña está seleccionada (variante azul).
  final String selectedIcon;

  /// Ícono cuando la pestaña no está seleccionada (variante blanca).
  final String unselectedIcon;

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final iconColor = selected ? colors.accent : colors.muted;
    final labelColor = selected ? colors.text : colors.muted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            selected ? selectedIcon : unselectedIcon,
            width: 24,
            height: 24,
            color: iconColor,
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              height: 16 / 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: labelColor,
            ),
          ),
        ],
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
              color: AppColors.brandPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: context.kuatia.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.28),
                  offset: const Offset(0, 5),
                  blurRadius: 8,
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
                // Tint ink sobre teal (PNG oscuro o blanco).
                color: AppColors.inkOnAccent,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
