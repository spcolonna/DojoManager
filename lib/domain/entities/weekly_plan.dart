import '../../core/config/tournament_config.dart';
import '../day_plan.dart';

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
  factory WeeklyPlan.defaultPlan({
    required int season,
    required int week,
  }) {
    final hasCopa = TournamentConfig.hasInterStyleCup(week);
    final copaDayIndex = TournamentConfig.interStyleDayForWeek(week);
    // 0=lunes, 1=martes, 2=miércoles, 3=jueves
    final copaDay = DayOfWeek.values[copaDayIndex];

    return WeeklyPlan(
      season: season,
      week: week,
      days: {
        DayOfWeek.monday: hasCopa && copaDay == DayOfWeek.monday
            ? DayPlan.tournament(DayOfWeek.monday)
            : DayPlan.empty(DayOfWeek.monday),
        DayOfWeek.tuesday: hasCopa && copaDay == DayOfWeek.tuesday
            ? DayPlan.tournament(DayOfWeek.tuesday)
            : DayPlan.empty(DayOfWeek.tuesday),
        DayOfWeek.wednesday: hasCopa && copaDay == DayOfWeek.wednesday
            ? DayPlan.tournament(DayOfWeek.wednesday)
            : DayPlan.empty(DayOfWeek.wednesday),
        DayOfWeek.thursday: hasCopa && copaDay == DayOfWeek.thursday
            ? DayPlan.tournament(DayOfWeek.thursday)
            : DayPlan.empty(DayOfWeek.thursday),
        DayOfWeek.friday:    DayPlan.empty(DayOfWeek.friday),
        DayOfWeek.saturday:  DayPlan.tournament(DayOfWeek.saturday), // liga local siempre
        DayOfWeek.sunday:    DayPlan.rest(DayOfWeek.sunday),
      },
    );
  }

  Map<String, dynamic> toMap() => {
    'season': season,
    'week': week,
    'days': days.map((k, v) => MapEntry(k.index.toString(), v.toMap())),
  };

  factory WeeklyPlan.fromMap(Map<String, dynamic> map) {
    final daysMap = map['days'] as Map<String, dynamic>? ?? {};
    final days = <DayOfWeek, DayPlan>{};
    for (final entry in daysMap.entries) {
      final dayIndex = int.tryParse(entry.key);
      if (dayIndex != null && dayIndex < DayOfWeek.values.length) {
        final day = DayOfWeek.values[dayIndex];
        days[day] = DayPlan.fromMap(entry.value as Map<String, dynamic>);
      }
    }
    // Completar días faltantes con defaults
    for (final day in DayOfWeek.values) {
      days.putIfAbsent(day, () => day == DayOfWeek.saturday
          ? DayPlan.tournament(day)
          : day == DayOfWeek.sunday
          ? DayPlan.rest(day)
          : DayPlan.empty(day));
    }
    return WeeklyPlan(
      season: map['season'] ?? 1,
      week: map['week'] ?? 1,
      days: days,
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