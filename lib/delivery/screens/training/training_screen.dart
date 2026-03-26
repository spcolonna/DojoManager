import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/belt_helper.dart';
import '../../../core/config/training_activities_config.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../widgets/animations/staggered_list.dart';
import 'training_view_model.dart';
import 'week_results_screen.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc            = l10n(context);
    final studentsAsync  = ref.watch(studentsProvider);
    final trainingState  = ref.watch(trainingViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        toolbarHeight: 20,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Text(
          loc.trainingTitle,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 14,
            color: AppColors.goldLight,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.bgDivider),
        ),
      ),
      body: studentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Text(loc.trainingNoStudents,
                  style: GoogleFonts.rajdhani(color: AppColors.textSecondary)),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: StaggeredList(
                    children: students.map((student) {
                      final selected = trainingState.activitiesFor(student.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _StudentPlanCard(
                          student: student,
                          selectedActivityIds: selected,
                          onToggle: (actId) => ref
                              .read(trainingViewModelProvider.notifier)
                              .toggleActivity(student.id, actId),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Botón simular semana ───────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  color: AppColors.bgSurface,
                  border: Border(top: BorderSide(color: AppColors.bgDivider)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: trainingState.isSimulating
                        ? null
                        : () async {
                      await ref
                          .read(trainingViewModelProvider.notifier)
                          .simulateWeek(students);
                      final results =
                          ref.read(trainingViewModelProvider).results;
                      if (results != null && context.mounted) {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              WeekResultsScreen(results: results),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration:
                          const Duration(milliseconds: 400),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: AppColors.bgDeep,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: trainingState.isSimulating
                        ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.bgDeep),
                    )
                        : Text(
                      loc.trainingSimulateWeek,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── STUDENT PLAN CARD ────────────────────────────────────────────────────────

class _StudentPlanCard extends StatelessWidget {
  final dynamic student;
  final List<String> selectedActivityIds;
  final void Function(String activityId) onToggle;

  const _StudentPlanCard({
    required this.student,
    required this.selectedActivityIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final loc        = l10n(context);
    final styleColor = AppColors.colorByStyle[student.styleId] ?? AppColors.goldPrimary;
    final beltColor  = AppColors.beltColorByLevel[student.belt.level] ?? AppColors.beltWhite;

    // Calcular totales de la selección actual
    int totalFatigue = student.fatiguePercent as int;
    int totalPH      = 0;
    final statPreview = <String, int>{};
    for (final id in selectedActivityIds) {
      final act = TrainingActivitiesConfig.byId(id);
      if (act == null) continue;
      totalFatigue += act.fatigueAdd;
      totalPH      += act.totalPH;
      act.statBonus.forEach((s, v) => statPreview[s] = (statPreview[s] ?? 0) + v);
    }
    totalFatigue = totalFatigue.clamp(0, 100);
    final overLimit = totalFatigue >= TrainingActivitiesConfig.fatigueInjuryThreshold;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: Column(
        children: [
          // ── Header del estudiante ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: styleColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: styleColor.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.person_rounded, color: styleColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.nameKey,
                          style: GoogleFonts.rajdhani(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: beltColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            beltDisplayName(student.belt.titleKey, loc),
                            style: GoogleFonts.rajdhani(
                                fontSize: 12, color: beltColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Indicador de fatiga proyectada
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(loc.trainingFatigue,
                        style: GoogleFonts.rajdhani(
                            fontSize: 10, color: AppColors.textTertiary,
                            letterSpacing: 1)),
                    Text(
                      '$totalFatigue%',
                      style: GoogleFonts.rajdhani(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: overLimit ? AppColors.redLight
                            : totalFatigue > 50 ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (overLimit)
                      Text(
                        '⚠ ${loc.trainingFatigueWarning}',
                        style: GoogleFonts.rajdhani(
                            fontSize: 9, color: AppColors.redLight),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Stats con preview de ganancia ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Column(
              children: [
                _StatRowWithGain('STR', student.stats.str, statPreview['str'] ?? 0, AppColors.branchPower),
                _StatRowWithGain('SPD', student.stats.spd, statPreview['spd'] ?? 0, AppColors.branchAgility),
                _StatRowWithGain('TEC', student.stats.tec, statPreview['tec'] ?? 0, AppColors.branchTechnique),
                _StatRowWithGain('DEF', student.stats.def, statPreview['def'] ?? 0, AppColors.branchGuard),
                _StatRowWithGain('MEN', student.stats.men, statPreview['men'] ?? 0, AppColors.branchMind),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.bgDivider),

          // ── Selector de actividades ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      loc.trainingActivitiesTitle.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary, letterSpacing: 1.5),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: selectedActivityIds.length >=
                            TrainingActivitiesConfig.maxActivitiesPerWeek
                            ? AppColors.redAction.withOpacity(0.15)
                            : AppColors.goldPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        loc.trainingActivitiesSelected(
                          selectedActivityIds.length,
                          TrainingActivitiesConfig.maxActivitiesPerWeek,
                        ),
                        style: GoogleFonts.rajdhani(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: selectedActivityIds.length >=
                              TrainingActivitiesConfig.maxActivitiesPerWeek
                              ? AppColors.redLight
                              : AppColors.goldPrimary,
                        ),
                      ),
                    ),
                    if (totalPH > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+$totalPH PH',
                          style: GoogleFonts.rajdhani(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: AppColors.goldPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Actividades por categoría
                ...ActivityCategory.values.map((cat) {
                  final acts = TrainingActivitiesConfig.byCategory(cat);
                  return _CategorySection(
                    category: cat,
                    activities: acts,
                    selectedIds: selectedActivityIds,
                    atLimit: selectedActivityIds.length >=
                        TrainingActivitiesConfig.maxActivitiesPerWeek,
                    onToggle: onToggle,
                    loc: loc,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STAT ROW CON GANANCIA PROYECTADA ─────────────────────────────────────────

class _StatRowWithGain extends StatelessWidget {
  final String label;
  final int value;
  final int gain;
  final Color color;

  const _StatRowWithGain(this.label, this.value, this.gain, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(label,
                style: GoogleFonts.rajdhani(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary, letterSpacing: 0.5)),
          ),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
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
          const SizedBox(width: 6),
          SizedBox(
            width: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$value',
                    style: GoogleFonts.rajdhani(
                        fontSize: 11, color: AppColors.textSecondary)),
                if (gain > 0) ...[
                  const SizedBox(width: 2),
                  Text('+$gain',
                      style: GoogleFonts.rajdhani(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.success)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN POR CATEGORÍA ────────────────────────────────────────────────────

class _CategorySection extends StatefulWidget {
  final ActivityCategory category;
  final List<TrainingActivity> activities;
  final List<String> selectedIds;
  final bool atLimit;
  final void Function(String) onToggle;
  final dynamic loc;

  const _CategorySection({
    required this.category,
    required this.activities,
    required this.selectedIds,
    required this.atLimit,
    required this.onToggle,
    required this.loc,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasSelected =
    widget.activities.any((a) => widget.selectedIds.contains(a.id));
    final catColor = _categoryColor(widget.category);
    final catName  = _categoryName(widget.category, widget.loc);

    return Column(
      children: [
        // Header colapsable
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: hasSelected
                  ? catColor.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasSelected
                    ? catColor.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(_categoryIcon(widget.category),
                    color: catColor, size: 16),
                const SizedBox(width: 8),
                Text(catName,
                    style: GoogleFonts.rajdhani(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: catColor, letterSpacing: 0.5)),
                if (hasSelected) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: catColor, shape: BoxShape.circle),
                  ),
                ],
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textTertiary, size: 18,
                ),
              ],
            ),
          ),
        ),

        // Actividades expandibles
        AnimatedCrossFade(
          duration: AppAnimations.fast,
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.activities.map((act) {
                final isSelected = widget.selectedIds.contains(act.id);
                final isDisabled = !isSelected && widget.atLimit;
                final hasFatigue = act.fatigueAdd > 0;

                return GestureDetector(
                  onTap: isDisabled ? null : () => widget.onToggle(act.id),
                  child: AnimatedContainer(
                    duration: AppAnimations.fast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? catColor.withOpacity(0.15)
                          : isDisabled
                          ? AppColors.bgInput.withOpacity(0.3)
                          : AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? catColor
                            : isDisabled
                            ? AppColors.bgDivider.withOpacity(0.3)
                            : AppColors.bgDivider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.check_rounded,
                                size: 11, color: catColor),
                          ),
                        Text(
                          _activityName(act.id, widget.loc),
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? catColor
                                : isDisabled
                                ? AppColors.textDisabled
                                : AppColors.textSecondary,
                          ),
                        ),
                        // Indicadores de bonus
                        if (act.phBonus > 0 || act.xpBonus > 0 || hasFatigue)
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (act.phBonus > 0)
                                  _MiniTag(
                                      '+${act.phBonus}PH',
                                      AppColors.goldPrimary),
                                if (act.xpBonus > 0)
                                  _MiniTag(
                                      '+${act.xpBonus}XP',
                                      AppColors.success),
                                if (act.fatigueAdd > 15)
                                  _MiniTag(
                                      '🔥',
                                      AppColors.redLight),
                                if (act.fatigueAdd < 0)
                                  _MiniTag(
                                      '${act.fatigueAdd}%',
                                      AppColors.success),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Color _categoryColor(ActivityCategory cat) => switch (cat) {
    ActivityCategory.strength   => AppColors.branchPower,
    ActivityCategory.cardio     => AppColors.orange,
    ActivityCategory.technique  => AppColors.branchTechnique,
    ActivityCategory.mindDefense=> AppColors.branchMind,
    ActivityCategory.combat     => AppColors.redLight,
    ActivityCategory.recovery   => AppColors.success,
  };

  IconData _categoryIcon(ActivityCategory cat) => switch (cat) {
    ActivityCategory.strength   => Icons.fitness_center_rounded,
    ActivityCategory.cardio     => Icons.directions_run_rounded,
    ActivityCategory.technique  => Icons.precision_manufacturing_rounded,
    ActivityCategory.mindDefense=> Icons.psychology_rounded,
    ActivityCategory.combat     => Icons.sports_mma_rounded,
    ActivityCategory.recovery   => Icons.spa_rounded,
  };

  String _categoryName(ActivityCategory cat, dynamic loc) => switch (cat) {
    ActivityCategory.strength   => loc.activityCategoryStrength,
    ActivityCategory.cardio     => loc.activityCategoryCardio,
    ActivityCategory.technique  => loc.activityCategoryTechnique,
    ActivityCategory.mindDefense=> loc.activityCategoryMindDefense,
    ActivityCategory.combat     => loc.activityCategoryCombat,
    ActivityCategory.recovery   => loc.activityCategoryRecovery,
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

class _MiniTag extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniTag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: GoogleFonts.rajdhani(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}