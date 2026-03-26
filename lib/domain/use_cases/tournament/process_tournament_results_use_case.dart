import '../../entities/tournament.dart';

/// Actualiza la tabla de posiciones después de un partido jugado.
/// Devuelve el torneo actualizado con los nuevos puntos y stats de cada equipo.
class ProcessTournamentResultsUseCase {

  Tournament execute({
    required Tournament tournament,
    required TournamentMatch playedMatch,
  }) {
    final updatedMatches = tournament.matches.map((m) =>
    m.id == playedMatch.id ? playedMatch : m).toList();

    final updatedTeams = _recalculateStandings(
      teams: tournament.teams,
      matches: updatedMatches,
    );

    final allPlayed = updatedMatches.every((m) => m.isPlayed);

    return Tournament(
      id: tournament.id,
      dojoId: tournament.dojoId,
      type: tournament.type,
      status: allPlayed
          ? TournamentStatus.completed
          : TournamentStatus.inProgress,
      season: tournament.season,
      week: tournament.week,
      beltLevelKey: tournament.beltLevelKey,
      styleId: tournament.styleId,
      teams: updatedTeams,
      matches: updatedMatches,
      scheduledAt: tournament.scheduledAt,
    );
  }

  List<TournamentTeam> _recalculateStandings({
    required List<TournamentTeam> teams,
    required List<TournamentMatch> matches,
  }) {
    // Reset y recalcular desde cero para evitar acumulación errónea
    final stats = {for (final t in teams) t.id: _TeamStats()};

    for (final match in matches.where((m) => m.isPlayed)) {
      final home = stats[match.homeTeamId]!;
      final away = stats[match.awayTeamId]!;

      home.goalsFor     += match.homePoints;
      home.goalsAgainst += match.awayPoints;
      away.goalsFor     += match.awayPoints;
      away.goalsAgainst += match.homePoints;

      switch (match.result) {
        case MatchResult.homeWin:
          home.wins++;
          home.points += 3;
          away.losses++;
          break;
        case MatchResult.awayWin:
          away.wins++;
          away.points += 3;
          home.losses++;
          break;
        case MatchResult.draw:
          home.draws++;
          home.points++;
          away.draws++;
          away.points++;
          break;
        case null:
          break;
      }
    }

    final updated = teams.map((t) {
      final s = stats[t.id]!;
      return t.copyWith(
        wins: s.wins, draws: s.draws, losses: s.losses,
        points: s.points, goalsFor: s.goalsFor, goalsAgainst: s.goalsAgainst,
      );
    }).toList();

    // Ordenar: puntos → diferencia de goles → goles a favor
    updated.sort((a, b) {
      if (b.points != a.points)      return b.points.compareTo(a.points);
      if (b.goalDifference != a.goalDifference)
        return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return updated;
  }
}

class _TeamStats {
  int wins = 0, draws = 0, losses = 0;
  int points = 0, goalsFor = 0, goalsAgainst = 0;
}