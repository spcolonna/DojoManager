import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/delivery/screens/training/simulation_bar.dart';
import 'package:grand_dojo/delivery/screens/training/training_view_model.dart';
import 'package:grand_dojo/delivery/screens/training/week_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/use_cases/training/simulate_day_use_case.dart';
import '../../widgets/animations/day_advance_animation.dart';
import '../../widgets/animations/float_label.dart';
import 'day_detail.dart';
import 'empty_day_hint.dart';

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
      if (p == null || p.isSimulated) continue;
      if (p.type != DayType.rest) return day;
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
          WeekCalendar(
            plan: state.plan,
            selectedDay: state.selectedDay,
            currentDay: state.currentDay,
            onDayTap: (day) => ref.read(trainingViewModelProvider.notifier).selectDay(day),
          ),

          const Divider(height: 1, color: AppColors.bgDivider),

          // ── Detalle del día seleccionado ──────────────────────────
          Expanded(
            child: state.selectedDay != null
                ? DayDetail(
              day: state.selectedDay!,
              plan: state.plan.days[state.selectedDay!]!,
              isSimulated:
              state.isDaySimulated(state.selectedDay!),
            )
                : EmptyDayHint(),
          ),

          // ── Botones de simulación ─────────────────────────────────
          SimulationBar(
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
                dayName: switch (day) {
                  DayOfWeek.monday    => loc.dayMonday,
                  DayOfWeek.tuesday   => loc.dayTuesday,
                  DayOfWeek.wednesday => loc.dayWednesday,
                  DayOfWeek.thursday  => loc.dayThursday,
                  DayOfWeek.friday    => loc.dayFriday,
                  DayOfWeek.saturday  => loc.daySaturday,
                  DayOfWeek.sunday    => loc.daySunday,
                },
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
            onGoToTournament: () {
              ref.read(navigationProvider.notifier).state = 2;
            },
          ),
        ],
      ),
    );
  }
}