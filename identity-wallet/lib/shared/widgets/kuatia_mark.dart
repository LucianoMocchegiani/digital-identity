import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Painter del path de marca (cruz/X), viewBox 24×24.
class KuatiaXPainter extends CustomPainter {
  KuatiaXPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final sx = size.width / 24;
    final sy = size.height / 24;
    final path = Path()
      ..moveTo(7.2 * sx, 4.2 * sy)
      ..lineTo(12 * sx, 9 * sy)
      ..lineTo(16.8 * sx, 4.2 * sy)
      ..lineTo(18.8 * sx, 6.2 * sy)
      ..lineTo(14 * sx, 11 * sy)
      ..lineTo(18.8 * sx, 15.8 * sy)
      ..lineTo(16.8 * sx, 17.8 * sy)
      ..lineTo(12 * sx, 13 * sy)
      ..lineTo(7.2 * sx, 17.8 * sy)
      ..lineTo(5.2 * sx, 15.8 * sy)
      ..lineTo(10 * sx, 11 * sy)
      ..lineTo(5.2 * sx, 6.2 * sy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant KuatiaXPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ícono de launcher / splash (fondo charcoal + X teal).
class KuatiaAppIcon extends StatelessWidget {
  const KuatiaAppIcon({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.inkOnAccent,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.5, size * 0.5),
        painter: KuatiaXPainter(color: AppColors.brandPrimary),
      ),
    );
  }
}
