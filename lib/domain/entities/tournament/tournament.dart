import 'package:equatable/equatable.dart';
import 'package:grand_dojo/domain/entities/tournament/tournament_match.dart';
import 'package:grand_dojo/domain/entities/tournament/tournament_team.dart';

enum TournamentType { styleLeague, interStyleCup }
enum TournamentStatus { upcoming, inProgress, completed }
enum MatchResult { homeWin, awayWin, draw }

class Tournament extends Equatable {
  final String id;
  final String dojoId;
  final TournamentType type;
  final TournamentStatus status;
  final int season;
  final int week;
  final String beltLevelKey;   // faja que compite en este torneo
  final String styleId;        // vacío si es inter-style
  final List<TournamentTeam> teams;
  final List<TournamentMatch> matches;
  final DateTime? scheduledAt;

  const Tournament({
    required this.id,
    required this.dojoId,
    required this.type,
    required this.status,
    required this.season,
    required this.week,
    required this.beltLevelKey,
    required this.styleId,
    required this.teams,
    required this.matches,
    this.scheduledAt,
  });

  TournamentTeam? get playerTeam =>
      teams.where((t) => t.isPlayer).isNotEmpty
          ? teams.firstWhere((t) => t.isPlayer)
          : null;

  List<TournamentMatch> get playerMatches =>
      matches.where((m) =>
      m.homeTeamId == playerTeam?.id ||
          m.awayTeamId == playerTeam?.id).toList();

  @override
  List<Object?> get props => [id];
}