import 'package:flutter_test/flutter_test.dart';
import 'package:grand_dojo/core/config/fight_strategy_config.dart';
import 'package:grand_dojo/domain/value_objects/student_stats.dart';

void main() {

  group('FightStrategyConfig — multiplicadores', () {

    test('aggressive aumenta STR y SPD, reduce DEF y MEN', () {
      final def = FightStrategyConfig.strategies['aggressive']!;
      expect(def.attackMultipliers.str, greaterThan(1.0));
      expect(def.attackMultipliers.spd, greaterThan(1.0));
      expect(def.attackMultipliers.def, lessThan(1.0));
      expect(def.attackMultipliers.men, lessThan(1.0));
    });

    test('defensive tiene DEF muy alta y stamina cost muy baja', () {
      final def = FightStrategyConfig.strategies['defensive']!;
      expect(def.attackMultipliers.def, greaterThan(1.3));
      expect(def.staminaCostPerTick, lessThan(4.0));
    });

    test('technical tiene TEC y MEN muy altas', () {
      final def = FightStrategyConfig.strategies['technical']!;
      expect(def.attackMultipliers.tec, greaterThan(1.3));
      expect(def.attackMultipliers.men, greaterThan(1.3));
    });

    test('grappling tiene STR muy alta y hasTakedownMechanic = true', () {
      final def = FightStrategyConfig.strategies['grappling']!;
      expect(def.attackMultipliers.str, greaterThan(1.3));
      expect(def.hasTakedownMechanic, true);
    });

    test('grappling tiene la stamina cost más alta', () {
      final costs = FightStrategyConfig.strategies.values
          .map((s) => s.staminaCostPerTick).toList();
      final grapplingCost =
          FightStrategyConfig.strategies['grappling']!.staminaCostPerTick;
      expect(grapplingCost, costs.reduce((a, b) => a > b ? a : b));
    });
  });

  group('FightStrategyConfig — matchup modifiers', () {

    test('technical tiene ventaja sobre aggressive', () {
      final mod = FightStrategyConfig
          .strategyMatchupModifiers['technical']!['aggressive']!;
      expect(mod, greaterThan(1.0));
    });

    test('aggressive tiene ventaja sobre defensive', () {
      final mod = FightStrategyConfig
          .strategyMatchupModifiers['aggressive']!['defensive']!;
      expect(mod, greaterThan(1.0));
    });

    test('grappling tiene ventaja sobre defensive', () {
      final mod = FightStrategyConfig
          .strategyMatchupModifiers['grappling']!['defensive']!;
      expect(mod, greaterThan(1.0));
    });

    test('technical tiene ventaja sobre grappling', () {
      final mod = FightStrategyConfig
          .strategyMatchupModifiers['technical']!['grappling']!;
      expect(mod, greaterThan(1.0));
    });

    // Verificar el ciclo completo piedra-papel-tijera
    test('ciclo de ventajas es consistente', () {
      final m = FightStrategyConfig.strategyMatchupModifiers;
      // aggressive beats defensive
      expect(m['aggressive']!['defensive']!, greaterThan(1.0));
      // defensive beats aggressive
      expect(m['defensive']!['aggressive']!, greaterThan(1.0));
      // technical beats aggressive
      expect(m['technical']!['aggressive']!, greaterThan(1.0));
      // grappling beats defensive
      expect(m['grappling']!['defensive']!, greaterThan(1.0));
      // technical beats grappling
      expect(m['technical']!['grappling']!, greaterThan(1.0));
    });
  });

  group('FightStrategyConfig — vulnerabilidades', () {

    test('aggressive es vulnerable a rival con MEN alta', () {
      final vuln =
      FightStrategyConfig.strategies['aggressive']!.vulnerableTo!;
      expect(vuln.triggerStat, 'men');
      expect(vuln.counterBonus, greaterThan(0));
    });

    test('defensive es vulnerable a rival con STR alta (grappling)', () {
      final vuln =
      FightStrategyConfig.strategies['defensive']!.vulnerableTo!;
      expect(vuln.triggerStat, 'str');
      expect(vuln.counterKey, 'grappling');
    });
  });

  group('FightStrategyConfig — auto-select', () {

    test('luchador con STR dominante → grappling', () {
      final stats = {'str': 25, 'spd': 10, 'tec': 10, 'def': 10, 'men': 10};
      expect(FightStrategyConfig.autoSelectStrategy(stats), 'grappling');
    });

    test('luchador con SPD dominante → aggressive', () {
      final stats = {'str': 10, 'spd': 25, 'tec': 10, 'def': 10, 'men': 10};
      expect(FightStrategyConfig.autoSelectStrategy(stats), 'aggressive');
    });

    test('luchador con TEC dominante → technical', () {
      final stats = {'str': 10, 'spd': 10, 'tec': 25, 'def': 10, 'men': 10};
      expect(FightStrategyConfig.autoSelectStrategy(stats), 'technical');
    });

    test('luchador con DEF dominante → defensive', () {
      final stats = {'str': 10, 'spd': 10, 'tec': 10, 'def': 25, 'men': 10};
      expect(FightStrategyConfig.autoSelectStrategy(stats), 'defensive');
    });
  });

  group('FightStatMultipliers — apply', () {

    test('multiplicadores se aplican correctamente sobre los stats', () {
      final mult = FightStrategyConfig
          .strategies['aggressive']!.attackMultipliers;
      final stats = {'str': 20, 'spd': 20, 'tec': 20, 'def': 20, 'men': 20};
      final eff = mult.apply(stats);

      expect(eff['str']!, moreOrLessEquals(20 * 1.35, epsilon: 0.01));
      expect(eff['def']!, moreOrLessEquals(20 * 0.65, epsilon: 0.01));
    });

    test('defensive tiene stats efectivos de DEF mayores que aggressive', () {
      final stats = {'str': 15, 'spd': 15, 'tec': 15, 'def': 15, 'men': 15};
      final aggEff = FightStrategyConfig.strategies['aggressive']!
          .attackMultipliers.apply(stats);
      final defEff = FightStrategyConfig.strategies['defensive']!
          .attackMultipliers.apply(stats);

      expect(defEff['def']!, greaterThan(aggEff['def']!));
    });
  });
}