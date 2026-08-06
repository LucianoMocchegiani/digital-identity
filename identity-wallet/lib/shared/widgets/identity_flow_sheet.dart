import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Aloja un sheet anclado abajo sobre un velo oscuro (patrón de flujos).
class FlowSheetScaffold extends StatelessWidget {
  const FlowSheetScaffold({super.key, required this.sheet});

  /// Sheet a mostrar (típicamente un [IdentityFlowSheet]).
  final Widget sheet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: Align(alignment: Alignment.bottomCenter, child: sheet),
    );
  }
}

/// Bottom sheet estándar de flujos (Añadir, Presentar): sube desde abajo
/// (slide-up) y el contenido hace un fade-in escalonado. Muestra handle de
/// arrastre, título alineado a la izquierda, [children] scrolleables y una
/// barra fija con botones secundario (outline) y primario (morado).
///
/// [onPrimary] en `null` deshabilita el botón primario (gris, sin acción).
class IdentityFlowSheet extends StatefulWidget {
  const IdentityFlowSheet({
    super.key,
    required this.title,
    required this.children,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    this.onPrimary,
  });

  /// Título del sheet (pregunta o nombre del paso).
  final String title;

  /// Ítems del contenido; cada uno entra con el fade-in escalonado.
  final List<Widget> children;

  /// Etiqueta del botón secundario (ej. "Cancelar", "Rechazar").
  final String secondaryLabel;

  /// Acción del botón secundario.
  final VoidCallback onSecondary;

  /// Etiqueta del botón primario (ej. "Continuar", "Compartir", "Agregar").
  final String primaryLabel;

  /// Acción del botón primario; `null` lo deshabilita.
  final VoidCallback? onPrimary;

  @override
  State<IdentityFlowSheet> createState() => _IdentityFlowSheetState();
}

class _IdentityFlowSheetState extends State<IdentityFlowSheet>
    with TickerProviderStateMixin {
  /// Controla la subida del sheet (slide-up).
  late final AnimationController _sheetController;

  /// Controla el fade-in escalonado del contenido, tras subir el sheet.
  late final AnimationController _contentController;

  /// Marca que las animaciones ya se iniciaron (didChangeDependencies
  /// puede invocarse varias veces).
  bool _started = false;

  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // El contenido aparece de a poco recién cuando el sheet terminó de subir.
    _sheetController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _contentController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // Con reduce-motion activo se saltean las animaciones. Asignar
    // `_sheetController.value = 1.0` SÍ dispara el status listener (que
    // llama `_contentController.forward()`), pero la línea siguiente pisa
    // ese forward y fija el contenido directamente en su valor final.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _sheetController.value = 1.0;
      _contentController.value = 1.0;
    } else {
      _sheetController.forward();
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Fade-in con leve desplazamiento vertical para el ítem [index],
  /// escalonado a lo largo de [_contentController].
  Widget _staggered(int index, int total, Widget child) {
    final start = (index / (total + 2)).clamp(0.0, 1.0);
    final end = ((index + 2) / (total + 2)).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: _contentController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.children.length;

    return SlideTransition(
      position: _slide,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textNeutralPrimary,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < total; i++)
                        _staggered(i, total, widget.children[i]),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                secondaryLabel: widget.secondaryLabel,
                onSecondary: widget.onSecondary,
                primaryLabel: widget.primaryLabel,
                onPrimary: widget.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de arrastre del sheet (34×6, negro al 7%).
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 34,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Barra inferior fija con los botones secundario (outline) y primario (morado).
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderNeutral)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SheetButton(
              label: secondaryLabel,
              onTap: onSecondary,
              filled: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SheetButton(
              label: primaryLabel,
              onTap: onPrimary,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón del sheet (radio 16, alto mínimo 34): morado relleno o blanco con
/// borde. Con [onTap] en `null` (solo variante rellena) se pinta gris y no
/// responde al tap.
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 34),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.borderNeutral
              : (filled ? AppColors.brandPrimary : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: AppColors.borderNeutral),
          boxShadow: const [kShadowXs],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 18 / 14,
            fontWeight: FontWeight.w600,
            color: disabled
                ? AppColors.textNeutralMuted
                : (filled ? AppColors.textOnDark : AppColors.textNeutralPrimary),
          ),
        ),
      ),
    );
  }
}

/// Fila de un campo del sheet: etiqueta atenuada arriba y valor abajo.
/// Si [value] está vacío se omite la línea de valor (claims sin dato).
/// Con [verified] muestra el badge "Verificado" (check azul + texto azul).
class SheetFieldRow extends StatelessWidget {
  const SheetFieldRow({
    super.key,
    required this.label,
    required this.value,
    this.verified = false,
  });

  /// Etiqueta legible del campo (ej. "Nombre").
  final String label;

  /// Valor a mostrar; vacío para omitir la línea.
  final String value;

  /// Si muestra el badge "Verificado" bajo el valor.
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textNeutralSecondary,
            ),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                height: 18 / 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textNeutralPrimary,
              ),
            ),
          ],
          if (verified) ...[
            const SizedBox(height: 6),
            const _VerifiedBadge(),
          ],
        ],
      ),
    );
  }
}

/// Badge "Verificado": check azul + texto azul de enlace.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'public/images/icons/Badge-wrapper.png',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        const Text(
          'Verificado',
          style: TextStyle(
            fontSize: 14,
            height: 18 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.linkBlue,
          ),
        ),
      ],
    );
  }
}
