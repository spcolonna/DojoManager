import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../entities/student.dart';
import '../../entities/dojo.dart';
import '../../repositories/i_student_repository.dart';
import '../../repositories/i_dojo_repository.dart';
import '../../../core/config/training_config.dart';
import '../../../core/config/xp_config.dart';
import '../../../core/config/economy_config.dart';

class WeekSimulationResult {
  final List<StudentWeekResult> studentResults;
  final int mdEarned;
  final Dojo updatedDojo;

  const WeekSimulationResult({
    required this.studentResults,
    required this.mdEarned,
    required this.updatedDojo,
  });
}

class StudentWeekResult {
  final String studentId;
  final int xpGained;
  final int phGained;
  final int newFatigue;
  final bool gotInjured;
  final Map<String, int> statGains; // stat → puntos ganados

  const StudentWeekResult({
    required this.studentId,
    required this.xpGained,
    required this.phGained,
    required this.newFatigue,
    required this.gotInjured,
    required this.statGains,
  });
}

class SimulateWeekUseCase {
  final IStudentRepository _studentRepo;
  final IDojoRepository _dojoRepo;
  final Random _rng = Random();

  SimulateWeekUseCase(this._studentRepo, this._dojoRepo);

  Future<Either<String, WeekSimulationResult>> execute({
    required Dojo dojo,
    required Map<String, String> planByStudentId, // studentId → planId
  }) async {
    final studentsResult = await _studentRepo.getStudentsByDojo(dojo.id);
    if (studentsResult.isLeft()) return const Left('students_fetch_error');

    final students = studentsResult.getOrElse(() => []);
    final results = <StudentWeekResult>[];
    int totalMD = EconomyConfig.mdPerTrainingWeek;

    final xpMultiplier = dojo.unlockedUpgradeIds.contains('martial_library')
        ? 1.0 + XPConfig.martialLibraryXPBonus
        : 1.0;

    for (final student in students) {
      final planId = planByStudentId[student.id] ?? 'balanced';
      final plan = TrainingConfig.plans[planId];
      if (plan == null) continue;

      // Injury check
      bool gotInjured = false;
      if (plan.injuryRiskPercent > 0) {
        gotInjured = _rng.nextInt(100) < plan.injuryRiskPercent;
      }

      final xpGained = (XPConfig.xpPerTrainingDayCompleted * 5 * xpMultiplier).toInt()
          + plan.extraXP;
      final phGained = plan.phGained;
      final newFatigue = gotInjured
          ? 100
          : (student.fatiguePercent + plan.fatiguePercent).clamp(0, 100);

      // Stat gains (simplificado: distribuye PH en stats según el plan)
      final statGains = _calculateStatGains(plan, student);

      // Actualizar estudiante
      var updatedStats = student.stats;
      statGains.forEach((stat, gain) {
        switch (stat) {
          case 'str': updatedStats = updatedStats.copyWith(str: updatedStats.str + gain); break;
          case 'spd': updatedStats = updatedStats.copyWith(spd: updatedStats.spd + gain); break;
          case 'tec': updatedStats = updatedStats.copyWith(tec: updatedStats.tec + gain); break;
          case 'def': updatedStats = updatedStats.copyWith(def: updatedStats.def + gain); break;
          case 'men': updatedStats = updatedStats.copyWith(men: updatedStats.men + gain); break;
        }
      });

      final updatedStudent = student.copyWith(
        stats: updatedStats,
        currentXP: student.currentXP + xpGained,
        skillPoints: student.skillPoints + phGained,
        fatiguePercent: plan.resetsWeeklyFatigue ? 0 : newFatigue,
        isInjured: gotInjured ? true : student.isInjured,
        injuryWeeksRemaining: gotInjured ? 2 : student.injuryWeeksRemaining,
      );

      await _studentRepo.saveStudent(updatedStudent);

      results.add(StudentWeekResult(
        studentId: student.id,
        xpGained: xpGained,
        phGained: phGained,
        newFatigue: newFatigue,
        gotInjured: gotInjured,
        statGains: statGains,
      ));
    }

    // Avanzar semana del dojo
    final nextWeek = dojo.currentWeek + 1;
    final updatedDojo = dojo.copyWith(
      currentWeek: nextWeek,
      md: dojo.md + totalMD,
    );
    await _dojoRepo.saveDojo(updatedDojo);

    return Right(WeekSimulationResult(
      studentResults: results,
      mdEarned: totalMD,
      updatedDojo: updatedDojo,
    ));
  }

  Map<String, int> _calculateStatGains(TrainingPlanDefinition plan, Student student) {
    // Distribución según plan (simplificada para MVP)
    switch (plan.id) {
      case 'intense':
        return {'str': 2, 'spd': 1}; // el jugador elige en la UI — aquí por defecto
      case 'balanced':
        return {'str': 1, 'spd': 1, 'tec': 1, 'def': 1, 'men': 1};
      case 'technical':
        return {'tec': 2, 'men': 1};
      case 'recovery':
        return {};
      case 'sparring':
        final stats = ['str', 'spd', 'tec', 'def', 'men'];
        final s1 = stats[_rng.nextInt(5)];
        var s2 = stats[_rng.nextInt(5)];
        while (s2 == s1) s2 = stats[_rng.nextInt(5)];
        return {s1: 1, s2: 1};
      case 'intensive_plus':
        return {'str': 3, 'spd': 2};
      case 'master_session':
        return {'tec': 4, 'men': 3};
      default:
        return {'str': 1, 'spd': 1};
    }
  }
}
