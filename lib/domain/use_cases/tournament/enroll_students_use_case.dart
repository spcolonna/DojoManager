import '../../entities/student.dart';
import '../../entities/tournament.dart';
import '../../../core/config/tournament_config.dart';

class EnrollmentResult {
  final bool success;
  final String? error;
  final Map<String, List<String>> enrollmentByBelt; // beltKey → studentIds
  final List<int> fightOrder; // índices de estudiantes en los 3 spots

  const EnrollmentResult.ok({
    required this.enrollmentByBelt,
    required this.fightOrder,
  }) : success = true, error = null;

  const EnrollmentResult.fail(this.error)
      : success = false, enrollmentByBelt = const {},
        fightOrder = const [];
}

class EnrollStudentsUseCase {

  EnrollmentResult execute({
    required List<Student> students,
    required List<String> enrolledStudentIds,
    required List<int> fightOrder, // ej: [0, 1, 0] → student[0] pelea 1ra y 3ra
    required Tournament tournament,
  }) {
    if (enrolledStudentIds.isEmpty) {
      return const EnrollmentResult.fail('No students enrolled');
    }

    if (enrolledStudentIds.length > TournamentConfig.maxStudentsPerBeltPerTournament) {
      return EnrollmentResult.fail(
          'Maximum ${TournamentConfig.maxStudentsPerBeltPerTournament} students per belt');
    }

    // Verificar que todos los estudiantes existen y pueden pelear
    for (final id in enrolledStudentIds) {
      final student = students.where((s) => s.id == id).firstOrNull;
      if (student == null) {
        return EnrollmentResult.fail('Student not found: $id');
      }
      if (!student.canFight) {
        return EnrollmentResult.fail(
            '${student.nameKey} cannot fight (injured or fatigued)');
      }
    }

    // Validar el orden de pelea
    // fightOrder tiene 3 posiciones → cada valor es el índice del estudiante
    // Ejemplo válido: [0, 1, 0] — estudiante 0 pelea en spots 1 y 3
    if (fightOrder.length != TournamentConfig.fightsPerMatch) {
      return EnrollmentResult.fail(
          'Fight order must have exactly ${TournamentConfig.fightsPerMatch} spots');
    }

    for (final idx in fightOrder) {
      if (idx < 0 || idx >= enrolledStudentIds.length) {
        return EnrollmentResult.fail('Invalid fight order index: $idx');
      }
    }

    // Verificar que ningún estudiante pelea en los 3 spots
    // (al menos uno debe repetir, no todos)
    final uniqueInOrder = fightOrder.toSet().length;
    if (uniqueInOrder > enrolledStudentIds.length) {
      return EnrollmentResult.fail('Not enough students for fight order');
    }

    final beltKey = students
        .firstWhere((s) => s.id == enrolledStudentIds.first)
        .belt.titleKey;

    return EnrollmentResult.ok(
      enrollmentByBelt: {beltKey: enrolledStudentIds},
      fightOrder: fightOrder,
    );
  }
}