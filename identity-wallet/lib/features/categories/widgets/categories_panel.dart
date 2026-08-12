import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../../credentials/models/wallet_credential.dart';
import '../../credentials/widgets/credential_card.dart';
import '../models/wallet_category.dart';
import 'category_accordion.dart';
import 'category_creation_modal.dart';

/// Panel desplegable de credenciales por categoría.
///
/// Bottom sheet arrastrable: colapsado muestra handle + título "Credenciales";
/// expandido permite buscar, crear categoría y ver los contenedores con cards.
class CategoriesPanel extends StatefulWidget {
  const CategoriesPanel({
    super.key,
    this.categories = const [],
    this.onCredentialTap,
  });

  /// Categorías a listar.
  final List<WalletCategory> categories;

  /// Callback al tocar una credencial (abre su detalle).
  final void Function(WalletCredential credential)? onCredentialTap;

  @override
  State<CategoriesPanel> createState() => _CategoriesPanelState();
}

class _CategoriesPanelState extends State<CategoriesPanel> {
  /// Altura visible del panel colapsado: handle + encabezado.
  static const double _peekHeight = 120;

  bool _expanded = false;
  bool _searching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WalletCredential> get _allCredentials {
    for (final category in widget.categories) {
      if (category.isSystem) return category.credentials;
    }
    final byId = <String, WalletCredential>{};
    for (final category in widget.categories) {
      for (final credential in category.credentials) {
        final id = credential.id;
        if (id == null) continue;
        byId.putIfAbsent(id, () => credential);
      }
    }
    return byId.values.toList(growable: false);
  }

  /// Resultados de búsqueda: solo credenciales (sin contenedores de categoría).
  List<WalletCredential> get _searchResults {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _allCredentials
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.issuer.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  bool get _isSearchActive =>
      _searching && _searchQuery.trim().isNotEmpty;

  void _exitSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = false;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;
        final minFraction = (_peekHeight / available).clamp(0.08, 0.6);

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            final expanded =
                notification.extent > notification.minExtent + 0.02;
            if (expanded != _expanded) {
              setState(() {
                _expanded = expanded;
                if (!expanded) {
                  _searching = false;
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: minFraction,
            minChildSize: minFraction,
            maxChildSize: 1,
            snap: true,
            builder: (context, scrollController) {
              final colors = context.kuatia;
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: colors.panel,
                  shape: _CategoriesPanelShape(
                    borderColor: colors.border,
                    outerRadius: 16,
                    tabWidth: 150,
                    tabHeight: 18,
                    tabRadius: 8,
                    joinRadius: 8,
                    borderWidth: 1,
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 22, 14, 16),
                  children: [
                    Center(
                      child: Container(
                        width: 34,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHeader(colors),
                    const SizedBox(height: 12),
                    ..._buildBody(colors),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(KuatiaColors colors) {
    if (_isSearchActive) {
      final results = _searchResults;
      if (results.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No se encontraron credenciales.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: colors.muted,
              ),
            ),
          ),
        ];
      }
      return [
        for (var i = 0; i < results.length; i++)
          Padding(
            padding: EdgeInsets.only(
              left: 2,
              right: 2,
              bottom: i == results.length - 1 ? 0 : 12,
            ),
            child: CredentialCard(
              key: ValueKey('credential-card-${results[i].id}'),
              credential: results[i],
              onTap: () => widget.onCredentialTap?.call(results[i]),
            ),
          ),
      ];
    }

    final categories = widget.categories;
    if (categories.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Todavía no hay categorías. Creá una para organizar tus credenciales.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: colors.muted,
            ),
          ),
        ),
      ];
    }

    return [
      for (final category in categories)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CategoryAccordion(
            category: category,
            onCredentialTap: widget.onCredentialTap,
          ),
        ),
    ];
  }

  Widget _buildHeader(KuatiaColors colors) {
    if (_expanded && _searching) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'public/images/icons/lupa.png',
                    width: 18,
                    height: 18,
                    color: colors.muted,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      cursorColor: colors.accent,
                      style: TextStyle(
                        fontSize: 16,
                        height: 22 / 16,
                        color: colors.text,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Buscar credencial',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          height: 22 / 16,
                          fontWeight: FontWeight.w400,
                          color: colors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            asset: 'public/images/icons/Cross.png',
            onTap: _exitSearch,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            'Credenciales',
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
        if (_expanded) ...[
          _HeaderIconButton(
            asset: 'public/images/icons/lupa.png',
            onTap: () => setState(() => _searching = true),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: IdentityOutlineButton(
              label: 'Crear categoría',
              onTap: () => CategoryCreationModal.show(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.asset, this.onTap});

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: Image.asset(
                asset,
                width: 18,
                height: 18,
                color: colors.text,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Forma del panel de categorías: borde superior con una **lengüeta central
/// elevada** (donde va el handle) y curvas cóncavas a cada lado (silueta `‾‾\__/‾‾`).
class _CategoriesPanelShape extends ShapeBorder {
  const _CategoriesPanelShape({
    required this.borderColor,
    this.outerRadius = 16,
    this.tabWidth = 150,
    this.tabHeight = 16,
    this.tabRadius = 14,
    this.joinRadius = 10,
    this.borderWidth = 1,
  });

  final Color borderColor;
  final double outerRadius;
  final double tabWidth;
  final double tabHeight;
  final double tabRadius;
  final double joinRadius;
  final double borderWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  Path _buildPath(Rect rect, {bool closed = true}) {
    final l = rect.left, r = rect.right, b = rect.bottom, t = rect.top;
    final notch = t + tabHeight;
    final cx = rect.center.dx;
    final nL = cx - tabWidth / 2;
    final nR = cx + tabWidth / 2;

    final path = Path();
    if (closed) {
      path
        ..moveTo(l, b)
        ..lineTo(l, t + outerRadius);
    } else {
      path.moveTo(l, t + outerRadius);
    }

    path
      ..arcToPoint(Offset(l + outerRadius, t),
          radius: Radius.circular(outerRadius))
      ..lineTo(nL - joinRadius, t)
      ..arcToPoint(Offset(nL, t + joinRadius),
          radius: Radius.circular(joinRadius))
      ..lineTo(nL, notch - tabRadius)
      ..arcToPoint(Offset(nL + tabRadius, notch),
          radius: Radius.circular(tabRadius), clockwise: false)
      ..lineTo(nR - tabRadius, notch)
      ..arcToPoint(Offset(nR, notch - tabRadius),
          radius: Radius.circular(tabRadius), clockwise: false)
      ..lineTo(nR, t + joinRadius)
      ..arcToPoint(Offset(nR + joinRadius, t),
          radius: Radius.circular(joinRadius))
      ..lineTo(r - outerRadius, t)
      ..arcToPoint(Offset(r, t + outerRadius),
          radius: Radius.circular(outerRadius));

    if (closed) {
      path
        ..lineTo(r, b)
        ..close();
    }
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final extended = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom + 64,
    );
    return _buildPath(extended);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderWidth <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;
    canvas.drawPath(_buildPath(rect, closed: false), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
