/// Actividades individuales de entrenamiento.
/// Cada actividad afecta stats específicos, tiene un costo de fatiga y un
/// costo opcional en MD o GM.
/// Para agregar una actividad nueva: solo agregar una entrada aquí.
class TrainingActivitiesConfig {
  TrainingActivitiesConfig._();

  static const List<TrainingActivity> activities = [

    // ── FUERZA ────────────────────────────────────────────────────────────────
    TrainingActivity(
      id: 'push_ups',
      titleKey: 'activity_push_ups',
      descKey: 'activity_push_ups_desc',
      category: ActivityCategory.strength,
      icon: 'fitness_center',
      statBonus: {'str': 2},
      fatigueAdd: 12,
    ),
    TrainingActivity(
      id: 'planks',
      titleKey: 'activity_planks',
      descKey: 'activity_planks_desc',
      category: ActivityCategory.strength,
      icon: 'fitness_center',
      statBonus: {'str': 1, 'def': 1},
      fatigueAdd: 8,
    ),
    TrainingActivity(
      id: 'abs',
      titleKey: 'activity_abs',
      descKey: 'activity_abs_desc',
      category: ActivityCategory.strength,
      icon: 'fitness_center',
      statBonus: {'str': 1, 'res': 1},
      fatigueAdd: 10,
    ),
    TrainingActivity(
      id: 'weight_training',
      titleKey: 'activity_weight_training',
      descKey: 'activity_weight_training_desc',
      category: ActivityCategory.strength,
      icon: 'fitness_center',
      statBonus: {'str': 3},
      fatigueAdd: 20,
      phBonus: 3,
    ),

    // ── VELOCIDAD / CARDIO ─────────────────────────────────────────────────────
    TrainingActivity(
      id: 'running',
      titleKey: 'activity_running',
      descKey: 'activity_running_desc',
      category: ActivityCategory.cardio,
      icon: 'directions_run',
      statBonus: {'spd': 2, 'res': 1},
      fatigueAdd: 15,
    ),
    TrainingActivity(
      id: 'jump_rope',
      titleKey: 'activity_jump_rope',
      descKey: 'activity_jump_rope_desc',
      category: ActivityCategory.cardio,
      icon: 'directions_run',
      statBonus: {'spd': 2},
      fatigueAdd: 12,
    ),
    TrainingActivity(
      id: 'sprints',
      titleKey: 'activity_sprints',
      descKey: 'activity_sprints_desc',
      category: ActivityCategory.cardio,
      icon: 'directions_run',
      statBonus: {'spd': 3},
      fatigueAdd: 20,
      phBonus: 2,
    ),

    // ── TÉCNICA ───────────────────────────────────────────────────────────────
    TrainingActivity(
      id: 'kata',
      titleKey: 'activity_kata',
      descKey: 'activity_kata_desc',
      category: ActivityCategory.technique,
      icon: 'self_improvement',
      statBonus: {'tec': 2, 'men': 1},
      fatigueAdd: 8,
    ),
    TrainingActivity(
      id: 'shadow_combat',
      titleKey: 'activity_shadow_combat',
      descKey: 'activity_shadow_combat_desc',
      category: ActivityCategory.technique,
      icon: 'self_improvement',
      statBonus: {'tec': 2, 'spd': 1},
      fatigueAdd: 14,
    ),
    TrainingActivity(
      id: 'bag_work',
      titleKey: 'activity_bag_work',
      descKey: 'activity_bag_work_desc',
      category: ActivityCategory.technique,
      icon: 'sports_mma',
      statBonus: {'tec': 1, 'str': 1},
      fatigueAdd: 16,
    ),
    TrainingActivity(
      id: 'technique_drills',
      titleKey: 'activity_technique_drills',
      descKey: 'activity_technique_drills_desc',
      category: ActivityCategory.technique,
      icon: 'self_improvement',
      statBonus: {'tec': 3},
      fatigueAdd: 10,
      phBonus: 3,
    ),

    // ── DEFENSA / MENTE ───────────────────────────────────────────────────────
    TrainingActivity(
      id: 'postures',
      titleKey: 'activity_postures',
      descKey: 'activity_postures_desc',
      category: ActivityCategory.mindDefense,
      icon: 'accessibility_new',
      statBonus: {'def': 2},
      fatigueAdd: 6,
    ),
    TrainingActivity(
      id: 'meditation',
      titleKey: 'activity_meditation',
      descKey: 'activity_meditation_desc',
      category: ActivityCategory.mindDefense,
      icon: 'self_improvement',
      statBonus: {'men': 2},
      fatigueAdd: 4,
    ),
    TrainingActivity(
      id: 'breathing',
      titleKey: 'activity_breathing',
      descKey: 'activity_breathing_desc',
      category: ActivityCategory.mindDefense,
      icon: 'air',
      statBonus: {'men': 1, 'res': 1},
      fatigueAdd: 3,
    ),
    TrainingActivity(
      id: 'guard_drills',
      titleKey: 'activity_guard_drills',
      descKey: 'activity_guard_drills_desc',
      category: ActivityCategory.mindDefense,
      icon: 'shield',
      statBonus: {'def': 3},
      fatigueAdd: 12,
      phBonus: 2,
    ),

    // ── COMBATE ───────────────────────────────────────────────────────────────
    TrainingActivity(
      id: 'sparring',
      titleKey: 'activity_sparring',
      descKey: 'activity_sparring_desc',
      category: ActivityCategory.combat,
      icon: 'sports_kabaddi',
      statBonus: {'str': 1, 'spd': 1, 'tec': 1},
      fatigueAdd: 25,
      phBonus: 4,
      xpBonus: 20,
    ),
    TrainingActivity(
      id: 'controlled_combat',
      titleKey: 'activity_controlled_combat',
      descKey: 'activity_controlled_combat_desc',
      category: ActivityCategory.combat,
      icon: 'sports_kabaddi',
      statBonus: {'tec': 2, 'men': 1},
      fatigueAdd: 18,
      phBonus: 3,
      xpBonus: 12,
    ),
    TrainingActivity(
      id: 'strategy_session',
      titleKey: 'activity_strategy_session',
      descKey: 'activity_strategy_session_desc',
      category: ActivityCategory.combat,
      icon: 'psychology',
      statBonus: {'men': 3},
      fatigueAdd: 8,
      phBonus: 3,
    ),

    // ── RECUPERACIÓN ──────────────────────────────────────────────────────────
    TrainingActivity(
      id: 'stretching',
      titleKey: 'activity_stretching',
      descKey: 'activity_stretching_desc',
      category: ActivityCategory.recovery,
      icon: 'accessibility_new',
      statBonus: {},
      fatigueAdd: -15,  // negativo = reduce fatiga
    ),
    TrainingActivity(
      id: 'ice_bath',
      titleKey: 'activity_ice_bath',
      descKey: 'activity_ice_bath_desc',
      category: ActivityCategory.recovery,
      icon: 'ac_unit',
      statBonus: {},
      fatigueAdd: -20,
    ),
    TrainingActivity(
      id: 'rest',
      titleKey: 'activity_rest',
      descKey: 'activity_rest_desc',
      category: ActivityCategory.recovery,
      icon: 'hotel',
      statBonus: {},
      fatigueAdd: -30,
    ),
  ];

