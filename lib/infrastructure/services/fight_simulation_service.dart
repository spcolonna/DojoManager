import 'dart:math';
import '../../domain/entities/fight.dart';
import '../../core/config/fight_config.dart';
import '../../core/config/fight_strategy_config.dart';
import '../../domain/entities/fight_fighter.dart';
import '../../domain/entities/fight_tick_snapshot.dart';

class FightSimulationService {

  FightResult simulateFight({
    required FightFighter blue,   // ← era Student
    required FightFighter red,    // ← era Student
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

    final blueDef = FightStrategyConfig.strategies[blueStrategy.name];
    final redDef  = FightStrategyConfig.strategies[redStrategy.name];

    final stratVsStrat = FightStrategyConfig
        .strategyMatchupModifiers[blueStrategy.name]?[redStrategy.name] ?? 1.0;
    final stratVsStratRed = FightStrategyConfig
        .strategyMatchupModifiers[redStrategy.name]?[blueStrategy.name] ?? 1.0;

    final blueVsRedStyle =
        FightConfig.styleMatchupModifiers[blue.styleId]?[red.styleId] ?? 1.0;
    final redVsBlueStyle =
        FightConfig.styleMatchupModifiers[red.styleId]?[blue.styleId] ?? 1.0;

    for (int round = 1; round <= FightConfig.roundsPerFight; round++) {
      int blueRndPts = 0, redRndPts = 0;
      final bs = blueSlidersByRound?[round] ?? SliderValues.balanced;
      final rs = redSlidersByRound?[round] ?? SliderValues.balanced;

      for (int tick = 1; tick <= FightConfig.ticksPerRound; tick++) {
        final blueEffective = blueDef?.attackMultipliers.apply(blue.stats)
            ?? _defaultEffective(blue.stats);
        final redEffective  = redDef?.attackMultipliers.apply(red.stats)
            ?? _defaultEffective(red.stats);

        final blueAtk  = _computeAttack(blueEffective, blueStamina, bs);
        final redAtk   = _computeAttack(redEffective,  redStamina,  rs);
        final blueDef_ = _computeDefense(blueEffective, blueStamina, bs);
        final redDef_  = _computeDefense(redEffective,  redStamina,  rs);

        double blueScore = (blueAtk / redDef_)
            * blueVsRedStyle * stratVsStrat * _rngRange(rng);
        double redScore  = (redAtk / blueDef_)
            * redVsBlueStyle * stratVsStratRed * _rngRange(rng);

        if (blueDef != null) {
          final vuln = blueDef.vulnerableTo;
          if (vuln != null) {
            final v = red.stats[vuln.triggerStat] ?? 0;
            if (v >= vuln.triggerThreshold) redScore *= (1 + vuln.counterBonus);
          }
          final bonus = blueDef.bonusAgainst;
          if (bonus != null) {
            final v = red.stats[bonus.triggerStat] ?? 0;
            if (v < bonus.triggerBelow) blueScore *= (1 + bonus.damageBonus);
          }
        }

        if (redDef != null) {
          final vuln = redDef.vulnerableTo;
          if (vuln != null) {
            final v = blue.stats[vuln.triggerStat] ?? 0;
            if (v >= vuln.triggerThreshold) blueScore *= (1 + vuln.counterBonus);
          }
          final bonus = redDef.bonusAgainst;
          if (bonus != null) {
            final v = blue.stats[bonus.triggerStat] ?? 0;
            if (v < bonus.triggerBelow) redScore *= (1 + bonus.damageBonus);
          }
        }

        final blueTakedownThreshold = blueDef?.hasTakedownMechanic == true
            ? blueDef!.takedownThreshold : FightConfig.takedownThreshold;
        final redTakedownThreshold  = redDef?.hasTakedownMechanic == true
            ? redDef!.takedownThreshold  : FightConfig.takedownThreshold;

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

        blueStamina = (blueStamina - (blueDef?.staminaCostPerTick ?? 4.0))
            .clamp(0, 100);
        redStamina  = (redStamina  - (redDef?.staminaCostPerTick  ?? 4.0))
            .clamp(0, 100);
      }

      rounds.add(FightRoundResult(
        round: round, bluePoints: blueRndPts, redPoints: redRndPts,
        blueStaminaRemaining: blueStamina, redStaminaRemaining: redStamina,
      ));
    }

    final winnerId = blueTotalPts >= redTotalPts ? blue.id : red.id;
    final highlights = events
        .where((e) => e.type == 'dominant_hit' || e.type == 'takedown')
        .toList()
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
    if (spent >= FightConfig.fatigueHighThreshold)
      return 1 - FightConfig.fatigueHighPenalty;
    if (spent >= FightConfig.fatigueMediumThreshold)
      return 1 - FightConfig.fatigueMediumPenalty;
    return 1.0;
  }

  double _rngRange(Random r) =>
      FightConfig.rngMin + r.nextDouble() * (FightConfig.rngMax - FightConfig.rngMin);


  FightRoundSimulation simulateRoundToSnapshots({
    required FightFighter blue,
    required FightFighter red,
    required FightStrategy blueStrategy,
    required FightStrategy redStrategy,
    required double blueStartStamina,
    required double redStartStamina,
    int? seed,
  }) {
    final rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    double blueStamina = blueStartStamina;
    double redStamina  = redStartStamina;
    int bluePoints = 0, redPoints = 0;
    final snapshots = <FightTickSnapshot>[];

    final blueDef = FightStrategyConfig.strategies[blueStrategy.name];
    final redDef  = FightStrategyConfig.strategies[redStrategy.name];

    final stratVsStrat    = FightStrategyConfig.strategyMatchupModifiers[blueStrategy.name]?[redStrategy.name] ?? 1.0;
    final stratVsStratRed = FightStrategyConfig.strategyMatchupModifiers[redStrategy.name]?[blueStrategy.name] ?? 1.0;
    final blueVsRed = FightConfig.styleMatchupModifiers[blue.styleId]?[red.styleId] ?? 1.0;
    final redVsBlue = FightConfig.styleMatchupModifiers[red.styleId]?[blue.styleId] ?? 1.0;

    // Máquina de estados de movimiento
    final cycle = [
      ...List.filled(FightConfig.ticksCircling,    MovementState.circling),
      ...List.filled(FightConfig.ticksApproaching, MovementState.approaching),
      ...List.filled(FightConfig.ticksClinch,      MovementState.clinch),
      ...List.filled(FightConfig.ticksRetreating,  MovementState.retreating),
    ];

    for (int tick = 1; tick <= FightConfig.ticksPerRound; tick++) {
      final moveState = cycle[(tick - 1) % cycle.length];

      // Stats efectivos con estrategia
      final bEff = blueDef?.attackMultipliers.apply(blue.stats) ?? _defaultEffective(blue.stats);
      final rEff = redDef?.attackMultipliers.apply(red.stats)   ?? _defaultEffective(red.stats);

      // Fatiga
      final bFat = _fatigue(blueStamina);
      final rFat = _fatigue(redStamina);

      // Ataque efectivo
      final bAtk = _computeAttack(bEff, blueStamina, SliderValues.balanced) * bFat;
      final rAtk = _computeAttack(rEff, redStamina,  SliderValues.balanced) * rFat;

      // Defensa efectiva
      final bDef_ = _computeDefense(bEff, blueStamina, SliderValues.balanced) * bFat;
      final rDef_ = _computeDefense(rEff, redStamina,  SliderValues.balanced) * rFat;

      String? eventType;
      bool eventIsBlue = false;
      bool blueBlocked = false;
      bool redBlocked  = false;

      // ── Solo hay scoring en CLINCH ────────────────────────────────────────
      if (moveState == MovementState.clinch) {

        // ── Intento de ataque azul ─────────────────────────────────────────
        final bRoll = (bAtk / rDef_) * blueVsRed * stratVsStrat * _rngRange(rng);

        // Intento de bloqueo del rojo
        final redDefStat = (red.stats['def'] ?? 10) / 20.0;
        final redBlockRoll = FightConfig.blockBaseProbability * redDefStat * _rngRange(rng);
        final redBlocks = redBlockRoll > FightConfig.blockThreshold * 0.5 &&
            blueStrategy != FightStrategy.grappling;

        if (redBlocks && bRoll > FightConfig.cleanHitThreshold * 0.8) {
          // Bloqueo exitoso del rojo
          redBlocked = true;
          eventType = null;
        } else if (bRoll >= FightConfig.dominantHitThreshold) {
          bluePoints += 2;
          eventType = 'dominant_hit'; eventIsBlue = true;
          if (blueDef?.hasTakedownMechanic == true &&
              bRoll >= FightConfig.takedownThreshold) {
            eventType = 'takedown'; eventIsBlue = true;
            redStamina = (redStamina - FightConfig.takedownStaminaPenalty)
                .clamp(0, 100);
          }
        } else if (bRoll >= FightConfig.cleanHitThreshold) {
          bluePoints += 1;
          eventType = 'clean_hit'; eventIsBlue = true;
        }

        // ── Intento de ataque rojo ─────────────────────────────────────────
        final rRoll = (rAtk / bDef_) * redVsBlue * stratVsStratRed * _rngRange(rng);

        final blueDefStat = (blue.stats['def'] ?? 10) / 20.0;
        final blueBlockRoll = FightConfig.blockBaseProbability * blueDefStat * _rngRange(rng);
        final blueBlocks = blueBlockRoll > FightConfig.blockThreshold * 0.5 &&
            redStrategy != FightStrategy.grappling;

        if (blueBlocks && rRoll > FightConfig.cleanHitThreshold * 0.8) {
          blueBlocked = true;
        } else if (rRoll >= FightConfig.dominantHitThreshold) {
          redPoints += 2;
          if (eventType == null) { eventType = 'dominant_hit'; eventIsBlue = false; }
          if (redDef?.hasTakedownMechanic == true &&
              rRoll >= FightConfig.takedownThreshold) {
            eventType = 'takedown'; eventIsBlue = false;
            blueStamina = (blueStamina - FightConfig.takedownStaminaPenalty)
                .clamp(0, 100);
          }
        } else if (rRoll >= FightConfig.cleanHitThreshold) {
          redPoints += 1;
          if (eventType == null) { eventType = 'clean_hit'; eventIsBlue = false; }
        }
      }

      // Stamina solo se gasta en approaching y clinch
      if (moveState == MovementState.approaching ||
          moveState == MovementState.clinch) {
        blueStamina = (blueStamina - (blueDef?.staminaCostPerTick ?? 4.0))
            .clamp(0, 100);
        redStamina  = (redStamina  - (redDef?.staminaCostPerTick  ?? 4.0))
            .clamp(0, 100);
      }

      snapshots.add(FightTickSnapshot(
        tick: tick,
        blueScore: bluePoints,
        redScore: redPoints,
        blueStamina: blueStamina,
        redStamina: redStamina,
        movementState: moveState,
        eventType: eventType,
        eventIsBlue: eventIsBlue,
        blueBlocked: blueBlocked,
        redBlocked: redBlocked,
      ));
    }

    return FightRoundSimulation(
      snapshots: snapshots,
      bluePoints: bluePoints,
      redPoints: redPoints,
      blueStaminaAfter: blueStamina,
      redStaminaAfter: redStamina,
    );
  }
}