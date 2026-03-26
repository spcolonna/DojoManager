import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';

class AnimatedStatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final bool showValue;

  const AnimatedStatBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
    this.color = AppColors.goldPrimary,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / maxValue),
              duration: AppAnimations.statBarFill,
              curve: AppAnimations.sharpOut,
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: AppColors.bgDivider,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ),
          if (showValue) ...[
            const SizedBox(width: 6),
            SizedBox(
              width: 24,
              child: Text(
                '$value',
                textAlign: TextAlign.right,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}