import 'package:flutter/material.dart';

import '../../../shared/quark_shared.dart';
import '../../credentials/models/wallet_credential.dart';
import '../../credentials/widgets/credential_logo.dart';
import '../models/wallet_category.dart';
import 'category_creation_modal.dart';

/// Fila expandible de categoría del panel de categorías (componente `Accordion`).
///
/// **Colapsada**: badge de [category], nombre, subtítulo ("N items") y el ojo.
/// **Expandida**: muestra el nombre con acciones (editar / colapsar) y, si la
/// categoría está vacía, una ilustración con el mensaje "Esta categoría está
/// vacía". [onEdit] responde al lápiz.
///
/// El ojo es el mismo [QuarkEyeToggle] de la tarjeta de credencial, para que
/// mostrar y ocultar contenido use un único gesto en toda la app.
class CategoryAccordion extends StatefulWidget {
  const CategoryAccordion({
    super.key,
    required this.category,
    this.onEdit,
    this.onCredentialTap,
  });

  /// Categoría a representar.
  final WalletCategory category;

  /// Callback al tocar el lápiz (editar).
  final VoidCallback? onEdit;

  /// Callback al tocar una credencial de la lista (abre su detalle).
  final void Function(WalletCredential credential)? onCredentialTap;

  @override
  State<CategoryAccordion> createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<CategoryAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Material(
      color: widget.category.rowColor,
      borderRadius: radius,
      child: InkWell(
        // Colapsada: toca para expandir. Expandida: el cierre lo maneja la X.
        onTap: _expanded ? null : () => setState(() => _expanded = true),
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.borderNeutral),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded ? _buildExpanded() : _buildCollapsed(),
          ),
        ),
      ),
    );
  }

  /// Estado colapsado: badge + nombre + subtítulo + chevron.
  Widget _buildCollapsed() {
    final category = widget.category;
    return Row(
      children: [
        Image.asset(category.iconAsset, width: 35, height: 35),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.label, style: _titleStyle),
              const SizedBox(height: 2),
              Text(
                category.subtitle,
                // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
                style: const TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textNeutralSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Mismo ojo que la tarjeta de credencial: expandir y colapsar se ven
        // igual en toda la app.
        QuarkEyeToggle(
          expanded: false,
          onTap: () => setState(() => _expanded = true),
        ),
      ],
    );
  }

  /// Estado expandido: nombre + acciones (editar / cerrar) e ilustración vacía.
  Widget _buildExpanded() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Head: nombre + botones (lápiz / cerrar).
        // Sin alto fijo: se adapta al texto cuando la fuente del sistema es
        // mayor; los íconos quedan centrados respecto del título.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle,
              ),
            ),
            const SizedBox(width: 8),
            _HeadIcon(
              asset: 'public/images/icons/Pen.png',
              onTap: widget.onEdit ??
                  () => CategoryCreationModal.showEdit(
                        context,
                        category: widget.category,
                      ),
            ),
            const SizedBox(width: 8),
            QuarkEyeToggle(
              expanded: true,
              onTap: () => setState(() => _expanded = false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Con credenciales: lista de filas. Sin credenciales: estado vacío.
        if (widget.category.credentials.isEmpty)
          _buildEmptyState()
        else
          _buildCredentialList(),
      ],
    );
  }

  /// Lista de credenciales asignadas (componente `Institución-group`).
  Widget _buildCredentialList() {
    final credentials = widget.category.credentials;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < credentials.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: GestureDetector(
              onTap: () => widget.onCredentialTap?.call(credentials[i]),
              behavior: HitTestBehavior.opaque,
              child: _buildCredentialRow(credentials[i]),
            ),
          ),
      ],
    );
  }

  /// Fila de una credencial dentro del acordeón (logo + datos + flecha).
  ///
  /// Sin alto fijo: la fila se ajusta a su contenido para no desbordar cuando
  /// el sistema usa un tamaño de fuente mayor (`textScaleFactor` alto) o en
  /// pantallas de menor densidad.
  Widget _buildCredentialRow(WalletCredential credential) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CredentialLogo(
                logoUrl: credential.logoUrl,
                size: 35,
                radius: 8,
                borderColor: AppColors.borderNeutral,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      credential.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      credential.issuer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
                      style: const TextStyle(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textNeutralSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        // Chevron de detalle: mismo ícono vectorial y gris que el de la
        // categoría colapsada, para que todos los íconos queden en sintonía.
        // (El asset PNG de flecha tiene un trazo muy fino y se veía más claro
        // pese al mismo color.)
        const Icon(
          Icons.chevron_right,
          size: 24,
          color: AppColors.textNeutralSecondary,
        ),
      ],
    );
  }

  /// Estado vacío: ilustración + mensaje "Esta categoría está vacía".
  Widget _buildEmptyState() {
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
          const Text(
            'Esta categoría está vacía',
            // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textNeutralSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Todavía no hay credenciales asignadas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static const _titleStyle = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textNeutralPrimary,
  );
}

/// Ícono de acción del head (lápiz / cerrar): 24px, gris secundario.
class _HeadIcon extends StatelessWidget {
  const _HeadIcon({required this.asset, this.onTap});

  final String asset;
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
        color: AppColors.textNeutralSecondary,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
