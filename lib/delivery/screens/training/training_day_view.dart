import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/training_activities_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/day_plan.dart';
import '../../../domain/entities/weekly_plan.dart';
import 'day_stat.dart';

class TrainingDayView extends ConsumerWidget {
  final DayOfWeek day;
  final String dayName;
  final DayPlan plan;
  final bool isSimulated;
  final dynamic loc;
  final VoidCallback onEditTap;

  const TrainingDayView({
    required this.day,
    required this.dayName,
    required this.plan,
    required this.isSimulated,
    required this.loc,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del día
          Row(
            children: [
              Text(
                dayName,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldLight,
                ),
              ),
              const Spacer(),
              if (isSimulated)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(AppIcons.actionConfirm,
                          color: AppColors.success, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'DONE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            color: AppColors.goldPrimary, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'EDIT',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            loc.trainingActivitiesForAll,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 16),

          // Actividades del día
          if (!plan.hasActivities)
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.bgDivider,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.textTertiary, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      loc.trainingTapToEdit,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Lista de actividades programadas
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plan.activityIds.map((id) {
                final act = TrainingActivitiesConfig.byId(id);
                if (act == null) return const SizedBox.shrink();
                final cat = act.category;
                final color = _categoryColor(cat);
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_categoryIcon(cat), color: color, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        _activityName(id, loc),
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Resumen del día
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bgDivider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DayStat(
                    label: loc.trainingDayFatigue,
                    value: '${plan.totalFatigue}%',
                    color: plan.totalFatigue > 60
                        ? AppColors.warning
                        : AppColors.textSecondary,
                    icon: AppIcons.statusFatigue,
                  ),
                  DayStat(
                    label: loc.trainingDayPH,
                    value: '+${plan.totalPH}',
                    color: AppColors.goldPrimary,
                    icon: AppIcons.trainingMind,
                  ),
                  DayStat(
                    label: loc.trainingDayXP,
                    value: '+${plan.totalXP}',
                    color: AppColors.success,
                    icon: Icons.stars_rounded,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Estudiantes que van a entrenar
          Text(
            'MY STUDENTS',
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          studentsAsync.when(
            loading: () => const CircularProgressIndicator(
                color: AppColors.goldPrimary),
            error: (_, __) => const SizedBox.shrink(),
            data: (students) => Column(
              children: students.map((s) {
                final styleColor =
                    AppColors.colorByStyle[s.styleId] ?? AppColors.goldPrimary;
                final beltColor =
                    AppColors.beltColorByLevel[s.belt.level] ??
                        AppColors.beltWhite;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bgDivider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: styleColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(AppIcons.studentFill,
                            color: styleColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.nameKey,
                                style: GoogleFonts.rajdhani(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Row(
                              children: [
                                Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                      color: beltColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${s.fatiguePercent}% fatigue',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    color: s.fatiguePercent > 60
                                        ? AppColors.warning
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Preview de lo que ganaría hoy
                      if (plan.hasActivities)
                        Text(
                          '+${plan.totalPH} PH',
                          style: GoogleFonts.rajdhani(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.goldPrimary),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(ActivityCategory cat) => switch (cat) {
    ActivityCategory.strength    => AppColors.branchPower,
    ActivityCategory.cardio      => AppColors.orange,
    ActivityCategory.technique   => AppColors.branchTechnique,
    ActivityCategory.mindDefense => AppColors.branchMind,
    ActivityCategory.combat      => AppColors.redLight,
    ActivityCategory.recovery    => AppColors.success,
  };

  IconData _categoryIcon(ActivityCategory cat) => switch (cat) {
    ActivityCategory.strength    => AppIcons.trainingStrength,
    ActivityCategory.cardio      => Icons.directions_run_rounded,
    ActivityCategory.technique   => Icons.precision_manufacturing_rounded,
    ActivityCategory.mindDefense => AppIcons.trainingMind,
    ActivityCategory.combat      => Icons.sports_mma_rounded,
    ActivityCategory.recovery    => Icons.spa_rounded,
  };

  String _activityName(String id, dynamic loc) => switch (id) {
    'push_ups'          => loc.activityPushUps,
    'planks'            => loc.activityPlanks,
    'abs'               => loc.activityAbs,
    'weight_training'   => loc.activityWeightTraining,
    'running'           => loc.activityRunning,
    'jump_rope'         => loc.activityJumpRope,
    'sprints'           => loc.activitySprints,
    'kata'              => loc.activityKata,
    'shadow_combat'     => loc.activityShadowCombat,
    'bag_work'          => loc.activityBagWork,
    'technique_drills'  => loc.activityTechniqueDrills,
    'postures'          => loc.activityPostures,
    'meditation'        => loc.activityMeditation,
    'breathing'         => loc.activityBreathing,
    'guard_drills'      => loc.activityGuardDrills,
    'sparring'          => loc.activitySparring,
    'controlled_combat' => loc.activityControlledCombat,
    'strategy_session'  => loc.activityStrategySession,
    'stretching'        => loc.activityStretching,
    'ice_bath'          => loc.activityIceBath,
    'rest'              => loc.activityRest,
    _                   => id,
  };
}