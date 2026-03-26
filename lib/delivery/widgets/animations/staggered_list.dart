import 'package:flutter/material.dart';
import '../../../core/animations/app_animations.dart';

/// Envuelve una lista de widgets y los hace aparecer de a uno con delay.
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final int msPerItem;

  const StaggeredList({
    super.key,
    required this.children,
    this.msPerItem = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (i) => _StaggerItem(
        delay: AppAnimations.stagger(i, msPerItem: msPerItem),
        child: children[i],
      )),
    );
  }
}

class _StaggerItem extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _StaggerItem({required this.child, required this.delay});

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: AppAnimations.normal);
    _opacity = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: AppAnimations.fadeIn));
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: AppAnimations.slideIn));

    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}