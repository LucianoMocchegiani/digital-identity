import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Pantalla de la pestaña **Configuración** del navbar inferior (`/home/menu`).
///
/// Agrupa las opciones en tarjetas del design system: actividad y conexiones,
/// preferencias (ajustes, acerca de) y la acción destructiva de reiniciar la
/// wallet. Mantiene el [IdentityTopBar] y el [IdentityBottomNav] fijos; [MenuScreen]
/// no contiene lógica de estado: solo navegación.
///
/// El acceso a credenciales no vive acá: la pestaña "Credenciales" del navbar
/// ya es la puerta al home.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      appBar: IdentityTopBar(
        onNotificationsPressed: () => context.push('/home/inbox'),
      ),
      bottomNavigationBar: IdentityBottomNav(
        currentTab: IdentityNavTab.configuration,
        // `go` (no `push`) alterna la pestaña sin apilar y conservando el navbar.
        onCredentials: () => context.go('/home'),
        onScan: () => context.push('/home/scan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        children: [
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.history_outlined,
                label: 'Actividad',
                onTap: () => context.push('/home/activity'),
              ),
              _MenuTile(
                icon: Icons.people_outline,
                label: 'Conexiones',
                onTap: () => context.push('/home/inbox'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.settings_outlined,
                label: 'Ajustes',
                onTap: () => context.push('/home/menu/settings'),
              ),
              _MenuTile(
                icon: Icons.info_outline,
                label: 'Acerca de',
                onTap: () => context.push('/home/menu/about'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuGroup(
            children: [
              _MenuTile(
                icon: Icons.delete_outline,
                label: 'Reiniciar wallet',
                danger: true,
                onTap: () => context.push('/home/menu/reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta que agrupa filas del menú, con divisor entre ellas.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IdentityCard(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                color: AppColors.borderNeutral,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Fila del menú: ícono, etiqueta y chevron de navegación.
///
/// [danger] tiñe ícono y texto con los tokens destructivos (reiniciar wallet).
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        danger ? AppColors.dangerIcon : AppColors.textNeutralSecondary;
    final labelColor =
        danger ? AppColors.dangerText : AppColors.textNeutralPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // Sin alto fijo: la fila crece con la fuente del sistema.
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.textNeutralSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
