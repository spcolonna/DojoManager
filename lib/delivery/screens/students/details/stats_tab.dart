import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/l10n_helper.dart';
import '../../../../domain/entities/student.dart';
import '../../../widgets/animations/animated_stat_bar.dart';
import 'info_chip.dart';

class StatsTab extends StatelessWidget {
  final Student student;
  final Color styleColor;

  const StatsTab({required this.student, required this.styleColor});

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats principales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.bgDivider),
            ),
            child: Column(
              children: [
                AnimatedStatBar(
                  label: loc.statStr,
                  value: student.stats.str,
                  color: AppColors.branchPower,
                ),
                AnimatedStatBar(
                  label: loc.statSpd,
                  value: student.stats.spd,
                  color: AppColors.branchAgility,
                ),
                AnimatedStatBar(
                  label: loc.statTec,
                  value: student.stats.tec,
                  color: AppColors.branchTechnique,
                ),
                AnimatedStatBar(
                  label: loc.statDef,
                  value: student.stats.def,
                  color: AppColors.branchGuard,
                ),
                AnimatedStatBar(
                  label: loc.statMen,
                  value: student.stats.men,
                  color: AppColors.branchMind,
                ),
                AnimatedStatBar(
                  label: loc.statRes,
                  value: student.stats.res,
                  maxValue: 100,
                  color: styleColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Chips de info
          Row(
            children: [
              InfoChip(
                icon: AppIcons.statusFatigue,
                label: loc.studentFatigueLevel,
                value: '${student.fatiguePercent}%',
                color: student.fatiguePercent > 60
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              InfoChip(
                icon: AppIcons.trainingMind,
                label: 'PH',
                value: '${student.skillPoints}',
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 10),
              InfoChip(
                icon: AppIcons.studentMedal,
                label: 'Sessions',
                value: '${student.trainingHistory.length}',
                color: AppColors.info,
              ),
            ],
          ),

          if (student.isInjured) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.redAction.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.redAction.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.studentInjured,
                      color: AppColors.redLight, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    loc.studentInjuredWeeks(
                        student.injuryWeeksRemaining),
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.redLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}