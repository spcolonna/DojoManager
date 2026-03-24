import 'dart:math';
import '../../domain/entities/fight.dart';
import '../../domain/entities/student.dart';
import '../../core/config/fight_config.dart';

/// Simulación de peleas - corre 100% local, sin red.
/// Seed determinista por combate → replay reproducible.
class FightSimulationService {
  
  FightResult simulateFight({
    required Student blue,
    required Student red,
    required FightStrategy blueStrategy,
    required FightStrategy redStrategy,
    Map<int, SliderValues>? blueSlidersByRound,
    Map<int, SliderValues>? redSlidersByRound,
    int? seed,
  }) {
    final rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    int blueTotalPts = 0, redTotalPts = 0;
    double blueStamina = 100.0, redStamina = 100.0;
    final rounds = <FightRoundResult>[];
    final events = <FightEvent>[];

    final blueVsRedMod = FightConfig.styleMatchupModifiers[blue.styleId]?[red.styleId] ?? 1.0;
    final redVsBlueMod = FightConfig.styleMatchupModifiers[red.styleId]?[blue.styleId] ?? 1.0;

    for (int round = 1; round <= FightConfig.roundsPerFight; round++) {
      int blueRndPts = 0, redRndPts = 0;
      final bs = blueSlidersByRound?[round] ?? SliderValues.balanced;
      final rs = redSlidersByRound?[round] ?? SliderValues.balanced;

      for (int tick = 1; tick <= FightConfig.ticksPerRound; tick++) {
        final blueAtk = _atk(blue, blueStrategy, blueStamina, bs);
        final blueDef = _def(blue, blueStamina, bs);
        final redAtk  = _atk(red,  redStrategy,  redStamina,  rs);
        final redDef  = _def(red,  redStamina,  rs);

        final bScore = (blueAtk / redDef) * blueVsRedMod * _rngRange(rng);
        final rScore = (redAtk  / blueDef) * redVsBlueMod  * _rngRange(rng);

        void score(double s, String actorId, String opponentId) {
          if (s >= FightConfig.dominantHitThreshold) {
            if (actorId == blue.id) { blueRndPts += 2; blueTotalPts += 2; }
            else { redRndPts += 2; redTotalPts += 2; }
            events.add(FightEvent(tick: tick, round: round, type: 'dominant_hit', actorId: actorId, pointsScored: 2));
          } else if (s >= FightConfig.cleanHitThreshold) {
            if (actorId == blue.id) { blueRndPts += 1; blueTotalPts += 1; }
            else { redRndPts += 1; redTotalPts += 1; }
            events.add(FightEvent(tick: tick, round: round, type: 'clean_hit', actorId: actorId, pointsScored: 1));
          }
        }

        score(bScore, blue.id, red.id);
        score(rScore, red.id, blue.id);

        blueStamina = (blueStamina - _stamCost(blueStrategy)).clamp(0, 100);
        redStamina  = (redStamina  - _stamCost(redStrategy)).clamp(0, 100);
      }

      rounds.add(FightRoundResult(
        round: round, bluePoints: blueRndPts, redPoints: redRndPts,
        blueStaminaRemaining: blueStamina, redStaminaRemaining: redStamina,
      ));
    }

    final winnerId = blueTotalPts >= redTotalPts ? blue.id : red.id;
    final highlights = events.where((e) => e.type == 'dominant_hit').toList()
      ..sort((a, b) => b.pointsScored.compareTo(a.pointsScored));

    return FightResult(
      winnerId: winnerId,
      loserId: winnerId == blue.id ? red.id : blue.id,
      winnerPoints: winnerId == blue.id ? blueTotalPts : redTotalPts,
      loserPoints:  winnerId == blue.id ? redTotalPts  : blueTotalPts,
      rounds: rounds,
      highlights: highlights.take(5).toList(),
    );
  }

  double _atk(Student s, FightStrategy st, double stamina, SliderValues sl) {
    final w = FightConfig.strategyWeights[st.name] ?? [0.33, 0.33, 0.34];
    final raw = s.stats.str * w[0] + s.stats.spd * w[1] + s.stats.tec * w[2];
    return raw * _fatigue(stamina) * sl.attack;
  }

  double _def(Student s, double stamina, SliderValues sl) {
    final raw = s.stats.def * 0.6 + s.stats.men * 0.4;
    return raw * _fatigue(stamina) * (sl.defense + sl.mind * 0.5);
  }

  double _fatigue(double stamina) {
    final spent = (100 - stamina) / 100;
    if (spent >= 1.0) return FightConfig.minEfficiencyAtZeroStamina;
    if (spent >= FightConfig.fatigueHighThreshold) return 1 - FightConfig.fatigueHighPenalty;
    if (spent >= FightConfig.fatigueMediumThreshold) return 1 - FightConfig.fatigueMediumPenalty;
    return 1.0;
  }

  double _stamCost(FightStrategy s) => FightConfig.staminaCostPerTick[s.name] ?? 4.0;
  double _rngRange(Random r) => FightConfig.rngMin + r.nextDouble() * (FightConfig.rngMax - FightConfig.rngMin);
}
