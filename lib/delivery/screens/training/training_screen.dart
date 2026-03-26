import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/config/training_activities_config.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/use_cases/training/simulate_day_use_case.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';
import '../../widgets/animations/day_advance_animation.dart';
import '../../widgets/animations/float_label.dart';

// ─── VIEW MODEL ───────────────────────────────────────────────────────────────

class TrainingState {
  final WeeklyPlan plan;
  final DayOfWeek? selectedDay;
  final bool isSimulating;
  final List<DaySimulationResult> completedDays;
  final String? error;

  DayOfWeek? get currentDay {
    for (final day in DayOfWeek.values) {
      final p = plan.days[day];
      if (p != null && !p.isSimulated && p.type != DayType.tournament) {
        return day;
      }
    }
    return null;
  }

  const TrainingState({
    required this.plan,
    this.selectedDay,
    this.isSimulating = false,
    this.completedDays = const [],
    this.error,
  });

  TrainingState copyWith({
    WeeklyPlan? plan,
    DayOfWeek? selectedDay,
    bool? isSimulating,
    List<DaySimulationResult>? completedDays,
    String? error,
    bool clearSelected = false,
    bool clearError = false,
  }) => TrainingState(
    plan: plan ?? this.plan,
    selectedDay: clearSelected ? null : selectedDay ?? this.selectedDay,
    isSimulating: isSimulating ?? this.isSimulating,
    completedDays: completedDays ?? this.completedDays,
    error: clearError ? null : error ?? this.error,
  );

  bool isDaySimulated(DayOfWeek day) =>
      plan.days[day]?.isSimulated ?? false;

  DayOfWeek? get nextUnSimulatedDay {
    for (final day in DayOfWeek.values) {
      final p = plan.days[day];
      if (p != null && !p.isSimulated) return day;
    }
    return null;
  }
}

class TrainingViewModel extends StateNotifier<TrainingState> {
  final Ref _ref;
  late final SimulateDayUseCase _useCase;

  TrainingViewModel(this._ref) : super(TrainingState(
    plan: WeeklyPlan.defaultPlan(season: 1, week: 1),
  )) {
    _useCase = SimulateDayUseCase(FirebaseDojoRepository());
  }

  void selectDay(DayOfWeek day) {
    state = state.copyWith(selectedDay: day);
  }

  void setDayActivities(DayOfWeek day, List<String> activityIds) {
    final updated = state.plan.copyWithDay(
      day,
      state.plan.days[day]!.copyWith(activityIds: activityIds),
    );
    state = state.copyWith(plan: updated, clearSelected: true);
  }

  void setDayType(DayOfWeek day, DayType type) {
    final updated = state.plan.copyWithDay(
      day,
      state.plan.days[day]!.copyWith(type: type),
    );
    state = state.copyWith(plan: updated);
  }

  Future<DaySimulationResult?> simulateDay(DayOfWeek day) async {
    final students = await _ref.read(studentsProvider.future);
    final plan = state.plan.days[day]!;

    if (plan.type == DayType.tournament) return null;

    final result = await _useCase.execute(students: students, plan: plan);

    // Marcar el día como simulado
    final updatedPlan = state.plan.copyWithDay(
      day,
      plan.copyWith(isSimulated: true),
    );

    _ref.invalidate(studentsProvider);

    state = state.copyWith(
      plan: updatedPlan,
      completedDays: [...state.completedDays, result],
    );

    return result;
  }

