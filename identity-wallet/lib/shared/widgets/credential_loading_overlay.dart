import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';
import 'concentric_rings.dart';

/// Color de marca del punto activo del spinner (teal Kuatia).
const _spinnerActive = Color(0xFF00A89D);

/// Devuelve el color del punto [dotIndex] cuando el activo es [activeIndex].
Color spinnerDotColor(int dotIndex, int activeIndex, {Color? idle}) =>
    dotIndex == activeIndex ? _spinnerActive : (idle ?? const Color(0xFFD9D9D9));

/// Spinner de 8 puntos radiales: el punto teal avanza en sentido horario.
class SpinnerDots extends StatefulWidget {
  const SpinnerDots({super.key, this.size = 48});

  final double size;

  @override
  State<SpinnerDots> createState() => _SpinnerDotsState();
}

class _SpinnerDotsState extends State<SpinnerDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _dotCount = 8;

  @override
  void initState() {
    super.initState();
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
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final idle = context.kuatia.border.withValues(alpha: 1);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final active = reduceMotion
              ? 0
              : (_controller.value * _dotCount).floor() % _dotCount;
          return CustomPaint(
            painter: _SpinnerPainter(
              activeIndex: active,
              dotCount: _dotCount,
              idleColor: idle,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({
    required this.activeIndex,
    required this.dotCount,
    required this.idleColor,
  });

  final int activeIndex;
  final int dotCount;
  final Color idleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;

    for (var i = 0; i < dotCount; i++) {
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
        Paint()..color = spinnerDotColor(i, activeIndex, idle: idleColor),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.activeIndex != activeIndex ||
      oldDelegate.idleColor != idleColor;
}

/// Overlay de carga: velo + tarjeta con spinner (OID4VCI / OID4VP).
class CredentialLoadingOverlay extends StatelessWidget {
  const CredentialLoadingOverlay({
    super.key,
    this.title = 'Cargando credencial...',
    this.description = 'Aguarde unos instantes. Estamos verificando los datos.',
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.kuatia;
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 297,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Stack(
            children: [
              ...concentricRings(color: colors.border),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SpinnerDots(size: 48),
                  ),
                  Container(
                    color: colors.panel,
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
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 18 / 14,
                            fontWeight: FontWeight.w400,
                            color: colors.muted,
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
