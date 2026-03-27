import 'package:grand_dojo/domain/entities/student.dart';

import 'ai/aI_student.dart';

/// Abstracción común para cualquier luchador en una pelea.
/// Permite simular peleas entre Students reales y AIStudents.
class FightFighter {
  final String id;
  final String styleId;
  final Map<String, int> stats;

  const FightFighter({
    required this.id,
    required this.styleId,
    required this.stats,
  });

  /// Desde un Student real
  factory FightFighter.fromStudent(Student s) => FightFighter(
    id: s.id,
    styleId: s.styleId,
    stats: s.stats.toMap(),
  );

  /// Desde un AIStudent
  factory FightFighter.fromAI(AIStudent ai) => FightFighter(
    id: ai.id,
    styleId: ai.styleId,
    stats: ai.stats.toMap(),
  );
}