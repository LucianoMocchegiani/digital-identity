import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';

/// Barra flotante de acciones sobre el panel de categorías: "Añadir" y
/// "Presentar". Aparece al tocar el botón central del navbar.
///
/// Detrás lleva un degradado del fondo del tema (transparente → panel) para
/// que las píldoras se lean sin un fulgor blanco en dark.
class HomeActionsBar extends StatefulWidget {
  const HomeActionsBar({super.key, this.onAdd, this.onPresent});

  /// Acción "Añadir" (alta de credencial por escaneo).
  final VoidCallback? onAdd;

  /// Acción "Presentar" (presentación de credencial).
  final VoidCallback? onPresent;

  @override
  State<HomeActionsBar> createState() => _HomeActionsBarState();
}

class _HomeActionsBarState extends State<HomeActionsBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_curve),
        child: Container(
          height: 100,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.bg.withValues(alpha: 0),
                colors.bg.withValues(alpha: 0.75),
                colors.panel,
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionPill(
                icon: 'public/images/icons/Plus.png',
                label: 'Añadir',
                onTap: widget.onAdd,
              ),
              const SizedBox(width: 12),
              _ActionPill(
                icon: 'public/images/icons/Screencast.png',
                label: 'Presentar',
                onTap: widget.onPresent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Píldora de acción (fondo teal Kuatia, radio 16) con ícono y texto ink.
class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.icon, required this.label, this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [kShadowXs],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 18,
              height: 18,
              color: colors.ink,
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
