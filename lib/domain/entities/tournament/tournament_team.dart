import 'package:equatable/equatable.dart';

class TournamentTeam extends Equatable {
  final String id;
  final String name;
  final String styleId;
  final bool isPlayer;
  final int wins;
  final int draws;
  final int losses;
  final int points;
  final int goalsFor;      // puntos de pelea a favor
  final int goalsAgainst;  // puntos de pelea en contra

  const TournamentTeam({
    required this.id,
    required this.name,
    required this.styleId,
    required this.isPlayer,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.points = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;
  int get matchesPlayed  => wins + draws + losses;

  TournamentTeam copyWith({
    int? wins, int? draws, int? losses, int? points,
    int? goalsFor, int? goalsAgainst,
  }) => TournamentTeam(
    id: id, name: name, styleId: styleId, isPlayer: isPlayer,
    wins: wins ?? this.wins,
    draws: draws ?? this.draws,
    losses: losses ?? this.losses,
    points: points ?? this.points,
    goalsFor: goalsFor ?? this.goalsFor,
    goalsAgainst: goalsAgainst ?? this.goalsAgainst,
  );

  @override
  List<Object?> get props => [id];
}