  Future<void> simulateWeek(BuildContext context) async {
    state = state.copyWith(isSimulating: true);

    for (final day in DayOfWeek.values) {
      final plan = state.plan.days[day];
      if (plan == null || plan.isSimulated) continue;

      // Si es torneo — parar y avisar
      if (plan.type == DayType.tournament) {
        state = state.copyWith(isSimulating: false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n(context).trainingStopped,
                style: GoogleFonts.rajdhani(color: AppColors.textPrimary)),
            backgroundColor: AppColors.redDark,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      // Animación de transición de día
      if (context.mounted) {
        await DayAdvanceAnimation.show(
          context,
          dayName: _dayName(day, context),
          onDone: () {},
        );
      }

      await simulateDay(day);

      // Pequeña pausa entre días para que se sienta progresivo
      await Future.delayed(const Duration(milliseconds: 300));
    }

    state = state.copyWith(isSimulating: false);
  }

  String _dayName(DayOfWeek day, BuildContext ctx) {
    final loc = l10n(ctx);
    return switch (day) {
      DayOfWeek.monday    => loc.dayMonday,
      DayOfWeek.tuesday   => loc.dayTuesday,
      DayOfWeek.wednesday => loc.dayWednesday,
      DayOfWeek.thursday  => loc.dayThursday,
      DayOfWeek.friday    => loc.dayFriday,
      DayOfWeek.saturday  => loc.daySaturday,
      DayOfWeek.sunday    => loc.daySunday,
    };
  }
}

final trainingViewModelProvider =
StateNotifierProvider<TrainingViewModel, TrainingState>((ref) {
  return TrainingViewModel(ref);
});

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc   = l10n(context);
    final state = ref.watch(trainingViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        toolbarHeight: 44,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Text(
          loc.trainingWeekPlanner,
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
      body: Column(
        children: [
          // ── Calendario semanal ────────────────────────────────────
          _WeekCalendar(
            plan: state.plan,
            selectedDay: state.selectedDay,
            currentDay: state.currentDay,
            onDayTap: (day) => ref.read(trainingViewModelProvider.notifier).selectDay(day),
          ),

          const Divider(height: 1, color: AppColors.bgDivider),

          // ── Detalle del día seleccionado ──────────────────────────
          Expanded(
            child: state.selectedDay != null
                ? _DayDetail(
              day: state.selectedDay!,
              plan: state.plan.days[state.selectedDay!]!,
              isSimulated:
              state.isDaySimulated(state.selectedDay!),
            )
                : _EmptyDayHint(),
          ),

          // ── Botones de simulación ─────────────────────────────────
          _SimulationBar(
            state: state,
            onSimulateDay: () async {
              if (state.selectedDay == null) return;
              final day = state.selectedDay!;
              if (state.plan.days[day]?.type == DayType.tournament) {
                return;
              }
              // Animación del día
              await DayAdvanceAnimation.show(
                context,
                dayName: ref
                    .read(trainingViewModelProvider.notifier)
                    ._dayName(day, context),
                onDone: () {},
              );
              final result = await ref
                  .read(trainingViewModelProvider.notifier)
                  .simulateDay(day);
              if (result != null && context.mounted) {
                final total = result.studentResults.fold(
                    0, (s, r) => s + r.phGained);
                if (total > 0) {
                  FloatLabel.show(context, '+$total PH',
                      color: AppColors.goldPrimary);
                }
              }
            },
            onSimulateWeek: () => ref
                .read(trainingViewModelProvider.notifier)
                .simulateWeek(context),
          ),
        ],
      ),
    );
  }
}

// ─── CALENDARIO SEMANAL ───────────────────────────────────────────────────────

class _WeekCalendar extends StatelessWidget {
  final WeeklyPlan plan;
  final DayOfWeek? selectedDay;
  final DayOfWeek? currentDay;    
  final void Function(DayOfWeek) onDayTap;

