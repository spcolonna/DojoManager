import '../../../core/config/tournament_config.dart';

/// Resultado de una categoría (nivel de faja) en una fecha del torneo.
class CategoryResult {
  final int beltLevel;
  final bool playerWon;       // ganó el best-of-3
  final bool isWalkover;      // el jugador no tenía estudiantes
  final int pointsEarned;     // puntos que sumó la escuela del jugador
  final int rivalPointsEarned;
  final String matchId;

  const CategoryResult({
    required this.beltLevel,
    required this.playerWon,
    required this.isWalkover,
    required this.pointsEarned,
    required this.rivalPointsEarned,
    required this.matchId,
  });

  Map<String, dynamic> toMap() => {
    'beltLevel': beltLevel,
    'playerWon': playerWon,
    'isWalkover': isWalkover,
    'pointsEarned': pointsEarned,
    'rivalPointsEarned': rivalPointsEarned,
    'matchId': matchId,
  };

  factory CategoryResult.fromMap(Map<String, dynamic> map) => CategoryResult(
    beltLevel: map['beltLevel'] ?? 1,
    playerWon: map['playerWon'] ?? false,
    isWalkover: map['isWalkover'] ?? false,
    pointsEarned: map['pointsEarned'] ?? 0,
    rivalPointsEarned: map['rivalPointsEarned'] ?? 0,
    matchId: map['matchId'] ?? '',
  );

  /// Victoria normal
  factory CategoryResult.win({
    required int beltLevel,
    required String matchId,
  }) => CategoryResult(
    beltLevel: beltLevel,
    playerWon: true,
    isWalkover: false,
    pointsEarned: TournamentConfig.pointsByBelt[beltLevel] ?? 3,
    rivalPointsEarned: 0,
    matchId: matchId,
  );

  /// Derrota normal
  factory CategoryResult.loss({
    required int beltLevel,
    required String matchId,
  }) => CategoryResult(
    beltLevel: beltLevel,
    playerWon: false,
    isWalkover: false,
    pointsEarned: 0,
    rivalPointsEarned: TournamentConfig.pointsByBelt[beltLevel] ?? 3,
    matchId: matchId,
  );

  /// Walkover — el jugador no tenía estudiantes
  factory CategoryResult.walkover({
    required int beltLevel,
    required String matchId,
  }) => CategoryResult(
    beltLevel: beltLevel,
    playerWon: false,
    isWalkover: true,
    pointsEarned: 0,
    rivalPointsEarned: TournamentConfig.walkoverPointsFor(beltLevel),
    matchId: matchId,
  );
}