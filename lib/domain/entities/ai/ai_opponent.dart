import 'package:equatable/equatable.dart';
import 'aI_student.dart';

class AIOpponent extends Equatable {
  final String id;
  final String teamName;
  final String styleId;
  final int divisionLevel;
  final Map<int, List<AIStudent>> fightersByBelt;

  const AIOpponent({
    required this.id,
    required this.teamName,
    required this.styleId,
    required this.divisionLevel,
    required this.fightersByBelt,
  });

  // Compatibilidad con código existente
  List<AIStudent> get fighters =>
      fightersByBelt.values.expand((f) => f).toList();

  List<AIStudent> fightersForBelt(int beltLevel) =>
      fightersByBelt[beltLevel] ?? [];

  List<int> get availableBelts =>
      fightersByBelt.keys
          .where((b) => fightersByBelt[b]!.isNotEmpty)
          .toList()..sort();

  @override
  List<Object?> get props => [id];
}