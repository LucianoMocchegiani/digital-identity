import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Índices de las pestañas del navbar inferior.
enum QuarkNavTab {
  /// Pestaña de credenciales (vista por defecto).
  credentials,

  /// Pestaña de configuración.
  configuration,
}

/// Navbar inferior fijo de la app (componente `Nav`).
///
/// Barra blanca de 60px con borde superior, dos pestañas ([QuarkNavTab]) a los
/// lados y un botón QR morado central que sobresale 8px hacia arriba. La
/// pestaña indicada por [currentTab] muestra su ícono en la variante azul
/// (seleccionada), con texto en negrita y opacidad completa; la otra usa la
/// variante blanca y queda atenuada.
///
/// [onCredentials] y [onConfiguration] responden al toque de cada pestaña, y
/// [onScan] al del botón QR central.
class QuarkBottomNav extends StatelessWidget {
  const QuarkBottomNav({
    super.key,
    required this.currentTab,
    this.onCredentials,
    this.onConfiguration,
    this.onScan,
    this.showClose = false,
  });

  /// Pestaña actualmente seleccionada.
  final QuarkNavTab currentTab;

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

    return SizedBox(
      height: _qrOverflow + _barHeight + bottomInset,
      // Clip.none permite que el botón QR sobresalga por encima de la barra.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra anclada al fondo con padding seguro inferior.
          // Sin borde superior: el diseño (Figma) no lleva línea sobre el navbar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                        selected: currentTab == QuarkNavTab.credentials,
                        onTap: onCredentials,
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        selectedIcon: 'public/images/icons/Settings-pulse.png',
                        unselectedIcon: 'public/images/icons/Settings.png',
                        label: 'Configuración',
                        selected: currentTab == QuarkNavTab.configuration,
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
    return InkWell(
      onTap: onTap,
      child: Opacity(
        // Estado inactivo levemente atenuado (0.9) para mejor contraste.
        opacity: selected ? 1 : 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              selected ? selectedIcon : unselectedIcon,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
              style: TextStyle(
                fontSize: 10,
                height: 16 / 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textNeutralPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón central (componente `QR-Container`): círculo morado de 50px con borde,
/// sombra suave y el ícono QR en blanco, o una cruz cuando [showClose] es true.
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
            width: QuarkBottomNav._qrSize,
            height: QuarkBottomNav._qrSize,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderNeutral),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(191, 144, 255, 0.2),
                  offset: Offset(0, 5),
                  blurRadius: 5,
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
                // La cruz se tiñe de blanco para contrastar sobre el morado
                // (el PNG viene oscuro); el QR ya viene en blanco.
                color: showClose ? Colors.white : null,
                colorBlendMode: showClose ? BlendMode.srcIn : BlendMode.srcOver,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
