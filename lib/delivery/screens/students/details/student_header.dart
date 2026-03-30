import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/belt_helper.dart';
import '../../../../domain/entities/student.dart';

class StudentHeader extends StatelessWidget {
  final Student student;
  final Color styleColor;
  final Color beltColor;
  final double xpPercent;
  final dynamic loc;

  const StudentHeader({
    required this.student,
    required this.styleColor,
    required this.beltColor,
    required this.xpPercent,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final xpRequired = student.belt.xpRequiredForNextLevel;
    final xpMissing  = (xpRequired - student.currentXP).clamp(0, 999999);

    return Container(
      // ← reducí el padding top de 80 a 52
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            styleColor.withValues(alpha: 0.20),
            AppColors.bgSurface,
          ],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: styleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: styleColor.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: styleColor.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(AppIcons.studentFill, color: styleColor, size: 38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.nameKey,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: beltColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      beltDisplayName(student.belt.titleKey, loc),
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: beltColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('·', style: GoogleFonts.rajdhani(
                        color: AppColors.textTertiary)),
                    const SizedBox(width: 8),
                    Text(
                      styleDisplayName(student.styleId, loc),
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // XP bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: xpPercent),
                    duration: AppAnimations.statBarFill,
                    curve: AppAnimations.sharpOut,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 7,
                      backgroundColor: AppColors.bgDivider,
                      valueColor: AlwaysStoppedAnimation<Color>(styleColor),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // ← texto más visible
                Text(
                  loc.studentXPToNext(xpMissing),
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary, // era textTertiary
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}