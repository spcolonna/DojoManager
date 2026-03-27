import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/use_cases/training/simulate_day_use_case.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';
import '../../widgets/animations/day_advance_animation.dart';

// ─── STATE ────────────────────────────────────────────────────────────────────

class TrainingState {
  final WeeklyPlan plan;
  final DayOfWeek? selectedDay;
  final bool isSimulating;
  final List<DaySimulationResult> completedDays;
  final String? error;

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
  }) =>
      TrainingState(
        plan: plan ?? this.plan,
        selectedDay: clearSelected ? null : selectedDay ?? this.selectedDay,
        isSimulating: isSimulating ?? this.isSimulating,
        completedDays: completedDays ?? this.completedDays,
        error: clearError ? null : error ?? this.error,
      );

  bool isDaySimulated(DayOfWeek day) => plan.days[day]?.isSimulated ?? false;

  DayOfWeek? get currentDay {
    for (final day in DayOfWeek.values) {
      final p = plan.days[day];
      if (p != null && !p.isSimulated && p.type != DayType.tournament) {
        return day;
      }
    }
    return null;
  }
}

// ─── VIEW MODEL ───────────────────────────────────────────────────────────────

class TrainingViewModel extends StateNotifier<TrainingState> {
  final Ref _ref;
  late final SimulateDayUseCase _useCase;

  TrainingViewModel(this._ref)
      : super(TrainingState(
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
    state = state.copyWith(plan: updated);
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
    final plan     = state.plan.days[day]!;

    if (plan.type == DayType.tournament) return null;

    final result = await _useCase.execute(students: students, plan: plan);

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

      // Torneo — parar siempre
      if (plan.type == DayType.tournament) {
        state = state.copyWith(isSimulating: false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              l10n(context).trainingStopped,
              style: GoogleFonts.rajdhani(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFB71C1C),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      // Descanso — marcar como simulado sin calcular
      if (plan.type == DayType.rest) {
        final updatedPlan = state.plan.copyWithDay(
          day,
          plan.copyWith(isSimulated: true),
        );
        state = state.copyWith(plan: updatedPlan);
        continue;
      }

      // Animación del día
      if (context.mounted) {
        await DayAdvanceAnimation.show(
          context,
          dayName: _dayName(day, context),
          onDone: () {},
        );
      }

      await simulateDay(day);
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

// ─── PROVIDER ─────────────────────────────────────────────────────────────────

final trainingViewModelProvider =
StateNotifierProvider<TrainingViewModel, TrainingState>((ref) {
  return TrainingViewModel(ref);
});