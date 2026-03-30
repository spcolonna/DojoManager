import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleType { burst, ring, fall, spiral }

class ArenaParticle {
  double x, y, vx, vy, life, size;
  Color color;
  ParticleType type;
  double angle; // para espiral

  ArenaParticle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.color, required this.size,
    this.type = ParticleType.burst,
    this.life = 1.0,
    this.angle = 0,
  });
}

class ParticlePainter extends CustomPainter {
  final List<ArenaParticle> particles;

  const ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = p.life.clamp(0.0, 1.0);
      final paint   = Paint()
        ..color = p.color.withValues(alpha: opacity);

      if (p.type == ParticleType.ring) {
        // Anillo expansivo
        canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height),
          p.size,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else {
        canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height),
          p.size * p.life,
          paint..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => true;
}