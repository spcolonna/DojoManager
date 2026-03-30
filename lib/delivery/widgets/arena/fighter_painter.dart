import 'dart:math';
import 'package:flutter/material.dart';

enum FighterShape { hexagon, triangle }

class FighterPainter extends CustomPainter {
  final Color color;
  final bool isFlashing;
  final double pulse;
  final FighterShape shape;
  final bool showLabel;
  final String? label;

  const FighterPainter({
    required this.color,
    required this.isFlashing,
    required this.pulse,
    this.shape = FighterShape.hexagon,
    this.showLabel = false,
    this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Glow
    canvas.drawCircle(
      c,
      r * (1.3 + pulse * 0.25),
      Paint()
        ..color = (isFlashing ? Colors.white : color)
            .withOpacity(isFlashing ? 0.6 : 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Forma
    final path = shape == FighterShape.hexagon
        ? _hexPath(c, r * 0.82)
        : _triPath(c, r * 0.82);

    canvas.drawPath(path, Paint()..color = isFlashing ? Colors.white : color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Punto central
    canvas.drawCircle(
      c, r * 0.20,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Etiqueta "TÚ" o "RIVAL"
    if (showLabel && label != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [Shadow(color: color, blurRadius: 6)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(c.dx - tp.width / 2, -tp.height - 4));
    }
  }

  Path _hexPath(Offset c, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 30) * pi / 180;
      final x = c.dx + r * cos(a);
      final y = c.dy + r * sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  Path _triPath(Offset c, double r) {
    // Triángulo apuntando hacia la izquierda (hacia el jugador)
    final path = Path();
    path.moveTo(c.dx - r, c.dy);           // punta izquierda
    path.lineTo(c.dx + r * 0.6, c.dy - r * 0.85);
    path.lineTo(c.dx + r * 0.6, c.dy + r * 0.85);
    return path..close();
  }

  @override
  bool shouldRepaint(FighterPainter old) =>
      old.color != color ||
          old.isFlashing != isFlashing ||
          old.pulse != pulse;
}