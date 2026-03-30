import '../core/config/training_activities_config.dart';
import 'entities/weekly_plan.dart';

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

  Map<String, dynamic> toMap() => {
    'day': day.index,
    'type': type.index,
    'activityIds': activityIds,
    'isSimulated': isSimulated,
  };

  factory DayPlan.fromMap(Map<String, dynamic> map) => DayPlan(
    day: DayOfWeek.values[map['day'] ?? 0],
    type: DayType.values[map['type'] ?? 0],
    activityIds: List<String>.from(map['activityIds'] ?? []),
    isSimulated: map['isSimulated'] ?? false,
  );
}