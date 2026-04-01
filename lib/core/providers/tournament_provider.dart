import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai/ai_opponent.dart';
import '../../domain/entities/fight.dart';
import '../../domain/entities/tournament/tournament.dart';
import '../../domain/entities/tournament/tournament_match.dart';
import '../../domain/use_cases/tournament/generate_ai_opponents_use_case.dart';
import '../../domain/use_cases/tournament/generate_league_use_case.dart';
import '../../domain/use_cases/tournament/simulate_ai_match_use_case.dart';
import '../../domain/use_cases/tournament/process_tournament_results_use_case.dart';
import '../../infrastructure/repositories/firebase_dojo_repository.dart';
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

  // ─── INIT ──────────────────────────────────────────────────────────────────

  Future<void> initLeague({bool isInterStyle = false}) async {
    if (state != null) return;

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) return;

    final seed = dojo.currentSeason * 1000 + dojo.currentWeek;

    final rivalCount = isInterStyle
        ? TournamentConfig.interStyleCupTeamsCount - 1
        : TournamentConfig.leagueTeamsCount - 1;

    _aiOpponents = _aiGen.execute(
      playerStyleId: dojo.styleId,
      divisionLevel: 1,
      count: rivalCount,
      seed: seed,
      forceStyle: isInterStyle ? null : dojo.styleId,
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

    // Persistir flag + estado inicial
    final repo = FirebaseDojoRepository();
    await repo.updateDojo(dojo.copyWith(tournamentActive: true));
    await repo.saveTournamentState(dojo.id, {
      'season': dojo.currentSeason,
      'week': dojo.currentWeek,
      'styleId': dojo.styleId,
      'status': 'active',
      'playedMatches': [],
    });
    _ref.invalidate(dojoProvider);
  }

  // ─── CARGAR SI ESTABA ACTIVO ───────────────────────────────────────────────

  Future<void> loadIfActive() async {
    if (state != null) return;

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null || !dojo.tournamentActive) return;

    final seed = dojo.currentSeason * 1000 + dojo.currentWeek;

    const rivalCount = TournamentConfig.leagueTeamsCount - 1;

    _aiOpponents = _aiGen.execute(
      playerStyleId: dojo.styleId,
      divisionLevel: 1,
      count: rivalCount,
      seed: seed,
      forceStyle: dojo.styleId,
    );

    var league = _leagueGen.execute(
      playerDojoId: dojo.id,
      playerDojoName: dojo.name,
      styleId: dojo.styleId,
      beltLevelKey: 'belt_white',
      beltLevel: dojo.level.clamp(1, 10),
      season: dojo.currentSeason,
      week: dojo.currentWeek,
      aiOpponents: _aiOpponents,
    );

    // Reaplicar partidos guardados
    final repo = FirebaseDojoRepository();
    final saved = await repo.getTournamentState(dojo.id);
    if (saved != null) {
      final playedMatches = List<Map>.from(saved['playedMatches'] ?? []);
      for (final pm in playedMatches) {
        final matchId = pm['matchId'] as String;
        final matchList = league.matches
            .where((m) => m.id == matchId)
            .toList();
        if (matchList.isEmpty) continue;
        final played = matchList.first.copyWith(
          homePoints: pm['homePoints'] as int,
          awayPoints: pm['awayPoints'] as int,
          result: MatchResult.values.firstWhere(
                (r) => r.name == (pm['result'] as String),
            orElse: () => MatchResult.draw,
          ),
          isPlayed: true,
        );
        league = _processor.execute(tournament: league, playedMatch: played);
      }
    }

    state = league;
  }

  // ─── PRÓXIMO PARTIDO ───────────────────────────────────────────────────────

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

  // ─── SIMULAR PARTIDO ───────────────────────────────────────────────────────

  Future<TournamentMatch?> simulateNextMatch({
    required List<dynamic> playerFighters,
    required List<FightStrategy> playerStrategies,
    Map<int, List<String>> enrolledByBelt = const {},
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

    final homeFighters   = isHome ? playerFighters : aiOpponent.fighters;
    final awayFighters   = isHome ? aiOpponent.fighters : playerFighters;
    final homeStrategies = isHome ? playerStrategies : <FightStrategy>[];
    final awayStrategies = isHome ? <FightStrategy>[] : playerStrategies;
    final homeStyleId    = isHome ? state!.styleId : aiOpponent.styleId;
    final awayStyleId    = isHome ? aiOpponent.styleId : state!.styleId;

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

    // Persistir partido jugado
    final dojo = await _ref.read(dojoProvider.future);
    if (dojo != null) {
      final repo = FirebaseDojoRepository();
      final saved = await repo.getTournamentState(dojo.id) ?? {};
      final playedMatches = List<Map>.from(saved['playedMatches'] ?? []);
      playedMatches.add({
        'matchId': result.match.id,
        'homeTeamId': result.match.homeTeamId,
        'awayTeamId': result.match.awayTeamId,
        'homePoints': result.match.homePoints,
        'awayPoints': result.match.awayPoints,
        'result': result.match.result?.name ?? 'draw',
        'isPlayed': true,
      });
      await repo.saveTournamentState(dojo.id, {
        'season': dojo.currentSeason,
        'week': dojo.currentWeek,
        'styleId': dojo.styleId,
        'status': 'active',
        'playedMatches': playedMatches,
      });

      // Apagar flag si el jugador terminó todos sus partidos
      final allPlayed = updated.playerMatches.every((m) => m.isPlayed);
      if (allPlayed) {
        await repo.updateDojo(dojo.copyWith(tournamentActive: false));
      }
      _ref.invalidate(dojoProvider);
    }

    return result.match;
  }

  // ─── RIVAL ─────────────────────────────────────────────────────────────────

  AIOpponent? rivalFor(String teamId) =>
      _aiOpponents.where((o) => o.id == teamId).firstOrNull;
}

final tournamentProvider =
StateNotifierProvider<TournamentNotifier, Tournament?>((ref) {
  final notifier = TournamentNotifier(ref);
  notifier.loadIfActive();
  return notifier;
});