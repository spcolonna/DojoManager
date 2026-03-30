import 'package:flutter/material.dart';

class ArenaPainter extends CustomPainter {
  final double shakeX;
  final double shakeY;

  const ArenaPainter({this.shakeX = 0, this.shakeY = 0});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(shakeX, shakeY);

    final w = size.width, h = size.height;
    const pad = 12.0;
    final mat = Rect.fromLTRB(pad, pad, w - pad, h - pad);
    final rr  = RRect.fromRectAndRadius(mat, const Radius.circular(10));

    // Fondo del ring
    canvas.drawRRect(rr, Paint()..color = const Color(0xFF1E1508));

    // Líneas de tatami (horizontal)
    final gridPaint = Paint()
      ..color = const Color(0xFF2E220F)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      final y = pad + (h - pad * 2) * i / 8;
      canvas.drawLine(Offset(pad, y), Offset(w - pad, y), gridPaint);
    }
    // Vertical
    for (int i = 1; i < 6; i++) {
      final x = pad + (w - pad * 2) * i / 6;
      canvas.drawLine(Offset(x, pad), Offset(x, h - pad), gridPaint);
    }

    // Círculo central
    final centerPaint = Paint()
      ..color = const Color(0xFF3A2A10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w / 2, h / 2), 38, centerPaint);
    canvas.drawCircle(Offset(w / 2, h / 2), 6,
        Paint()..color = const Color(0xFF3A2A10));

    // Borde dorado del ring
    canvas.drawRRect(rr, Paint()
      ..color = const Color(0xFF6A4E00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Esquina azul (izquierda)
    canvas.drawRect(
      Rect.fromLTWH(pad, pad, 22, 22),
      Paint()..color = const Color(0xFF0A2040),
    );
    // Esquina roja (derecha)
    canvas.drawRect(
      Rect.fromLTWH(w - pad - 22, pad, 22, 22),
      Paint()..color = const Color(0xFF400A0A),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(ArenaPainter old) =>
      old.shakeX != shakeX || old.shakeY != shakeY;
}