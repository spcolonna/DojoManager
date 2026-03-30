import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/delivery/screens/students/details/result_chip.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/belt_helper.dart';
import '../../../../domain/entities/training_session.dart';

class HistoryCard extends StatelessWidget {
  final TrainingSession session;
  final dynamic loc;

  const HistoryCard({required this.session, required this.loc});

  @override
  Widget build(BuildContext context) {
    final date    = session.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final actList = session.activityIds
        .take(3)
        .map((id) => _activityName(id, loc))
        .toList();
    final extra = session.activityIds.length > 3
        ? ' +${session.activityIds.length - 3}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: session.leveledUp
              ? AppColors.goldPrimary.withValues(alpha: 0.4)
              : AppColors.bgDivider,
          width: session.leveledUp ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha + badge de subida de faja
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 11, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(
                dateStr,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (session.leveledUp)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward_rounded,
                          color: AppColors.goldPrimary, size: 11),
                      const SizedBox(width: 3),
                      Text(
                        beltDisplayName(session.newBeltKey ?? '', loc),
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Actividades como chips individuales
          if (session.activityIds.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...actList.map((name) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.bgDivider),
                  ),
                  child: Text(
                    name,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )),
                if (session.activityIds.length > 3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.bgDivider),
                    ),
                    child: Text(
                      extra.trim(),
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 10),

          // Chips de resultado
          Row(
            children: [
              ResultChip(
                label: loc.historyXPGained(session.xpGained),
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              ResultChip(
                label: loc.historyPHGained(session.phGained),
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 8),
              ResultChip(
                label: '${session.fatigueAfter}%',
                icon: Icons.local_fire_department_rounded,
                color: session.fatigueAfter > 60
                    ? AppColors.warning
                    : AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

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