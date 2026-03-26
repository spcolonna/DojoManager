import 'package:equatable/equatable.dart';
import 'ai/aI_student.dart';

/// Rival controlado por la IA.
/// No persiste en Firestore — se genera proceduralmente por división y semana.
class AIOpponent extends Equatable {
  final String id;
  final String teamName;
  final String styleId;
  final int divisionLevel;   // 1 = más bajo, 5 = más alto
  final List<AIStudent> fighters;

  const AIOpponent({
    required this.id,
    required this.teamName,
    required this.styleId,
    required this.divisionLevel,
    required this.fighters,
  });

  @override
  List<Object?> get props => [id];
}