import 'package:uuid/uuid.dart';
import '../../entities/ai/ai_opponent.dart';
import '../../entities/tournament/tournament.dart';
import '../../entities/tournament/tournament_match.dart';
import '../../entities/tournament/tournament_team.dart';

/// Genera la estructura completa de una liga (round-robin).
/// Cada equipo juega contra todos los demás una vez.
class GenerateLeagueUseCase {
  final _uuid = const Uuid();

  Tournament execute({
    required String playerDojoId,
    required String playerDojoName,
    required String styleId,
    required String beltLevelKey,
    required int beltLevel,
    required int season,
    required int week,
    required List<AIOpponent> aiOpponents,
  }) {
    // Construir equipos
    final playerTeam = TournamentTeam(
      id: 'player_$playerDojoId',
      name: playerDojoName,
      styleId: styleId,
      isPlayer: true,
    );

    final allTeams = [
      playerTeam,
      ...aiOpponents.map((opp) => TournamentTeam(
        id: opp.id,
        name: opp.teamName,
        styleId: opp.styleId,
        isPlayer: false,
      )),
    ];

    // Round-robin: cada equipo vs todos los demás (orden Berger)
    final matches = _generateRoundRobin(
      teams: allTeams,
      tournamentId: _uuid.v4(),
    );

    return Tournament(
      id: _uuid.v4(),
      dojoId: playerDojoId,
      type: TournamentType.styleLeague,
      status: TournamentStatus.upcoming,
      season: season,
      week: week,
      beltLevelKey: beltLevelKey,
      styleId: styleId,
      teams: allTeams,
      matches: matches,
    );
  }

  List<TournamentMatch> _generateRoundRobin({
    required List<TournamentTeam> teams,
    required String tournamentId,
  }) {
    final matches = <TournamentMatch>[];
    final n = teams.length;

    // Algoritmo de Berger para round-robin
    // Si n es impar, agrega un "bye" ficticio
    final list = n % 2 == 0 ? List<TournamentTeam?>.from(teams)
        : [...teams, null];
    final count = list.length;

    for (int round = 0; round < count - 1; round++) {
      for (int i = 0; i < count ~/ 2; i++) {
        final home = list[i];
        final away = list[count - 1 - i];

        if (home != null && away != null) {
          matches.add(TournamentMatch(
            id: _uuid.v4(),
            tournamentId: tournamentId,
            homeTeamId: home.id,
            awayTeamId: away.id,
            round: round + 1,
          ));
        }
      }
      // Rotar todos excepto el primero
      final last = list.removeAt(count - 1);
      list.insert(1, last);
    }

    return matches;
  }
}