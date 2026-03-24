/// Planes de entrenamiento: definiciones, costos y efectos.
class TrainingConfig {
  TrainingConfig._();

  // PH ganados por plan (ver detalle en cada TrainingPlanDefinition)
  static const Map<String, TrainingPlanDefinition> plans = {
    'intense': TrainingPlanDefinition(
      id: 'intense',
      titleKey: 'training_plan_intense_title',
      descKey: 'training_plan_intense_desc',
      phGained: 8,
      fatiguePercent: 70,
      costMD: 0,
      costGM: 0,
      focusedAttributeCount: 2,
    ),
    'balanced': TrainingPlanDefinition(
      id: 'balanced',
      titleKey: 'training_plan_balanced_title',
      descKey: 'training_plan_balanced_desc',
      phGained: 10,
      fatiguePercent: 40,
      costMD: 0,
      costGM: 0,
    ),
    'technical': TrainingPlanDefinition(
      id: 'technical',
      titleKey: 'training_plan_technical_title',
      descKey: 'training_plan_technical_desc',
      phGained: 6,
      fatiguePercent: 30,
      costMD: 0,
      costGM: 0,
    ),
    'recovery': TrainingPlanDefinition(
      id: 'recovery',
      titleKey: 'training_plan_recovery_title',
      descKey: 'training_plan_recovery_desc',
      phGained: 0,
      fatiguePercent: 0,
      costMD: 0,
      costGM: 0,
      resetsWeeklyFatigue: true,
    ),
    'sparring': TrainingPlanDefinition(
      id: 'sparring',
      titleKey: 'training_plan_sparring_title',
      descKey: 'training_plan_sparring_desc',
      phGained: 3,
      fatiguePercent: 45,
      costMD: 0,
      costGM: 0,
      extraXP: 60,
    ),
    'intensive_plus': TrainingPlanDefinition(
      id: 'intensive_plus',
      titleKey: 'training_plan_intensive_plus_title',
      descKey: 'training_plan_intensive_plus_desc',
      phGained: 12,
      fatiguePercent: 85,
      costMD: 50,
      costGM: 0,
      injuryRiskPercent: 5,
      focusedAttributeCount: 2,
    ),
    'master_session': TrainingPlanDefinition(
      id: 'master_session',
      titleKey: 'training_plan_master_session_title',
      descKey: 'training_plan_master_session_desc',
      phGained: 20,
      fatiguePercent: 50,
      costMD: 0,
      costGM: 5,
      injuryRiskPercent: 0,
      sameStyleOnly: true,
    ),
  };

  // ─── PENALIZACIONES DE FATIGA EN COMBATE ──────────────────────────────────
  static const int fatigueLowMax    = 30;  // sin penalización
  static const int fatigueMedMax    = 60;  // -5% stats
  static const int fatigueHighMax   = 80;  // -15% stats
  // >80% → -30% stats + riesgo de lesión

  static const double fatigueMedPenalty  = 0.05;
  static const double fatigueHighPenalty = 0.15;
  static const double fatigueMaxPenalty  = 0.30;
  static const int    fatigueInjuryRisk  = 10; // %
}

class TrainingPlanDefinition {
  final String id;
  final String titleKey;
  final String descKey;
  final int phGained;
  final int fatiguePercent;
  final int costMD;
  final int costGM;
  final int focusedAttributeCount;
  final bool resetsWeeklyFatigue;
  final int injuryRiskPercent;
  final int extraXP;
  final bool sameStyleOnly;

  const TrainingPlanDefinition({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.phGained,
    required this.fatiguePercent,
    required this.costMD,
    required this.costGM,
    this.focusedAttributeCount = 0,
    this.resetsWeeklyFatigue = false,
    this.injuryRiskPercent = 0,
    this.extraXP = 0,
    this.sameStyleOnly = false,
  });
}