  const _WeekCalendar({
    required this.plan,
    required this.selectedDay,
    required this.currentDay,      
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: DayOfWeek.values.map((day) {
          final dayPlan      = plan.days[day]!;
          final isSelected   = day == selectedDay;
          final isSimulated  = dayPlan.isSimulated;
          final isCurrentDay = day == currentDay;

          final color = switch (dayPlan.type) {
            DayType.training   => dayPlan.hasActivities
                ? AppColors.success
                : AppColors.textTertiary,
            DayType.rest       => AppColors.info,
            DayType.tournament => AppColors.redAction,
          };

          final shortLabel = switch (day) {
            DayOfWeek.monday    => loc.dayMon,
            DayOfWeek.tuesday   => loc.dayTue,
            DayOfWeek.wednesday => loc.dayWed,
            DayOfWeek.thursday  => loc.dayThu,
            DayOfWeek.friday    => loc.dayFri,
            DayOfWeek.saturday  => loc.daySat,
            DayOfWeek.sunday    => loc.daySun,
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTap(day),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Indicador de tipo / día actual ──────────────
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isCurrentDay && !isSimulated)
                          Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrimary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: isSimulated
                                ? AppColors.success
                                : isCurrentDay
                                ? AppColors.goldPrimary
                                : color.withOpacity(
                                dayPlan.hasActivities ? 1.0 : 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortLabel,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected ? color : AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // ── Etiqueta NEXT ────────────────────────────────
                    if (isCurrentDay && !isSimulated)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'NEXT',
                          style: GoogleFonts.rajdhani(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: AppColors.bgDeep,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 3),
                    // ── Ícono del tipo de día ────────────────────────
                    Icon(
                      switch (dayPlan.type) {
                        DayType.training   => Icons.fitness_center_rounded,
                        DayType.rest       => Icons.hotel_rounded,
                        DayType.tournament => Icons.emoji_events_rounded,
                      },
                      size: 14,
                      color: isSelected ? color : AppColors.textTertiary,
                    ),
                    // ── Número de actividades ────────────────────────
                    if (dayPlan.type == DayType.training &&
                        dayPlan.hasActivities) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${dayPlan.activityIds.length}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 9,
                          color: isSelected ? color : AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── DETALLE DEL DÍA ──────────────────────────────────────────────────────────

class _DayDetail extends ConsumerWidget {
  final DayOfWeek day;
  final DayPlan plan;
  final bool isSimulated;

  const _DayDetail({
    required this.day,
    required this.plan,
    required this.isSimulated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = l10n(context);

    final dayName = switch (day) {
      DayOfWeek.monday    => loc.dayMonday,
      DayOfWeek.tuesday   => loc.dayTuesday,
      DayOfWeek.wednesday => loc.dayWednesday,
      DayOfWeek.thursday  => loc.dayThursday,
      DayOfWeek.friday    => loc.dayFriday,
      DayOfWeek.saturday  => loc.daySaturday,
      DayOfWeek.sunday    => loc.daySunday,
    };

    // Torneo
    if (plan.type == DayType.tournament) {
      return _TournamentDayView(dayName: dayName, loc: loc);
    }

    // Descanso
    if (plan.type == DayType.rest) {
      return _RestDayView(
        dayName: dayName,
        loc: loc,
        onChangeTap: () => ref
            .read(trainingViewModelProvider.notifier)
            .setDayType(day, DayType.training),
      );
    }

    // Entrenamiento
    return _TrainingDayView(
      day: day,
      dayName: dayName,
      plan: plan,
      isSimulated: isSimulated,
      loc: loc,
      onEditTap: () => _showActivityPicker(context, ref, day, plan),
    );
  }

  void _showActivityPicker(
      BuildContext context,
      WidgetRef ref,
      DayOfWeek day,
      DayPlan plan,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityPickerSheet(
        currentIds: plan.activityIds,
        onConfirm: (ids) {
          ref
              .read(trainingViewModelProvider.notifier)
              .setDayActivities(day, ids);
        },
      ),
    );
  }
}

// ─── VISTA DE DÍA DE ENTRENAMIENTO ───────────────────────────────────────────

class _TrainingDayView extends ConsumerWidget {
  final DayOfWeek day;
  final String dayName;
  final DayPlan plan;
  final bool isSimulated;
  final dynamic loc;
  final VoidCallback onEditTap;

  const _TrainingDayView({
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
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded,
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
                      color: AppColors.goldPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.goldPrimary.withOpacity(0.4)),
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
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4)),
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
                  _DayStat(
                    label: loc.trainingDayFatigue,
                    value: '${plan.totalFatigue}%',
                    color: plan.totalFatigue > 60
                        ? AppColors.warning
                        : AppColors.textSecondary,
                    icon: Icons.local_fire_department_rounded,
                  ),
                  _DayStat(
                    label: loc.trainingDayPH,
                    value: '+${plan.totalPH}',
                    color: AppColors.goldPrimary,
                    icon: Icons.psychology_rounded,
                  ),
                  _DayStat(
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
                          color: styleColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded,
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
    ActivityCategory.strength    => Icons.fitness_center_rounded,
    ActivityCategory.cardio      => Icons.directions_run_rounded,
    ActivityCategory.technique   => Icons.precision_manufacturing_rounded,
    ActivityCategory.mindDefense => Icons.psychology_rounded,
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

class _DayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _DayStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.rajdhani(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: GoogleFonts.rajdhani(
                fontSize: 9, color: AppColors.textTertiary, letterSpacing: 0.3)),
      ],
    );
  }
}

// ─── VISTAS DE TORNEO Y DESCANSO ──────────────────────────────────────────────

class _TournamentDayView extends StatelessWidget {
  final String dayName;
  final dynamic loc;
  const _TournamentDayView({required this.dayName, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.redAction.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.redAction.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: AppColors.redLight, size: 36),
            ),
            const SizedBox(height: 16),
            Text(dayName,
                style: GoogleFonts.cinzelDecorative(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.goldLight)),
            const SizedBox(height: 8),
            Text(
              loc.trainingStopped,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestDayView extends StatelessWidget {
  final String dayName;
  final dynamic loc;
  final VoidCallback onChangeTap;
  const _RestDayView({
    required this.dayName,
    required this.loc,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.info.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.hotel_rounded,
                  color: AppColors.infoLight, size: 36),
            ),
            const SizedBox(height: 16),
            Text(dayName,
                style: GoogleFonts.cinzelDecorative(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.goldLight)),
            const SizedBox(height: 8),
            Text(
              loc.trainingDayRest,
              style: GoogleFonts.rajdhani(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onChangeTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldPrimary,
                side: const BorderSide(color: AppColors.bgDivider),
              ),
              child: Text(loc.trainingDayTraining,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '← Select a day to plan',
        style: GoogleFonts.rajdhani(
            fontSize: 14, color: AppColors.textTertiary),
      ),
    );
  }
}

// ─── BARRA DE SIMULACIÓN ──────────────────────────────────────────────────────

class _SimulationBar extends StatelessWidget {
  final TrainingState state;
  final VoidCallback onSimulateDay;
  final VoidCallback onSimulateWeek;

  const _SimulationBar({
    required this.state,
    required this.onSimulateDay,
    required this.onSimulateWeek,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final canSimDay = state.selectedDay != null &&
        !state.isDaySimulated(state.selectedDay!) &&
        state.plan.days[state.selectedDay!]?.type != DayType.tournament;
    final canSimWeek = !state.isSimulating &&
        state.plan.days.values.any((d) => !d.isSimulated);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.bgDivider)),
      ),
      child: Row(
        children: [
          // Simular día
          Expanded(
            child: OutlinedButton(
              onPressed: canSimDay && !state.isSimulating
                  ? onSimulateDay
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldPrimary,
                side: BorderSide(
                  color: canSimDay
                      ? AppColors.goldPrimary.withOpacity(0.5)
                      : AppColors.bgDivider,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                loc.trainingSimulateDay,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Simular semana
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canSimWeek ? onSimulateWeek : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.bgDeep,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: state.isSimulating
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.bgDeep))
                  : Text(
                loc.trainingSimulateWeek,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SELECTOR DE ACTIVIDADES (BOTTOM SHEET) ───────────────────────────────────

class _ActivityPickerSheet extends StatefulWidget {
  final List<String> currentIds;
  final void Function(List<String>) onConfirm;

  const _ActivityPickerSheet({
    required this.currentIds,
    required this.onConfirm,
  });

  @override
  State<_ActivityPickerSheet> createState() => _ActivityPickerSheetState();
}

class _ActivityPickerSheetState extends State<_ActivityPickerSheet> {
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
                          ? AppColors.redAction.withOpacity(0.15)
                          : AppColors.goldPrimary.withOpacity(0.12),
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
                                    ? catColor.withOpacity(0.15)
                                    : atLim
                                    ? AppColors.bgInput.withOpacity(0.3)
                                    : AppColors.bgElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSel
                                      ? catColor
                                      : atLim
                                      ? AppColors.bgDivider.withOpacity(0.3)
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
                                      child: Icon(Icons.check_rounded,
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
    ActivityCategory.strength    => Icons.fitness_center_rounded,
    ActivityCategory.cardio      => Icons.directions_run_rounded,
    ActivityCategory.technique   => Icons.precision_manufacturing_rounded,
    ActivityCategory.mindDefense => Icons.psychology_rounded,
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