import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../../credentials/models/wallet_credential.dart';
import '../models/wallet_category.dart';
import 'category_accordion.dart';
import 'category_creation_modal.dart';

/// Panel desplegable de categorías (componente `Categorias-disponibles-Wrapper`).
///
/// Es un bottom sheet arrastrable: colapsado deja ver el handle y el encabezado
/// ("Categorías" + "Crear nueva"); al arrastrarlo hacia arriba se despliega y
/// muestra la lista de [categories]. [onCreate] responde al botón "Crear nueva"
/// y [onCategoryTap] al toque de una fila.
class CategoriesPanel extends StatefulWidget {
  const CategoriesPanel({
    super.key,
    this.categories = const [],
    this.onCreate,
    this.onCategoryTap,
    this.onCredentialTap,
    this.onExpandedChanged,
  });

  /// Categorías a listar.
  final List<WalletCategory> categories;

  /// Callback al tocar "Crear nueva".
  final VoidCallback? onCreate;

  /// Callback al tocar una categoría.
  final void Function(WalletCategory category)? onCategoryTap;

  /// Callback al tocar una credencial dentro de una categoría (abre su detalle).
  final void Function(WalletCredential credential)? onCredentialTap;

  /// Notifica cuando el panel pasa a expandido (true) o colapsado (false).
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<CategoriesPanel> createState() => _CategoriesPanelState();
}

class _CategoriesPanelState extends State<CategoriesPanel> {
  /// Altura visible del panel colapsado: handle + encabezado ("Categorías") +
  /// el inicio de la primera categoría hasta su título ("Identidad"), sin llegar
  /// a mostrar el subtítulo ("N items"), como en el diseño.
  static const double _peekHeight = 120;

  /// True cuando el panel está expandido (no en su posición colapsada).
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Convierte el peek en fracción del alto disponible para el sheet.
        final available = constraints.maxHeight;
        final minFraction = (_peekHeight / available).clamp(0.08, 0.6);

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            // Expandido cuando supera el mínimo (colapsado) con un margen.
            final expanded = notification.extent > notification.minExtent + 0.02;
            if (expanded != _expanded) {
              setState(() => _expanded = expanded);
              widget.onExpandedChanged?.call(expanded);
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: minFraction,
            minChildSize: minFraction,
            maxChildSize: 1,
            snap: true,
            builder: (context, scrollController) {
            // Forma con lengüeta central elevada (handle) y curvas cóncavas.
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: context.kuatia.panel,
                shape: const _CategoriesPanelShape(
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
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                children: [
                  Center(
                    child: Container(
                      width: 34,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.kuatia.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorías',
                        style: TextStyle(
                          fontSize: 16,
                          height: 22 / 16,
                          fontWeight: FontWeight.w600,
                          color: context.kuatia.text,
                        ),
                      ),
                      if (_expanded)
                        IdentityOutlineButton(
                          label: 'Crear nueva',
                          onTap: widget.onCreate ??
                              () => CategoryCreationModal.show(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final category in widget.categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CategoryAccordion(
                        category: category,
                        onCredentialTap: widget.onCredentialTap,
                      ),
                    ),
                ],
              ),
            );
          },
          ),
        );
      },
    );
  }
}

/// Forma del panel de categorías: borde superior con una **lengüeta central
/// elevada** (donde va el handle) y curvas cóncavas a cada lado (silueta `‾‾\__/‾‾`).
class _CategoriesPanelShape extends ShapeBorder {
  const _CategoriesPanelShape({
    this.outerRadius = 16,
    this.tabWidth = 150,
    this.tabHeight = 16,
    this.tabRadius = 14,
    this.joinRadius = 10,
    this.borderWidth = 1,
  });

  /// Color del borde superior cuando [borderWidth] es mayor que 0.
  static const Color _borderColor = Color(0xFFE3E3E3);

  /// Radio de las esquinas superiores externas.
  final double outerRadius;

  /// Ancho de la lengüeta central.
  final double tabWidth;

  /// Altura que la lengüeta sobresale por encima del borde lateral.
  final double tabHeight;

  /// Radio de las esquinas superiores de la lengüeta.
  final double tabRadius;

  /// Radio de las curvas cóncavas que unen la lengüeta con los lados.
  final double joinRadius;

  /// Grosor del borde (0 = sin borde).
  final double borderWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  /// Contorno superior del panel (silueta `‾‾\__/‾‾`), desde la esquina superior
  /// izquierda hasta la derecha. Es la única parte con borde visible.
  ///
  /// Si [closed] es `true` cierra el rectángulo (base inferior + lados) para
  /// usarse como relleno/recorte; si es `false` deja una polilínea abierta para
  /// dibujar solo el borde de arriba, sin línea inferior sobre el navbar.
  Path _buildPath(Rect rect, {bool closed = true}) {
    final l = rect.left, r = rect.right, b = rect.bottom, t = rect.top;
    final notch = t + tabHeight; // profundidad del notch central
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
      // esquina superior izquierda (convexa)
      ..arcToPoint(Offset(l + outerRadius, t),
          radius: Radius.circular(outerRadius))
      ..lineTo(nL - joinRadius, t)
      // hombro izquierdo: baja hacia el notch (convexa)
      ..arcToPoint(Offset(nL, t + joinRadius),
          radius: Radius.circular(joinRadius))
      ..lineTo(nL, notch - tabRadius)
      // fondo del notch, esquina izquierda (cóncava)
      ..arcToPoint(Offset(nL + tabRadius, notch),
          radius: Radius.circular(tabRadius), clockwise: false)
      ..lineTo(nR - tabRadius, notch)
      // fondo del notch, esquina derecha (cóncava)
      ..arcToPoint(Offset(nR, notch - tabRadius),
          radius: Radius.circular(tabRadius), clockwise: false)
      ..lineTo(nR, t + joinRadius)
      // hombro derecho: sube de nuevo al borde (convexa)
      ..arcToPoint(Offset(nR + joinRadius, t),
          radius: Radius.circular(joinRadius))
      ..lineTo(r - outerRadius, t)
      // esquina superior derecha (convexa)
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
    // Extiende la base muy por debajo del rect para que la sombra del
    // `BoxShadow` no se proyecte sobre el borde inferior (que al expandir el
    // panel queda sobre el navbar). La silueta superior se mantiene intacta.
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
    // Sin borde cuando borderWidth es 0: el panel queda solo con su forma blanca
    // y la lengüeta, sin contorno gris sobre el navbar.
    if (borderWidth <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = _borderColor;
    // Solo el contorno superior: evita la línea de base sobre el navbar cuando
    // el panel está expandido a pantalla completa.
    canvas.drawPath(_buildPath(rect, closed: false), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
