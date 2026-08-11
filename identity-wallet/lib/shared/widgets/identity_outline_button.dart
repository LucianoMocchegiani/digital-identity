import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';

/// Botón outline Kuatia: panel + borde + texto del tema (light/dark).
class IdentityOutlineButton extends StatelessWidget {
  const IdentityOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final radius = BorderRadius.circular(expand ? 16 : 8);

    return Material(
      color: colors.panel,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: expand ? double.infinity : null,
          constraints: expand ? const BoxConstraints(minHeight: 46) : null,
          padding: expand
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: expand ? Alignment.center : null,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.text),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
