import 'package:equatable/equatable.dart';

enum FightStrategy { aggressive, defensive, technical, grappling, adaptive }

class FightResult extends Equatable {
  final String winnerId;
  final String loserId;
  final int winnerPoints;
  final int loserPoints;
  final List<FightRoundResult> rounds;
  final List<FightEvent> highlights;

  const FightResult({
    required this.winnerId,
    required this.loserId,
    required this.winnerPoints,
    required this.loserPoints,
    required this.rounds,
    required this.highlights,
  });

  @override
  List<Object?> get props => [winnerId, loserId];
}

class FightRoundResult extends Equatable {
  final int round;
  final int bluePoints;
  final int redPoints;
  final double blueStaminaRemaining;
  final double redStaminaRemaining;

  const FightRoundResult({
    required this.round,
    required this.bluePoints,
    required this.redPoints,
    required this.blueStaminaRemaining,
    required this.redStaminaRemaining,
  });

  @override
  List<Object?> get props => [round];
}

class FightEvent {
  final int tick;
  final int round;
  final String type; // 'clean_hit', 'dominant_hit', 'takedown', 'counter'
  final String actorId;
  final int pointsScored;

  const FightEvent({
    required this.tick,
    required this.round,
    required this.type,
    required this.actorId,
    required this.pointsScored,
  });
}

class SliderValues {
  final double attack;
  final double defense;
  final double mind;

  const SliderValues({
    required this.attack,
    required this.defense,
    required this.mind,
  });

  static const SliderValues balanced = SliderValues(
    attack: 0.34,
    defense: 0.33,
    mind: 0.33,
  );

  static const SliderValues aggressive = SliderValues(
    attack: 0.60,
    defense: 0.20,
    mind: 0.20,
  );

  static const SliderValues defensive = SliderValues(
    attack: 0.20,
    defense: 0.60,
    mind: 0.20,
  );
}
