import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Animación de transición entre días.
/// Uso: DayAdvanceAnimation.show(context, dayName: 'Tuesday', onDone: ...)
class DayAdvanceAnimation {
  static Future<void> show(
      BuildContext context, {
        required String dayName,
        required VoidCallback onDone,
      }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _DayAdvanceWidget(
        dayName: dayName,
        onDone: onDone,
      ),
    );
  }
}

class _DayAdvanceWidget extends StatefulWidget {
  final String dayName;
  final VoidCallback onDone;
  const _DayAdvanceWidget({required this.dayName, required this.onDone});

  @override
  State<_DayAdvanceWidget> createState() => _DayAdvanceWidgetState();
}

class _DayAdvanceWidgetState extends State<_DayAdvanceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c,
          curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _scale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _c,
          curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );
    _fadeOut = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _c,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    _c.forward().then((_) {
      Navigator.of(context).pop();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Material(
        color: Colors.black.withOpacity(_fadeIn.value * 0.85),
        child: Center(
          child: Opacity(
            opacity: _fadeIn.value * _fadeOut.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Línea horizontal que atraviesa
                  Container(
                    height: 1.5,
                    width: MediaQuery.of(context).size.width * 0.7 *
                        _fadeIn.value,
                    color: AppColors.goldPrimary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.dayName.toUpperCase(),
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldLight,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TRAINING',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1.5,
                    width: MediaQuery.of(context).size.width * 0.7 *
                        _fadeIn.value,
                    color: AppColors.goldPrimary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}