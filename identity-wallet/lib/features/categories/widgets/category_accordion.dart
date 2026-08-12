import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../../credentials/models/wallet_credential.dart';
import '../../credentials/widgets/credential_card.dart';
import '../models/wallet_category.dart';
import 'category_creation_modal.dart';
import 'category_icon.dart';

/// Contenedor expandible de categoría del panel.
///
/// Colapsada: ícono, nombre, subtítulo y ojo. Expandida: editar (si no es
/// sistema), colapsar, y las [CredentialCard] o estado vacío.
class CategoryAccordion extends StatefulWidget {
  const CategoryAccordion({
    super.key,
    required this.category,
    this.onCredentialTap,
  });

  /// Categoría a representar.
  final WalletCategory category;

  /// Callback al tocar una credencial de la lista (abre su detalle).
  final void Function(WalletCredential credential)? onCredentialTap;

  @override
  State<CategoryAccordion> createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<CategoryAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final radius = BorderRadius.circular(12);

    return Material(
      color: widget.category.rowColor,
      borderRadius: radius,
      child: InkWell(
        // Colapsada: toca para expandir. Expandida: el cierre lo maneja el ojo.
        onTap: _expanded ? null : () => setState(() => _expanded = true),
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.border),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded ? _buildExpanded(colors) : _buildCollapsed(colors),
          ),
        ),
      ),
    );
  }

  /// Estado colapsado: badge + nombre + subtítulo + ojo.
  Widget _buildCollapsed(KuatiaColors colors) {
    final category = widget.category;
    return Row(
      children: [
        CategoryIcon(
          asset: category.iconAsset,
          colorArgb: category.colorArgb,
          size: 35,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.label, style: _titleStyle(colors)),
              const SizedBox(height: 2),
              Text(
                category.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w500,
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IdentityEyeToggle(
          expanded: false,
          onTap: () => setState(() => _expanded = true),
        ),
      ],
    );
  }

  /// Estado expandido: nombre + acciones e cards / vacío.
  Widget _buildExpanded(KuatiaColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle(colors),
              ),
            ),
            const SizedBox(width: 8),
            if (!widget.category.isSystem) ...[
              _HeadIcon(
                asset: 'public/images/icons/Pen.png',
                color: colors.muted,
                onTap: () => CategoryCreationModal.showEdit(
                  context,
                  category: widget.category,
                ),
              ),
              const SizedBox(width: 8),
            ],
            IdentityEyeToggle(
              expanded: true,
              onTap: () => setState(() => _expanded = false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.category.credentials.isEmpty)
          _buildEmptyState(colors)
        else
          _buildCredentialCards(),
      ],
    );
  }

  /// Cards de credencial dentro del contenedor de categoría.
  Widget _buildCredentialCards() {
    final credentials = widget.category.credentials;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < credentials.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
            child: CredentialCard(
              credential: credentials[i],
              onTap: () => widget.onCredentialTap?.call(credentials[i]),
            ),
          ),
      ],
    );
  }

  /// Estado vacío: ilustración + mensaje.
  Widget _buildEmptyState(KuatiaColors colors) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'public/images/icons/empty-cred.png',
            width: 124.53,
            height: 74.53,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Esta categoría está vacía',
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w600,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Todavía no hay credenciales asignadas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: colors.muted,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle(KuatiaColors colors) => TextStyle(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: colors.text,
      );
}

/// Ícono de acción del head (lápiz): 24px, color del tema.
class _HeadIcon extends StatelessWidget {
  const _HeadIcon({required this.asset, required this.color, this.onTap});

  final String asset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        asset,
        width: 24,
        height: 24,
        color: color,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
