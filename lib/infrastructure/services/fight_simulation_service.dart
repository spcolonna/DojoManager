import 'dart:math';
import '../../domain/entities/fight.dart';
import '../../domain/entities/student.dart';
import '../../core/config/fight_config.dart';
import '../../core/config/fight_strategy_config.dart';

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

    // Definiciones de estrategia
    final blueDef = FightStrategyConfig.strategies[blueStrategy.name];
    final redDef  = FightStrategyConfig.strategies[redStrategy.name];

    // Modificador de matchup entre estrategias
    final stratVsStrat = FightStrategyConfig
        .strategyMatchupModifiers[blueStrategy.name]?[redStrategy.name] ?? 1.0;
    final stratVsStratRed = FightStrategyConfig
        .strategyMatchupModifiers[redStrategy.name]?[blueStrategy.name] ?? 1.0;

    // Modificador de matchup entre estilos marciales (ya existente)
    final blueVsRedStyle = FightConfig.styleMatchupModifiers[blue.styleId]?[red.styleId] ?? 1.0;
    final redVsBlueStyle = FightConfig.styleMatchupModifiers[red.styleId]?[blue.styleId] ?? 1.0;

    for (int round = 1; round <= FightConfig.roundsPerFight; round++) {
      int blueRndPts = 0, redRndPts = 0;
      final bs = blueSlidersByRound?[round] ?? SliderValues.balanced;
      final rs = redSlidersByRound?[round] ?? SliderValues.balanced;

      for (int tick = 1; tick <= FightConfig.ticksPerRound; tick++) {

        // Stats efectivos con multiplicadores de estrategia
        final blueEffective = blueDef?.attackMultipliers.apply(blue.stats.toMap())
            ?? _defaultEffective(blue.stats.toMap());
        final redEffective  = redDef?.attackMultipliers.apply(red.stats.toMap())
            ?? _defaultEffective(red.stats.toMap());

        // Ataque efectivo
        final blueAtk = _computeAttack(blueEffective, blueStamina, bs);
        final redAtk  = _computeAttack(redEffective,  redStamina,  rs);

        // Defensa efectiva
        final blueDef_ = _computeDefense(blueEffective, blueStamina, bs);
        final redDef_  = _computeDefense(redEffective,  redStamina,  rs);

        // Probabilidad de scoring
        double blueScore = (blueAtk / redDef_)
            * blueVsRedStyle
            * stratVsStrat
            * _rngRange(rng);

        double redScore = (redAtk / blueDef_)
            * redVsBlueStyle
            * stratVsStratRed
            * _rngRange(rng);

        // ── Vulnerabilidad del blue ante el rojo ──────────────────────────
        if (blueDef != null) {
          final vuln = blueDef.vulnerableTo;
          if (vuln != null) {
            final redStatValue = red.stats.toMap()[vuln.triggerStat] ?? 0;
            if (redStatValue >= vuln.triggerThreshold) {
              // El rival tiene el stat alto → bonus de contraataque para el rojo
              redScore *= (1 + vuln.counterBonus);
            }
          }
        }

        // ── Vulnerabilidad del red ante el azul ───────────────────────────
        if (redDef != null) {
          final vuln = redDef.vulnerableTo;
          if (vuln != null) {
            final blueStatValue = blue.stats.toMap()[vuln.triggerStat] ?? 0;
            if (blueStatValue >= vuln.triggerThreshold) {
              blueScore *= (1 + vuln.counterBonus);
            }
          }
        }

        // ── Bonus del blue contra el rojo ─────────────────────────────────
        if (blueDef != null) {
          final bonus = blueDef.bonusAgainst;
          if (bonus != null) {
            final redStatValue = red.stats.toMap()[bonus.triggerStat] ?? 0;
            if (redStatValue < bonus.triggerBelow) {
              blueScore *= (1 + bonus.damageBonus);
            }
          }
        }

        // ── Bonus del red contra el azul ──────────────────────────────────
        if (redDef != null) {
          final bonus = redDef.bonusAgainst;
          if (bonus != null) {
            final blueStatValue = blue.stats.toMap()[bonus.triggerStat] ?? 0;
            if (blueStatValue < bonus.triggerBelow) {
              redScore *= (1 + bonus.damageBonus);
            }
          }
        }

        // ── Scoring blue ──────────────────────────────────────────────────
        // Grappling: intento de derribo con umbral propio
        final blueTakedownThreshold = blueDef?.hasTakedownMechanic == true
            ? blueDef!.takedownThreshold
            : FightConfig.takedownThreshold;

        if (blueScore >= FightConfig.dominantHitThreshold) {
          blueRndPts += 2; blueTotalPts += 2;
          events.add(FightEvent(tick: tick, round: round,
              type: 'dominant_hit', actorId: blue.id, pointsScored: 2));
        } else if (blueScore >= blueTakedownThreshold &&
            blueDef?.hasTakedownMechanic == true) {
          blueRndPts += 2; blueTotalPts += 2;
          redStamina = (redStamina - (blueDef?.takedownStaminaPenalty ?? 15))
              .clamp(0, 100);
          events.add(FightEvent(tick: tick, round: round,
              type: 'takedown', actorId: blue.id, pointsScored: 2));
        } else if (blueScore >= FightConfig.cleanHitThreshold) {
          blueRndPts += 1; blueTotalPts += 1;
          events.add(FightEvent(tick: tick, round: round,
              type: 'clean_hit', actorId: blue.id, pointsScored: 1));
        }

        // ── Scoring red ───────────────────────────────────────────────────
        final redTakedownThreshold = redDef?.hasTakedownMechanic == true
            ? redDef!.takedownThreshold
            : FightConfig.takedownThreshold;

        if (redScore >= FightConfig.dominantHitThreshold) {
          redRndPts += 2; redTotalPts += 2;
          events.add(FightEvent(tick: tick, round: round,
              type: 'dominant_hit', actorId: red.id, pointsScored: 2));
        } else if (redScore >= redTakedownThreshold &&
            redDef?.hasTakedownMechanic == true) {
          redRndPts += 2; redTotalPts += 2;
          blueStamina = (blueStamina - (redDef?.takedownStaminaPenalty ?? 15))
              .clamp(0, 100);
          events.add(FightEvent(tick: tick, round: round,
              type: 'takedown', actorId: red.id, pointsScored: 2));
        } else if (redScore >= FightConfig.cleanHitThreshold) {
          redRndPts += 1; redTotalPts += 1;
          events.add(FightEvent(tick: tick, round: round,
              type: 'clean_hit', actorId: red.id, pointsScored: 1));
        }

        // ── Stamina drain según estrategia ────────────────────────────────
        blueStamina = (blueStamina -
            (blueDef?.staminaCostPerTick ?? 4.0)).clamp(0, 100);
        redStamina  = (redStamina -
            (redDef?.staminaCostPerTick  ?? 4.0)).clamp(0, 100);
      }

      rounds.add(FightRoundResult(
        round: round, bluePoints: blueRndPts, redPoints: redRndPts,
        blueStaminaRemaining: blueStamina, redStaminaRemaining: redStamina,
      ));
    }

    final winnerId = blueTotalPts >= redTotalPts ? blue.id : red.id;
    final highlights = events.where((e) =>
    e.type == 'dominant_hit' || e.type == 'takedown').toList()
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

  double _computeAttack(Map<String, double> eff, double stamina, SliderValues sl) {
    final raw = eff['str']! * 0.35 + eff['spd']! * 0.35 + eff['tec']! * 0.30;
    return raw * _fatigue(stamina) * sl.attack;
  }

  double _computeDefense(Map<String, double> eff, double stamina, SliderValues sl) {
    final raw = eff['def']! * 0.6 + eff['men']! * 0.4;
    return raw * _fatigue(stamina) * (sl.defense + sl.mind * 0.5);
  }

  Map<String, double> _defaultEffective(Map<String, int> stats) =>
      stats.map((k, v) => MapEntry(k, v.toDouble()));

  double _fatigue(double stamina) {
    final spent = (100 - stamina) / 100;
    if (spent >= 1.0) return FightConfig.minEfficiencyAtZeroStamina;
    if (spent >= FightConfig.fatigueHighThreshold)   return 1 - FightConfig.fatigueHighPenalty;
    if (spent >= FightConfig.fatigueMediumThreshold) return 1 - FightConfig.fatigueMediumPenalty;
    return 1.0;
  }

  double _rngRange(Random r) =>
      FightConfig.rngMin + r.nextDouble() * (FightConfig.rngMax - FightConfig.rngMin);
}