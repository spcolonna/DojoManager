import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai/ai_opponent.dart';
import '../../domain/entities/fight.dart';
import '../../domain/entities/tournament/tournament.dart';
import '../../domain/entities/tournament/tournament_match.dart';
import '../../domain/use_cases/tournament/generate_ai_opponents_use_case.dart';
import '../../domain/use_cases/tournament/generate_league_use_case.dart';
import '../../domain/use_cases/tournament/simulate_ai_match_use_case.dart';
import '../../domain/use_cases/tournament/process_tournament_results_use_case.dart';
import '../config/tournament_config.dart';
import '../providers/dojo_provider.dart';

class TournamentNotifier extends StateNotifier<Tournament?> {
  final Ref _ref;
  final _aiGen     = GenerateAIOpponentsUseCase();
  final _leagueGen = GenerateLeagueUseCase();
  final _simulator = SimulateAIMatchUseCase();
  final _processor = ProcessTournamentResultsUseCase();

  List<AIOpponent> _aiOpponents = [];

  TournamentNotifier(this._ref) : super(null);

  Future<void> initLeague({bool isInterStyle = false}) async {
    if (state != null) return;

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) return;

    final seed = dojo.currentSeason * 1000 + dojo.currentWeek;

    // Liga local: 20 equipos → 19 rivales, todos del mismo estilo
    // Copa: 32 equipos → 31 rivales, estilos cruzados
    final rivalCount = isInterStyle
        ? TournamentConfig.interStyleCupTeamsCount - 1
        : TournamentConfig.leagueTeamsCount - 1;

    _aiOpponents = _aiGen.execute(
      playerStyleId: dojo.styleId,
      beltLevel: dojo.level.clamp(1, 10),
      divisionLevel: 1,
      count: rivalCount,
      seed: seed,
      forceStyle: isInterStyle ? null : dojo.styleId, // ← clave
    );

    final league = _leagueGen.execute(
      playerDojoId: dojo.id,
      playerDojoName: dojo.name,
      styleId: dojo.styleId,
      beltLevelKey: 'belt_white',
      beltLevel: dojo.level.clamp(1, 10),
      season: dojo.currentSeason,
      week: dojo.currentWeek,
      aiOpponents: _aiOpponents,
    );

    state = league;
  }

  /// Devuelve el próximo partido sin jugar del jugador.
  TournamentMatch? get nextPlayerMatch {
    final t = state;
    if (t == null) return null;
    final playerId = t.playerTeam?.id;
    if (playerId == null) return null;
    return t.matches
        .where((m) =>
    !m.isPlayed &&
        (m.homeTeamId == playerId || m.awayTeamId == playerId))
        .firstOrNull;
  }

  /// Simula el próximo partido del jugador con los estudiantes inscriptos.
  Future<TournamentMatch?> simulateNextMatch({
    required List<dynamic> playerFighters,
    required List<FightStrategy> playerStrategies,
  }) async {
    final match = nextPlayerMatch;
    if (match == null || state == null) return null;

    final playerTeamId = state!.playerTeam!.id;
    final isHome       = match.homeTeamId == playerTeamId;
    final aiTeamId     = isHome ? match.awayTeamId : match.homeTeamId;
    final aiOpponent   = _aiOpponents
        .where((o) => o.id == aiTeamId)
        .firstOrNull;

    if (aiOpponent == null) return null;

    final homeFighters = isHome ? playerFighters : aiOpponent.fighters;
    final awayFighters = isHome ? aiOpponent.fighters : playerFighters;
    final homeStrategies = isHome ? playerStrategies : [];
    final awayStrategies = isHome ? [] : playerStrategies;
    final homeStyleId    = isHome
        ? state!.styleId
        : aiOpponent.styleId;
    final awayStyleId    = isHome
        ? aiOpponent.styleId
        : state!.styleId;

    final seed = DateTime.now().millisecondsSinceEpoch;

    final result = _simulator.execute(
      match: match,
      homeFighters: homeFighters,
      awayFighters: awayFighters,
      homeStyleId: homeStyleId,
      awayStyleId: awayStyleId,
      homeStrategies: homeStrategies.cast<FightStrategy>(),
      awayStrategies: awayStrategies.cast<FightStrategy>(),
      seed: seed,
    );

    final updated = _processor.execute(
      tournament: state!,
      playedMatch: result.match,
    );

    state = updated;
    return result.match;
  }

  AIOpponent? rivalFor(String teamId) =>
      _aiOpponents.where((o) => o.id == teamId).firstOrNull;
}

final tournamentProvider =
StateNotifierProvider<TournamentNotifier, Tournament?>((ref) {
  final notifier = TournamentNotifier(ref);
  notifier.initLeague();
  return notifier;
});