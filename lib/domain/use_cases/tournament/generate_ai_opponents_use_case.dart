import 'dart:math';
import '../../entities/ai/aI_student.dart';
import '../../entities/ai/ai_opponent.dart';
import '../../value_objects/student_stats.dart';
import '../../value_objects/belt.dart';
import '../../../core/config/tournament_config.dart';

class GenerateAIOpponentsUseCase {

  List<AIOpponent> execute({
    required String playerStyleId,
    required int divisionLevel,
    required int count,
    required int seed,
    String? forceStyle,
  }) {
    final rng = Random(seed);
    final opponents = <AIOpponent>[];

    final styles = TournamentConfig.styleMatchupModifiers.keys.toList();
    if (!styles.contains(playerStyleId)) styles.add(playerStyleId);

    for (int i = 0; i < count; i++) {
      final style = forceStyle ?? styles[rng.nextInt(styles.length)];
      final name  = _generateTeamName(style, rng);

      // Generar fighters para todos los niveles de faja 1-10
      final fightersByBelt = <int, List<AIStudent>>{};
      for (int belt = 1; belt <= 10; belt++) {
        final fighterCount = 1 + rng.nextInt(2); // 1 o 2 por belt
        fightersByBelt[belt] = List.generate(
          fighterCount,
              (j) => _generateFighter(
            id: 'ai_${seed}_${i}_b${belt}_$j',
            styleId: style,
            beltLevel: belt,
            divisionLevel: divisionLevel,
            rng: rng,
          ),
        );
      }

      opponents.add(AIOpponent(
        id: 'ai_team_${seed}_$i',
        teamName: name,
        styleId: style,
        divisionLevel: divisionLevel,
        fightersByBelt: fightersByBelt,
      ));
    }

    return opponents;
  }

  AIStudent _generateFighter({
    required String id,
    required String styleId,
    required int beltLevel,
    required int divisionLevel,
    required Random rng,
  }) {
    final baseValue = 8 + (beltLevel * 2) + (divisionLevel * 2);
    const variance  = 4;

    int randomStat(int base) =>
        (base + rng.nextInt(variance * 2) - variance).clamp(5, 40);

    final profile = _styleProfile(styleId);
    final stats = StudentStats(
      str: randomStat((baseValue * profile['str']!).round()),
      spd: randomStat((baseValue * profile['spd']!).round()),
      tec: randomStat((baseValue * profile['tec']!).round()),
      def: randomStat((baseValue * profile['def']!).round()),
      men: randomStat((baseValue * profile['men']!).round()),
      res: 40 + (beltLevel * 5) + rng.nextInt(15),
    );

    return AIStudent(
      id: id,
      name: _fighterName(rng),
      stats: stats,
      belt: Belt(level: beltLevel),
      styleId: styleId,
    );
  }

  Map<String, double> _styleProfile(String styleId) => switch (styleId) {
    'kung_fu'   => {'str': 0.9, 'spd': 1.0, 'tec': 1.1, 'def': 0.9, 'men': 1.1},
    'karate'    => {'str': 1.1, 'spd': 0.9, 'tec': 1.1, 'def': 1.0, 'men': 0.9},
    'taekwondo' => {'str': 0.8, 'spd': 1.4, 'tec': 1.0, 'def': 0.8, 'men': 1.0},
    'judo'      => {'str': 1.0, 'spd': 0.7, 'tec': 0.9, 'def': 1.4, 'men': 1.0},
    'muay_thai' => {'str': 1.3, 'spd': 1.0, 'tec': 0.9, 'def': 1.1, 'men': 0.7},
    'bjj'       => {'str': 0.9, 'spd': 0.7, 'tec': 1.1, 'def': 1.2, 'men': 1.1},
    'boxing'    => {'str': 1.2, 'spd': 1.1, 'tec': 0.9, 'def': 1.0, 'men': 0.8},
    'mma'       => {'str': 1.0, 'spd': 1.0, 'tec': 1.0, 'def': 1.0, 'men': 1.0},
    _           => {'str': 1.0, 'spd': 1.0, 'tec': 1.0, 'def': 1.0, 'men': 1.0},
  };

  String _generateTeamName(String styleId, Random rng) {
    final prefixes = ['Dragon', 'Tiger', 'Eagle', 'Iron', 'Steel',
      'Shadow', 'Phoenix', 'Golden', 'Thunder', 'Silent'];
    final suffixes = switch (styleId) {
      'kung_fu'   => ['Temple', 'Fist', 'Monastery', 'Palace'],
      'karate'    => ['Dojo', 'Academy', 'School', 'Kai'],
      'taekwondo' => ['Gym', 'Institute', 'Center', 'Federation'],
      'judo'      => ['Club', 'Hall', 'Dojo', 'Association'],
      'muay_thai' => ['Camp', 'Gym', 'Muay', 'Boxing'],
      'bjj'       => ['Academy', 'Team', 'Association', 'Lab'],
      'boxing'    => ['Boxing Club', 'Ring', 'Gym', 'Corner'],
      'mma'       => ['MMA', 'Fight Club', 'Combat', 'Arena'],
      _           => ['Dojo', 'School', 'Academy', 'Club'],
    };
    return '${prefixes[rng.nextInt(prefixes.length)]} '
        '${suffixes[rng.nextInt(suffixes.length)]}';
  }

  String _fighterName(Random rng) {
    const first = ['Kai', 'Ryu', 'Jin', 'Hiro', 'Sato', 'Chen', 'Liu',
      'Park', 'Kim', 'Dae', 'Bruno', 'Marco', 'Ivan', 'Erik', 'Lars'];
    const last  = ['Tanaka', 'Yamamoto', 'Lee', 'Kim', 'Chen', 'Wang',
      'Silva', 'Santos', 'Berg', 'Holm', 'Cruz', 'Diaz', 'Park', 'Han'];
    return '${first[rng.nextInt(first.length)]} '
        '${last[rng.nextInt(last.length)]}';
  }
}