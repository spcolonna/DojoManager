import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/belt_helper.dart';
import '../../../../domain/entities/student.dart';

class ProgressTab extends StatelessWidget {
  final Student student;
  final Color beltColor;
  final double xpPercent;
  final VoidCallback onOpenTree;
  final dynamic loc;

  const ProgressTab({
    required this.student,
    required this.beltColor,
    required this.xpPercent,
    required this.onOpenTree,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    // Cadena de fajas
    final beltLevels = List.generate(10, (i) => i + 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progreso de faja
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.bgDivider),
            ),
            child: Column(
              children: [
                // Cadena de fajas visual
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: beltLevels.length,
                    itemBuilder: (_, i) {
                      final level  = beltLevels[i];
                      final color  = AppColors.beltColorByLevel[level] ??
                          AppColors.beltWhite;
                      final isDone = student.belt.level > level;
                      final isCurr = student.belt.level == level;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: AppAnimations.normal,
                            width: isCurr ? 36 : 28,
                            height: isCurr ? 36 : 28,
                            decoration: BoxDecoration(
                              color: isDone || isCurr
                                  ? color.withOpacity(0.2)
                                  : AppColors.bgElevated,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDone || isCurr
                                    ? color
                                    : AppColors.bgDivider,
                                width: isCurr ? 2 : 1,
                              ),
                            ),
                            child: isDone
                                ? Icon(AppIcons.actionConfirm,
                                color: color, size: 14)
                                : null,
                          ),
                          if (i < beltLevels.length - 1)
                            Container(
                              width: 16, height: 2,
                              color: isDone
                                  ? color.withOpacity(0.4)
                                  : AppColors.bgDivider,
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // XP actual
                Row(
                  children: [
                    Text(
                      beltDisplayName(student.belt.titleKey, loc),
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: beltColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${student.currentXP} / ${student.belt.xpRequiredForNextLevel} XP',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: xpPercent),
                  duration: AppAnimations.statBarFill,
                  curve: AppAnimations.sharpOut,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: AppColors.bgDivider,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(beltColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nodos del árbol desbloqueados
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.bgDivider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.branchPower,
                        color: AppColors.goldPrimary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      loc.studentOpenTree,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${student.unlockedNodeIds.length} nodes',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (student.skillPoints > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.studentAvailablePH(student.skillPoints),
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpenTree,
                    icon: const Icon(AppIcons.branchPower, size: 16),
                    label: Text(
                      loc.studentOpenTree,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: AppColors.bgDeep,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
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