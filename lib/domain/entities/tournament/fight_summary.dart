import 'package:equatable/equatable.dart';

class FightSummary extends Equatable {
  final int fightNumber;    // 1, 2, o 3 dentro del match
  final String winnerId;    // teamId del ganador
  final int homeScore;
  final int awayScore;

  const FightSummary({
    required this.fightNumber,
    required this.winnerId,
    required this.homeScore,
    required this.awayScore,
  });

  @override
  List<Object?> get props => [fightNumber, winnerId];
}