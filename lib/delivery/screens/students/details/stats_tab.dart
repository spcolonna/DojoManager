import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/l10n_helper.dart';
import '../../../../domain/entities/student.dart';
import '../../../../domain/use_cases/training/generate_learning_coefficients.dart';
import '../../../widgets/animations/animated_stat_bar.dart';
import 'info_chip.dart';

class StatsTab extends StatelessWidget {
  final Student student;
  final Color styleColor;

  const StatsTab({required this.student, required this.styleColor});

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final hasCoefficients = student.learningCoefficients.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Stats principales ──────────────────────────────────
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

          // ── Chips de info ──────────────────────────────────────
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

          // ── Lesión ────────────────────────────────────────────
          if (student.isInjured) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.redAction.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.redAction.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.studentInjured,
                      color: AppColors.redLight, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    loc.studentInjuredWeeks(student.injuryWeeksRemaining),
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

          const SizedBox(height: 16),

          // ── Potencial (coeficientes de aprendizaje) ────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasCoefficients
                    ? AppColors.goldPrimary.withValues(alpha: 0.3)
                    : AppColors.bgDivider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasCoefficients
                          ? Icons.auto_awesome_rounded
                          : Icons.lock_outline_rounded,
                      color: hasCoefficients
                          ? AppColors.goldPrimary
                          : AppColors.textTertiary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'POTENCIAL',
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: hasCoefficients
                            ? AppColors.goldPrimary
                            : AppColors.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                hasCoefficients
                    ? _CoefficientsGrid(
                  coefficients: student.learningCoefficients,
                  loc: loc,
                )
                    : Text(
                  loc.talentLocked,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    height: 1.4,
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

// ─── GRILLA DE COEFICIENTES ───────────────────────────────────────────────────

class _CoefficientsGrid extends StatelessWidget {
  final Map<String, double> coefficients;
  final dynamic loc;

  const _CoefficientsGrid({
    required this.coefficients,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final stats = ['str', 'spd', 'tec', 'def', 'men'];
    final colors = {
      'str': AppColors.branchPower,
      'spd': AppColors.branchAgility,
      'tec': AppColors.branchTechnique,
      'def': AppColors.branchGuard,
      'men': AppColors.branchMind,
    };
    final labels = {
      'str': 'STR',
      'spd': 'SPD',
      'tec': 'TEC',
      'def': 'DEF',
      'men': 'MEN',
    };

    return Column(
      children: stats.map((stat) {
        final coeff = coefficients[stat] ?? 1.0;
        final stars = GenerateLearningCoefficients.toStars(coeff);
        final color = colors[stat] ?? AppColors.textSecondary;
        final label = GenerateLearningCoefficients.toLabel(coeff, loc);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // Stat label
              SizedBox(
                width: 36,
                child: Text(
                  labels[stat] ?? stat.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              // Estrellas
              Row(
                children: List.generate(5, (i) => Icon(
                  i < stars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 14,
                  color: i < stars
                      ? AppColors.goldPrimary
                      : AppColors.bgDivider,
                )),
              ),
              const SizedBox(width: 8),
              // Label de talento
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}