import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';

/// Fondo atmosférico Kuatia (glow + grilla + líneas), alineado a web `Atmosphere`.
class KuatiaAtmosphere extends StatelessWidget {
  const KuatiaAtmosphere({super.key, this.soft = true});

  /// Menos intensidad (pantallas densas).
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final c = context.kuatia;
    final glow = c.accent.withValues(alpha: soft ? 0.12 : 0.22);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.bg, c.atmosphereMid, c.bg],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.85),
                radius: 1.1,
                colors: [glow, Colors.transparent],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, -0.6),
                radius: 0.9,
                colors: [
                  c.accent.withValues(alpha: soft ? 0.06 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: _DotGridPainter(
              color: c.accent.withValues(alpha: soft ? 0.08 : 0.12),
            ),
          ),
          CustomPaint(
            painter: _WatermarkLinesPainter(
              color: c.accent.withValues(alpha: soft ? 0.14 : 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scaffold con atmósfera Kuatia detrás del body.
class KuatiaScaffold extends StatelessWidget {
  const KuatiaScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final bg = context.kuatia.bg;
    return Scaffold(
      backgroundColor: bg,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: KuatiaAtmosphere()),
          if (body != null) body!,
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 22.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _WatermarkLinesPainter extends CustomPainter {
  _WatermarkLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    Path line(List<Offset> pts) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      line([
        Offset(-0.05 * w, 0.18 * h),
        Offset(0.35 * w, 0.06 * h),
        Offset(0.65 * w, 0.26 * h),
        Offset(1.12 * w, -0.03 * h),
      ]),
      paint,
    );
    canvas.drawPath(
      line([
        Offset(0.12 * w, 1.05 * h),
        Offset(0.45 * w, 0.58 * h),
        Offset(0.82 * w, 0.78 * h),
        Offset(1.2 * w, 0.42 * h),
      ]),
      paint,
    );
    canvas.drawPath(
      line([
        Offset(-0.02 * w, 0.55 * h),
        Offset(0.32 * w, 0.38 * h),
        Offset(0.68 * w, 0.66 * h),
        Offset(1.15 * w, 0.28 * h),
      ]),
      paint,
    );

    final arcPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.85, h * 0.15), radius: w * 0.55),
      math.pi * 0.9,
      math.pi * 0.7,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WatermarkLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}
