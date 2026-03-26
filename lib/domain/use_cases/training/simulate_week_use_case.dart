import 'dart:math';
import '../../entities/student.dart';
import '../../value_objects/belt.dart';
import '../../../core/config/training_activities_config.dart';
import '../../../core/config/xp_config.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';

class WeekSimulationResult {
  final String studentId;
  final String studentName;
  final int phGained;
  final int xpGained;
  final int newFatigue;
  final bool leveledUp;
  final Belt? newBelt;
  final bool injured;
  final Map<String, int> statGains; // stat → puntos ganados

  const WeekSimulationResult({
    required this.studentId,
    required this.studentName,
    required this.phGained,
    required this.xpGained,
    required this.newFatigue,
    required this.leveledUp,
    this.newBelt,
    required this.injured,
    required this.statGains,
  });
}

class SimulateWeekUseCase {
  final FirebaseDojoRepository _repo;
  final Random _rng = Random();

  SimulateWeekUseCase(this._repo);

  Future<List<WeekSimulationResult>> execute({
    required List<Student> students,
    required Map<String, List<String>> activitiesByStudentId,
    required String dojoId,
  }) async {
    final results = <WeekSimulationResult>[];

    for (final student in students) {
      final activityIds = activitiesByStudentId[student.id] ?? [];

      // Resolver actividades seleccionadas
      final activities = activityIds
          .map((id) => TrainingActivitiesConfig.byId(id))
          .whereType<TrainingActivity>()
          .toList();

      // Si no eligió nada → plan equilibrado por defecto
      if (activities.isEmpty) {
        results.add(await _simulateDefault(student));
        continue;
      }

      // Acumular stats, fatiga, PH y XP
      final statGains  = <String, int>{};
      int totalFatigue = 0;
      int totalPH      = 0;
      int totalXP      = XPConfig.xpPerTrainingDayCompleted * 5;

      for (final activity in activities) {
        activity.statBonus.forEach((stat, val) {
          statGains[stat] = (statGains[stat] ?? 0) + val;
        });
        totalFatigue += activity.fatigueAdd;
        totalPH      += activity.totalPH;
        totalXP      += activity.xpBonus;
      }

      final newFatigue = (student.fatiguePercent + totalFatigue).clamp(0, 100);
      final injured = newFatigue >= TrainingActivitiesConfig.fatigueInjuryThreshold &&
          _rng.nextInt(100) < TrainingActivitiesConfig.injuryRiskPercent;

      // XP → subida de nivel
      int newXP = student.currentXP + totalXP;
      Belt currentBelt = student.belt;
      bool leveledUp   = false;

      while (currentBelt.level < 10 &&
          newXP >= currentBelt.xpRequiredForNextLevel) {
        newXP -= currentBelt.xpRequiredForNextLevel;
        currentBelt = currentBelt.next;
        leveledUp = true;
      }

      // Guardar en Firestore
      final updated = student.copyWith(
        currentXP: newXP,
        belt: currentBelt,
        skillPoints: student.skillPoints + totalPH,
        fatiguePercent: newFatigue as int,
        isInjured: injured,
        injuryWeeksRemaining: injured ? 1 : student.injuryWeeksRemaining,
      );

      await _repo.updateStudent(updated);

      results.add(WeekSimulationResult(
        studentId: student.id,
        studentName: student.nameKey,
        phGained: totalPH,
        xpGained: totalXP,
        newFatigue: newFatigue as int,
        leveledUp: leveledUp,
        newBelt: leveledUp ? currentBelt : null,
        injured: injured,
        statGains: statGains,
      ));
    }

    return results;
  }

  Future<WeekSimulationResult> _simulateDefault(Student student) async {
    const defaultPH  = 5;
    const defaultXP  = 75;
    const defaultFat = 20;

    final newFatigue = (student.fatiguePercent + defaultFat).clamp(0, 100);
    int newXP = student.currentXP + defaultXP;
    Belt belt = student.belt;
    bool leveledUp = false;

    while (belt.level < 10 && newXP >= belt.xpRequiredForNextLevel) {
      newXP -= belt.xpRequiredForNextLevel;
      belt = belt.next;
      leveledUp = true;
    }

    final updated = student.copyWith(
      currentXP: newXP,
      belt: belt,
      skillPoints: student.skillPoints + defaultPH,
      fatiguePercent: newFatigue as int,
    );
    await _repo.updateStudent(updated);

    return WeekSimulationResult(
      studentId: student.id,
      studentName: student.nameKey,
      phGained: defaultPH,
      xpGained: defaultXP,
      newFatigue: newFatigue as int,
      leveledUp: leveledUp,
      newBelt: leveledUp ? belt : null,
      injured: false,
      statGains: {'str': 1, 'spd': 1, 'tec': 1, 'def': 1, 'men': 1},
    );
  }
}