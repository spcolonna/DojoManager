import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';

/// Texto que flota hacia arriba y se desvanece.
/// Uso: FloatLabel.show(context, '+5 PH', color: AppColors.goldPrimary);
class FloatLabel {
  static void show(
      BuildContext context,
      String text, {
        Color color = AppColors.goldPrimary,
        Offset? position,
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(builder: (_) => _FloatLabelWidget(
      text: text,
      color: color,
      position: position,
      onDone: () => entry.remove(),
    ));

    overlay.insert(entry);
  }
}

class _FloatLabelWidget extends StatefulWidget {
  final String text;
  final Color color;
  final Offset? position;
  final VoidCallback onDone;

  const _FloatLabelWidget({
    required this.text,
    required this.color,
    required this.onDone,
    this.position,
  });

  @override
  State<_FloatLabelWidget> createState() => _FloatLabelWidgetState();
}

class _FloatLabelWidgetState extends State<_FloatLabelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.floatFade,
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 45),
    ]).animate(_controller);

    _offset = Tween(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.sharpOut),
    );

    _controller.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pos  = widget.position ?? Offset(size.width / 2, size.height / 2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Positioned(
        left: pos.dx - 40,
        top: pos.dy + _offset.value,
        child: IgnorePointer(
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.color.withValues(alpha: 0.5)),
              ),
              child: Text(
                widget.text,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}