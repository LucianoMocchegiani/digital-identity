import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../theme/kuatia_colors.dart';

/// Superficie de panel Kuatia: radio 12, borde y sombra `xs`.
class IdentityCard extends StatelessWidget {
  const IdentityCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: const [kShadowXs],
      ),
      child: child,
    );
  }
}