  // ── LÍMITES DE LA SEMANA ──────────────────────────────────────────────────
  static const int maxActivitiesPerWeek   = 5;
  static const int fatigueInjuryThreshold = 85;
  static const int injuryRiskPercent      = 8;
  static const int basePHPerActivity      = 1;
  static const int baseXPPerActivity      = 8;

  // ── HELPERS ───────────────────────────────────────────────────────────────
  static List<TrainingActivity> byCategory(ActivityCategory cat) =>
      activities.where((a) => a.category == cat).toList();

  static TrainingActivity? byId(String id) {
    try {
      return activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ─── ENUMS Y DATA CLASS ───────────────────────────────────────────────────────

enum ActivityCategory {
  strength,
  cardio,
  technique,
  mindDefense,
  combat,
  recovery,
}

class TrainingActivity {
  final String id;
  final String titleKey;
  final String descKey;
  final ActivityCategory category;
  final String icon;           // nombre del MaterialIcon
  final Map<String, int> statBonus; // stat → puntos
  final int fatigueAdd;        // puede ser negativo (recupera fatiga)
  final int phBonus;           // PH extra además del base
  final int xpBonus;           // XP extra

  const TrainingActivity({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.category,
    required this.icon,
    required this.statBonus,
    required this.fatigueAdd,
    this.phBonus = 0,
    this.xpBonus = 0,
  });

  /// Fatiga total que genera esta actividad (puede ser negativa).
  int get totalFatigue => fatigueAdd;

  /// PH totales que otorga esta actividad.
  int get totalPH => TrainingActivitiesConfig.basePHPerActivity + phBonus;

  /// XP totales que otorga esta actividad.
  int get totalXP => TrainingActivitiesConfig.baseXPPerActivity + xpBonus;
}