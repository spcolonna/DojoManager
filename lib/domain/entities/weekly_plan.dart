import '../../core/config/training_activities_config.dart';

/// Plan semanal del dojo.
/// Cada día tiene una lista de actividades que entrenan TODOS los estudiantes.
/// El sábado/domingo pueden tener torneo en lugar de entrenamiento.
class WeeklyPlan {
  final int season;
  final int week;
  final Map<DayOfWeek, DayPlan> days;

  const WeeklyPlan({
    required this.season,
    required this.week,
    required this.days,
  });

  DayPlan? planFor(DayOfWeek day) => days[day];

  bool get hasTrainingDays =>
      days.values.any((d) => d.type == DayType.training);

  bool get hasTournament =>
      days.values.any((d) => d.type == DayType.tournament);

  DayOfWeek? get tournamentDay =>
      days.entries
          .where((e) => e.value.type == DayType.tournament)
          .map((e) => e.key)
          .firstOrNull;

  WeeklyPlan copyWithDay(DayOfWeek day, DayPlan plan) {
    return WeeklyPlan(
      season: season,
      week: week,
      days: {...days, day: plan},
    );
  }

  // Plan vacío por defecto — lunes a viernes libre, sábado torneo
  factory WeeklyPlan.defaultPlan({required int season, required int week}) {
    return WeeklyPlan(
      season: season,
      week: week,
      days: {
        DayOfWeek.monday:    DayPlan.empty(DayOfWeek.monday),
        DayOfWeek.tuesday:   DayPlan.empty(DayOfWeek.tuesday),
        DayOfWeek.wednesday: DayPlan.empty(DayOfWeek.wednesday),
        DayOfWeek.thursday:  DayPlan.empty(DayOfWeek.thursday),
        DayOfWeek.friday:    DayPlan.empty(DayOfWeek.friday),
        DayOfWeek.saturday:  DayPlan.tournament(DayOfWeek.saturday),
        DayOfWeek.sunday:    DayPlan.rest(DayOfWeek.sunday),
      },
    );
  }
}

class DayPlan {
  final DayOfWeek day;
  final DayType type;
  final List<String> activityIds; // mismas actividades para TODOS los estudiantes
  final bool isSimulated;

  const DayPlan({
    required this.day,
    required this.type,
    this.activityIds = const [],
    this.isSimulated = false,
  });

  factory DayPlan.empty(DayOfWeek day) =>
      DayPlan(day: day, type: DayType.training);

  factory DayPlan.rest(DayOfWeek day) =>
      DayPlan(day: day, type: DayType.rest);

  factory DayPlan.tournament(DayOfWeek day) =>
      DayPlan(day: day, type: DayType.tournament);

  bool get hasActivities => activityIds.isNotEmpty;

  DayPlan copyWith({
    List<String>? activityIds,
    DayType? type,
    bool? isSimulated,
  }) => DayPlan(
    day: day,
    type: type ?? this.type,
    activityIds: activityIds ?? this.activityIds,
    isSimulated: isSimulated ?? this.isSimulated,
  );

  // Calcular fatiga total del día
  int get totalFatigue {
    if (type != DayType.training) return 0;
    return activityIds.fold(0, (sum, id) {
      final act = TrainingActivitiesConfig.byId(id);
      return sum + (act?.fatigueAdd ?? 0);
    });
  }

  // PH total del día
  int get totalPH {
    if (type != DayType.training) return 0;
    return activityIds.fold(0, (sum, id) {
      final act = TrainingActivitiesConfig.byId(id);
      return sum + (act?.totalPH ?? 0);
    });
  }

  // XP total del día
  int get totalXP {
    if (type != DayType.training) return 0;
    return activityIds.fold(
      TrainingActivitiesConfig.baseXPPerActivity,
          (sum, id) {
        final act = TrainingActivitiesConfig.byId(id);
        return sum + (act?.xpBonus ?? 0);
      },
    );
  }
}

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum DayType { training, rest, tournament }

extension DayOfWeekExt on DayOfWeek {
  String get labelKey => switch (this) {
    DayOfWeek.monday    => 'day_monday',
    DayOfWeek.tuesday   => 'day_tuesday',
    DayOfWeek.wednesday => 'day_wednesday',
    DayOfWeek.thursday  => 'day_thursday',
    DayOfWeek.friday    => 'day_friday',
    DayOfWeek.saturday  => 'day_saturday',
    DayOfWeek.sunday    => 'day_sunday',
  };

  String get shortKey => switch (this) {
    DayOfWeek.monday    => 'day_mon',
    DayOfWeek.tuesday   => 'day_tue',
    DayOfWeek.wednesday => 'day_wed',
    DayOfWeek.thursday  => 'day_thu',
    DayOfWeek.friday    => 'day_fri',
    DayOfWeek.saturday  => 'day_sat',
    DayOfWeek.sunday    => 'day_sun',
  };

  bool get isWeekend => this == DayOfWeek.saturday || this == DayOfWeek.sunday;
}