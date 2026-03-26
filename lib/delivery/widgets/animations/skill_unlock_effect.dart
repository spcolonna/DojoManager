import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';

/// Efecto visual al desbloquear un nodo del árbol de habilidades.
/// Uso:
///   final key = GlobalKey<SkillUnlockEffectState>();
///   SkillUnlockEffect(key: key, child: myWidget)
///   key.currentState?.play();
class SkillUnlockEffect extends StatefulWidget {
  final Widget child;
  final Color color;

  const SkillUnlockEffect({
    super.key,
    required this.child,
    this.color = AppColors.goldPrimary,
  });

  @override
  State<SkillUnlockEffect> createState() => SkillUnlockEffectState();
}

class SkillUnlockEffectState extends State<SkillUnlockEffect>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _particleController;
  late Animation<double> _flashAnim;
  late Animation<double> _scaleAnim;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    _flashController = AnimationController(
      vsync: this,
      duration: AppAnimations.skillUnlock,
    );

    _particleController = AnimationController(
      vsync: this,
      duration: AppAnimations.skillUnlock,
    );

    _flashAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
    ]).animate(_flashController);
  }

  @override
  void dispose() {
    _flashController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void play() {
    _particles.clear();
    for (int i = 0; i < 10; i++) {
      _particles.add(_Particle(
        angle: _rng.nextDouble() * 2 * pi,
        speed: 40 + _rng.nextDouble() * 60,
        size: 3 + _rng.nextDouble() * 4,
        color: widget.color.withOpacity(0.8 + _rng.nextDouble() * 0.2),
      ));
    }
    _flashController.forward(from: 0);
    _particleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flashController, _particleController]),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Scale + glow del widget base
            Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (_flashAnim.value > 0)
                      BoxShadow(
                        color: widget.color.withOpacity(_flashAnim.value * 0.8),
                        blurRadius: 20 * _flashAnim.value,
                        spreadRadius: 4 * _flashAnim.value,
                      ),
                  ],
                ),
                child: widget.child,
              ),
            ),
            // Flash overlay blanco
            if (_flashAnim.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(_flashAnim.value * 0.6),
                    ),
                  ),
                ),
              ),
            // Partículas
            ..._particles.map((p) {
              final progress = _particleController.value;
              final x = cos(p.angle) * p.speed * progress;
              final y = sin(p.angle) * p.speed * progress;
              final opacity = (1 - progress).clamp(0.0, 1.0);

              return Positioned(
                left: 20 + x,
                top: 20 + y,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}