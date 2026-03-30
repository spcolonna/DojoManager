import '../../core/config/fight_config.dart';

class FightTickSnapshot {
  final int tick;
  final int blueScore;
  final int redScore;
  final double blueStamina;
  final double redStamina;
  final String? eventType;   // 'clean_hit', 'dominant_hit', 'takedown', 'block_blue', 'block_red'
  final bool eventIsBlue;
  final MovementState movementState;
  final bool blueBlocked;           
  final bool redBlocked;            

  const FightTickSnapshot({
    required this.tick,
    required this.blueScore,
    required this.redScore,
    required this.blueStamina,
    required this.redStamina,
    required this.movementState,
    this.eventType,
    required this.eventIsBlue,
    this.blueBlocked = false,
    this.redBlocked  = false,
  });

  double get blueDominance {
    final total = blueScore + redScore;
    if (total == 0) return 0.5;
    return blueScore / total;
  }
}

class FightRoundSimulation {
  final List<FightTickSnapshot> snapshots;
  final int bluePoints;
  final int redPoints;
  final double blueStaminaAfter;
  final double redStaminaAfter;

  const FightRoundSimulation({
    required this.snapshots,
    required this.bluePoints,
    required this.redPoints,
    required this.blueStaminaAfter,
    required this.redStaminaAfter,
  });
}