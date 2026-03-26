import 'package:equatable/equatable.dart';

import '../tournament.dart';
import 'fight_summary.dart';

class TournamentMatch extends Equatable {
  final String id;
  final String tournamentId;
  final String homeTeamId;
  final String awayTeamId;
  final MatchResult? result;
  final int homePoints;    // puntos de pelea (no de liga)
  final int awayPoints;
  final int round;
  final bool isPlayed;
  final List<FightSummary> fights;

  const TournamentMatch({
    required this.id,
    required this.tournamentId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.round,
    this.result,
    this.homePoints = 0,
    this.awayPoints = 0,
    this.isPlayed = false,
    this.fights = const [],
  });

  TournamentMatch copyWith({
    MatchResult? result,
    int? homePoints,
    int? awayPoints,
    bool? isPlayed,
    List<FightSummary>? fights,
  }) => TournamentMatch(
    id: id, tournamentId: tournamentId,
    homeTeamId: homeTeamId, awayTeamId: awayTeamId,
    round: round,
    result: result ?? this.result,
    homePoints: homePoints ?? this.homePoints,
    awayPoints: awayPoints ?? this.awayPoints,
    isPlayed: isPlayed ?? this.isPlayed,
    fights: fights ?? this.fights,
  );

  @override
  List<Object?> get props => [id];
}