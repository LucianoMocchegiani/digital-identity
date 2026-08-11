import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Pestaña Configuración del navbar.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KuatiaScaffold(
      appBar: IdentityTopBar(
        onNotificationsPressed: () => context.push('/home/inbox'),
      ),
      bottomNavigationBar: IdentityBottomNav(
        currentTab: IdentityNavTab.configuration,
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

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return IdentityCard(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                color: colors.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

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
    final colors = context.kuatia;
    final iconColor = danger ? colors.dangerIcon : colors.muted;
    final labelColor = danger ? colors.dangerText : colors.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
              Icon(Icons.chevron_right, size: 24, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
