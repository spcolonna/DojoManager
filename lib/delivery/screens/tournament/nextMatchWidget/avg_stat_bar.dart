import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class AvgStatBar extends StatelessWidget {
  final String label;
  final List fighters;
  final String statKey;
  final Color color;

  const AvgStatBar(this.label, this.fighters, this.statKey, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final avg = fighters.isEmpty
        ? 0.0
        : fighters
        .map((f) => (f.stats.toMap()[statKey] ?? 0) as int)
        .reduce((a, b) => a + b) /
        fighters.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(label,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                )),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (avg / 40).clamp(0, 1),
                minHeight: 5,
                backgroundColor: AppColors.bgDivider,
                valueColor: AlwaysStoppedAnimation<Color>(
                    color.withValues(alpha: 0.7)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            avg.toStringAsFixed(0),
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}