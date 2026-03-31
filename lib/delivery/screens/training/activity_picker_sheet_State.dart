import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/animations/app_animations.dart';
import '../../../core/config/training_activities_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/l10n_helper.dart';
import 'activity_picker_sheet.dart';

class ActivityPickerSheetState extends State<ActivityPickerSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.currentIds);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < TrainingActivitiesConfig.maxActivitiesPerWeek) {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    loc.trainingSelectActivities,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 14,
                      color: AppColors.goldLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selected.length >=
                          TrainingActivitiesConfig.maxActivitiesPerWeek
                          ? AppColors.redAction.withValues(alpha: 0.15)
                          : AppColors.goldPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selected.length}/${TrainingActivitiesConfig.maxActivitiesPerWeek}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: _selected.length >=
                            TrainingActivitiesConfig.maxActivitiesPerWeek
                            ? AppColors.redLight
                            : AppColors.goldPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.bgDivider),
            // Lista
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: ActivityCategory.values.map((cat) {
                  final acts = TrainingActivitiesConfig.byCategory(cat);
                  final catColor = _catColor(cat);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(_catIcon(cat), color: catColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _catName(cat, loc),
                              style: GoogleFonts.rajdhani(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: catColor, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: acts.map((act) {
                          final isSel = _selected.contains(act.id);
                          final atLim = !isSel &&
                              _selected.length >=
                                  TrainingActivitiesConfig.maxActivitiesPerWeek;
                          return GestureDetector(
                            onTap: atLim ? null : () => _toggle(act.id),
                            child: AnimatedContainer(
                              duration: AppAnimations.fast,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? catColor.withValues(alpha: 0.15)
                                    : atLim
                                    ? AppColors.bgInput.withValues(alpha: 0.3)
                                    : AppColors.bgElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSel
                                      ? catColor
                                      : atLim
                                      ? AppColors.bgDivider.withValues(alpha: 0.3)
                                      : AppColors.bgDivider,
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSel)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(right: 4),
                                      child: Icon(AppIcons.actionConfirm,
                                          size: 11, color: catColor),
                                    ),
                                  Text(
                                    _actName(act.id, loc),
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 12,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSel
                                          ? catColor
                                          : atLim
                                          ? AppColors.textDisabled
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (act.phBonus > 0)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(left: 4),
                                      child: Text(
                                        '+${act.phBonus}PH',
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isSel
                                              ? AppColors.goldPrimary
                                              : AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            ),
            // Botón confirmar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_selected);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.bgDeep,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    loc.trainingConfirmPlan,
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _catColor(ActivityCategory c) => switch (c) {
    ActivityCategory.strength    => AppColors.branchPower,
    ActivityCategory.cardio      => AppColors.orange,
    ActivityCategory.technique   => AppColors.branchTechnique,
    ActivityCategory.mindDefense => AppColors.branchMind,
    ActivityCategory.combat      => AppColors.redLight,
    ActivityCategory.recovery    => AppColors.success,
  };

  IconData _catIcon(ActivityCategory c) => switch (c) {
    ActivityCategory.strength    => AppIcons.trainingStrength,
    ActivityCategory.cardio      => Icons.directions_run_rounded,
    ActivityCategory.technique   => Icons.precision_manufacturing_rounded,
    ActivityCategory.mindDefense => AppIcons.trainingMind,
    ActivityCategory.combat      => Icons.sports_mma_rounded,
    ActivityCategory.recovery    => Icons.spa_rounded,
  };

  String _catName(ActivityCategory c, dynamic loc) => switch (c) {
    ActivityCategory.strength    => loc.activityCategoryStrength,
    ActivityCategory.cardio      => loc.activityCategoryCardio,
    ActivityCategory.technique   => loc.activityCategoryTechnique,
    ActivityCategory.mindDefense => loc.activityCategoryMindDefense,
    ActivityCategory.combat      => loc.activityCategoryCombat,
    ActivityCategory.recovery    => loc.activityCategoryRecovery,
  };

  String _actName(String id, dynamic loc) => switch (id) {
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