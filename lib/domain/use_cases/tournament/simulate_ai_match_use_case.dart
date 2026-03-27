import 'dart:math';
import '../../../core/config/tournament_config.dart';
import '../../entities/ai/aI_student.dart';
import '../../entities/fight_fighter.dart';
import '../../entities/student.dart';
import '../../entities/fight.dart';
import '../../../infrastructure/services/fight_simulation_service.dart';
import '../../entities/tournament/fight_summary.dart';
import '../../entities/tournament/tournament.dart';
import '../../entities/tournament/tournament_match.dart';

/// Simula un encuentro completo (3 peleas, best of 3).
/// Funciona tanto para IA vs IA como para jugador vs IA.
class SimulateAIMatchUseCase {
  final FightSimulationService _fightService = FightSimulationService();

  MatchSimulationResult execute({
    required TournamentMatch match,
    required List<dynamic> homeFighters,   // List<Student> o List<AIStudent>
    required List<dynamic> awayFighters,
    required String homeStyleId,
    required String awayStyleId,
    required List<FightStrategy> homeStrategies,
    required List<FightStrategy> awayStrategies,
    required int seed,
  }) {
    final rng = Random(seed);

    // Determinar orden de peleas (máx 3)
    // home[0] vs away[0], home[1] vs away[1], home[0] vs away[1] si hay 3ra
    final fights = <FightSummary>[];
    int homeWins = 0;
    int awayWins = 0;
    int totalHomePoints = 0;
    int totalAwayPoints = 0;

    for (int i = 0; i < TournamentConfig.fightsPerMatch; i++) {
      if (homeWins >= TournamentConfig.fightsNeededToWinMatch ||
          awayWins >= TournamentConfig.fightsNeededToWinMatch) break;

      final homeIdx = i % homeFighters.length;
      final awayIdx = i % awayFighters.length;

      final fightResult = _simulateSingleFight(
        homeFighter: homeFighters[homeIdx],
        awayFighter: awayFighters[awayIdx],
        homeStyleId: homeStyleId,
        awayStyleId: awayStyleId,
        homeStrategy: homeStrategies.length > homeIdx
            ? homeStrategies[homeIdx]
            : _bestStrategy(homeFighters[homeIdx]),
        awayStrategy: _bestStrategy(awayFighters[awayIdx]),
        seed: rng.nextInt(999999),
      );

      final homeWon = fightResult.winnerId ==
          _idOf(homeFighters[homeIdx]);

      if (homeWon) homeWins++; else awayWins++;
      totalHomePoints += homeWon
          ? fightResult.winnerPoints
          : fightResult.loserPoints;
      totalAwayPoints += homeWon
          ? fightResult.loserPoints
          : fightResult.winnerPoints;

      fights.add(FightSummary(
        fightNumber: i + 1,
        winnerId: homeWon ? match.homeTeamId : match.awayTeamId,
        homeScore: homeWon
            ? fightResult.winnerPoints
            : fightResult.loserPoints,
        awayScore: homeWon
            ? fightResult.loserPoints
            : fightResult.winnerPoints,
      ));
    }

    final matchResult = homeWins > awayWins
        ? MatchResult.homeWin
        : awayWins > homeWins
        ? MatchResult.awayWin
        : MatchResult.draw;

    final updatedMatch = match.copyWith(
      result: matchResult,
      homePoints: totalHomePoints,
      awayPoints: totalAwayPoints,
      isPlayed: true,
      fights: fights,
    );

    return MatchSimulationResult(
      match: updatedMatch,
      homeWins: homeWins,
      awayWins: awayWins,
    );
  }

  FightResult _simulateSingleFight({
    required dynamic homeFighter,
    required dynamic awayFighter,
    required String homeStyleId,
    required String awayStyleId,
    required FightStrategy homeStrategy,
    required FightStrategy awayStrategy,
    required int seed,
  }) {
    // Convertir a FightFighter según el tipo
    final blue = homeFighter is Student
        ? FightFighter.fromStudent(homeFighter)
        : FightFighter.fromAI(homeFighter as AIStudent);

    final red = awayFighter is Student
        ? FightFighter.fromStudent(awayFighter)
        : FightFighter.fromAI(awayFighter as AIStudent);

    return _fightService.simulateFight(
      blue: blue,
      red: red,
      blueStrategy: homeStrategy,
      redStrategy: awayStrategy,
      seed: seed,
    );
  }

// Actualizá también _bestStrategy y _idOf:
  FightStrategy _bestStrategy(dynamic fighter) {
    final stats = fighter is Student
        ? fighter.stats.toMap()
        : (fighter as AIStudent).stats.toMap();

    final dominant = stats.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;

    return switch (dominant) {
      'str' => FightStrategy.grappling,
      'spd' => FightStrategy.aggressive,
      'tec' => FightStrategy.technical,
      'def' => FightStrategy.defensive,
      'men' => FightStrategy.technical,
      _     => FightStrategy.technical,
    };
  }

  String _idOf(dynamic fighter) => fighter is Student
      ? fighter.id
      : (fighter as AIStudent).id;
}

class MatchSimulationResult {
  final TournamentMatch match;
  final int homeWins;
  final int awayWins;

  const MatchSimulationResult({
    required this.match,
    required this.homeWins,
    required this.awayWins,
  });
}

/// Adapter que permite usar AIStudent en el FightSimulationService
class _AIStudentAdapter {
  final AIStudent ai;
  final String _styleId;

  _AIStudentAdapter(this.ai, this._styleId);

  String get id       => ai.id;
  String get styleId  => _styleId;
  dynamic get stats   => ai.stats;
  dynamic get belt    => ai.belt;
  String get nameKey  => ai.name;
}