import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/delivery/screens/training/training_screen.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/use_cases/training/simulate_day_use_case.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';
import '../../widgets/animations/day_advance_animation.dart';

class TrainingViewModel extends StateNotifier<TrainingState> {
  final Ref _ref;
  late final SimulateDayUseCase _useCase;
  final _repo = FirebaseDojoRepository();

  TrainingViewModel(this._ref)
      : super(TrainingState(
    plan: WeeklyPlan.defaultPlan(season: 1, week: 1),
  )) {
    _useCase = SimulateDayUseCase(FirebaseDojoRepository());
    _loadPlan();
  }

  // ── Cargar plan desde Firestore al iniciar ────────────────────────────────
  Future<void> _loadPlan() async {
    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) return;

    final saved = await _repo.getWeeklyPlan(dojo.id);
    if (saved != null) {
      // Si el plan guardado es de otra semana, generar uno nuevo
      if (saved.season == dojo.currentSeason &&
          saved.week == dojo.currentWeek) {
        state = state.copyWith(plan: saved);
        return;
      }
    }

    // Plan nuevo para esta semana
    final fresh = WeeklyPlan.defaultPlan(
      season: dojo.currentSeason,
      week: dojo.currentWeek,
    );
    state = state.copyWith(plan: fresh);
    await _repo.saveWeeklyPlan(dojo.id, fresh);
  }

  // ── Guardar plan en Firestore ─────────────────────────────────────────────
  Future<void> _persistPlan(WeeklyPlan plan) async {
    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) return;
    await _repo.saveWeeklyPlan(dojo.id, plan);
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
    _persistPlan(updated);
  }

  void setDayType(DayOfWeek day, DayType type) {
    final updated = state.plan.copyWithDay(
      day,
      state.plan.days[day]!.copyWith(type: type),
    );
    state = state.copyWith(plan: updated);
    _persistPlan(updated);
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

    // Persistir después de cada día simulado
    await _persistPlan(updatedPlan);

    return result;
  }

  Future<void> simulateWeek(BuildContext context) async {
    state = state.copyWith(isSimulating: true);

    for (final day in DayOfWeek.values) {
      final plan = state.plan.days[day];
      if (plan == null || plan.isSimulated) continue;

      // ── Torneo — SIEMPRE parar, sin importar nada ──────────────────────
      if (plan.type == DayType.tournament) {
        state = state.copyWith(
          isSimulating: false,
          selectedDay: day,  // seleccionar el día del torneo
        );
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
        return;  // ← corta el loop completamente
      }

      // ── Descanso — marcar sin simular ──────────────────────────────────
      if (plan.type == DayType.rest) {
        final updatedPlan = state.plan.copyWithDay(
          day,
          plan.copyWith(isSimulated: true),
        );
        state = state.copyWith(plan: updatedPlan);
        await _persistPlan(updatedPlan);
        continue;
      }

      // ── Entrenamiento — animar y simular ───────────────────────────────
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

  /// Marcar el día de torneo como completado (llamar después de simular el combate)
  Future<void> markTournamentDayComplete() async {
    final tournamentDay = state.plan.tournamentDay;
    if (tournamentDay == null) return;

    final updatedPlan = state.plan.copyWithDay(
      tournamentDay,
      state.plan.days[tournamentDay]!.copyWith(isSimulated: true),
    );
    state = state.copyWith(plan: updatedPlan);
    await _persistPlan(updatedPlan);
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