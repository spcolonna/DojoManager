import 'dart:math';
import '../../entities/student.dart';
import '../../entities/weekly_plan.dart';
import '../../value_objects/belt.dart';
import '../../../core/config/training_activities_config.dart';
import '../../../core/config/xp_config.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';

class DaySimulationResult {
  final DayOfWeek day;
  final List<StudentDayResult> studentResults;
  final List<String> activitiesSimulated;
  final bool wasTournamentDay;

  const DaySimulationResult({
    required this.day,
    required this.studentResults,
    required this.activitiesSimulated,
    required this.wasTournamentDay,
  });

  int get totalPH  => studentResults.fold(0, (s, r) => s + r.phGained);
  int get totalXP  => studentResults.fold(0, (s, r) => s + r.xpGained);
}

class StudentDayResult {
  final String studentId;
  final String studentName;
  final int phGained;
  final int xpGained;
  final int newFatigue;
  final Map<String, int> statGains;
  final bool leveledUp;
  final Belt? newBelt;

  const StudentDayResult({
    required this.studentId,
    required this.studentName,
    required this.phGained,
    required this.xpGained,
    required this.newFatigue,
    required this.statGains,
    required this.leveledUp,
    this.newBelt,
  });
}

class SimulateDayUseCase {
  final FirebaseDojoRepository _repo;
  final Random _rng = Random();

  SimulateDayUseCase(this._repo);

  Future<DaySimulationResult> execute({
    required List<Student> students,
    required DayPlan plan,
  }) async {
    // Si es torneo o descanso no simulamos actividades
    if (plan.type == DayType.tournament) {
      return DaySimulationResult(
        day: plan.day,
        studentResults: [],
        activitiesSimulated: [],
        wasTournamentDay: true,
      );
    }

    final activities = plan.activityIds
        .map((id) => TrainingActivitiesConfig.byId(id))
        .whereType<TrainingActivity>()
        .toList();

    // Todos los estudiantes reciben el mismo entrenamiento
    final studentResults = <StudentDayResult>[];

    for (final student in students) {
      final statGains = <String, int>{};
      int fatigue = 0;
      int ph = 0;
      int xp = TrainingActivitiesConfig.baseXPPerActivity;

      for (final act in activities) {
        act.statBonus.forEach((stat, val) {
          statGains[stat] = (statGains[stat] ?? 0) + val;
        });
        fatigue += act.fatigueAdd;
        ph      += act.totalPH;
        xp      += act.xpBonus;
      }

      // Si es día de descanso, recupera fatiga
      if (plan.type == DayType.rest) {
        fatigue = -20;
        ph = 0;
        xp = 0;
      }

      final newFatigue = (student.fatiguePercent + fatigue).clamp(0, 100);

      // XP y subida de nivel
      int newXP = student.currentXP + xp;
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
        skillPoints: student.skillPoints + ph,
        fatiguePercent: newFatigue as int,
      );

      await _repo.updateStudent(updated);

      studentResults.add(StudentDayResult(
        studentId: student.id,
        studentName: student.nameKey,
        phGained: ph,
        xpGained: xp,
        newFatigue: newFatigue as int,
        statGains: statGains,
        leveledUp: leveledUp,
        newBelt: leveledUp ? belt : null,
      ));
    }

    return DaySimulationResult(
      day: plan.day,
      studentResults: studentResults,
      activitiesSimulated: plan.activityIds,
      wasTournamentDay: false,
    );
  }
}