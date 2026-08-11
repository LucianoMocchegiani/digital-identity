import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'concentric_rings.dart';

/// Color de marca del punto activo del spinner (teal Kuatia).
const _spinnerActive = Color(0xFF00A89D);

/// Color de los puntos inactivos del spinner.
const _spinnerIdle = Color(0xFFD9D9D9);

/// Devuelve el color del punto [dotIndex] cuando el activo es [activeIndex].
///
/// El punto activo se pinta en teal de marca; el resto en gris. Función pura
/// para poder testear la rotación del color sin instanciar widgets.
Color spinnerDotColor(int dotIndex, int activeIndex) =>
    dotIndex == activeIndex ? _spinnerActive : _spinnerIdle;

/// Spinner de 8 puntos radiales: el punto teal avanza en sentido horario.
///
/// Los puntos se dibujan en código (no se usa el PNG) para poder animar cuál
/// está activo. Respeta reduce-motion: con animaciones deshabilitadas queda
/// estático en el primer punto.
class SpinnerDots extends StatefulWidget {
  const SpinnerDots({super.key, this.size = 48});

  /// Lado de la caja cuadrada del spinner.
  final double size;

  @override
  State<SpinnerDots> createState() => _SpinnerDotsState();
}

class _SpinnerDotsState extends State<SpinnerDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Cantidad de puntos del spinner.
  static const _dotCount = 8;

  @override
  void initState() {
    super.initState();
    // Una vuelta completa (8 pasos) por segundo aprox.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final active =
              reduceMotion ? 0 : (_controller.value * _dotCount).floor() % _dotCount;
          return CustomPaint(
            painter: _SpinnerPainter(activeIndex: active, dotCount: _dotCount),
          );
        },
      ),
    );
  }
}

/// Pinta los 8 puntos radiales (4×12, radio completo) alrededor del centro.
class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.activeIndex, required this.dotCount});

  final int activeIndex;
  final int dotCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Radio al centro del punto: deja el punto (12px de largo) dentro de la caja.
    final radius = size.width / 2 - 6;

    for (var i = 0; i < dotCount; i++) {
      // Empieza arriba (12 en punto) y avanza en sentido horario.
      final angle = (i / dotCount) * 2 * math.pi - math.pi / 2;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.save();
      canvas.translate(dotCenter.dx, dotCenter.dy);
      canvas.rotate(angle + math.pi / 2);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 4, height: 12),
        const Radius.circular(900),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = spinnerDotColor(i, activeIndex),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.activeIndex != activeIndex;
}

/// Overlay de carga: velo oscuro + tarjeta con spinner morado y anillos concéntricos.
///
/// Se superpone al slide de confirmación (que queda atenuado detrás). Reutilizado
/// en OID4VCI (emisión) y OID4VP (envío de presentación).
class CredentialLoadingOverlay extends StatelessWidget {
  const CredentialLoadingOverlay({
    super.key,
    this.title = 'Cargando credencial...',
    this.description = 'Aguarde unos instantes. Estamos verificando los datos.',
  });

  /// Título del overlay.
  final String title;

  /// Texto descriptivo bajo el título.
  final String description;

  @override
  Widget build(BuildContext context) {
    // Material transparente: el overlay se apila como hermano del slide (fuera
    // de todo Scaffold), sin esto los textos heredan el estilo fallback de
    // Flutter (subrayado doble amarillo).
    return Material(
      type: MaterialType.transparency,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 297,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Stack(
            children: [
              ...concentricRings(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SpinnerDots(size: 48),
                  ),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            height: 22 / 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNeutralPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 18 / 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textNeutralSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
