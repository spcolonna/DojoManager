import 'package:flutter/material.dart';

class TrailPoint {
  final double x;
  final double y;
  double opacity;

  TrailPoint({required this.x, required this.y, this.opacity = 0.6});
}

class TrailPainter extends CustomPainter {
  final List<TrailPoint> blueTrail;
  final List<TrailPoint> redTrail;
  final Color blueColor;
  final Color redColor;

  const TrailPainter({
    required this.blueTrail,
    required this.redTrail,
    required this.blueColor,
    required this.redColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawTrail(canvas, size, blueTrail, blueColor);
    _drawTrail(canvas, size, redTrail, redColor);
  }

  void _drawTrail(Canvas canvas, Size size,
      List<TrailPoint> trail, Color color) {
    for (int i = 0; i < trail.length; i++) {
      final p = trail[i];
      final radius = 6.0 * (i / trail.length); // más pequeño al principio
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        radius,
        Paint()
          ..color = color.withOpacity(p.opacity * (i / trail.length))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrailPainter old) => true;
}