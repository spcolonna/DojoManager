import '../../entities/student.dart';
import '../../../core/config/tournament_config.dart';
import '../../entities/tournament/tournament.dart';

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

  EnrollmentResult execute({   // ← sin Future
    required List<Student> students,
    required List<String> enrolledStudentIds,
    required List<int> fightOrder,
    required Tournament tournament,
  }) {
    // 1. Validar cantidad de inscritos
    if (enrolledStudentIds.isEmpty) {
      return EnrollmentResult.fail('No students enrolled');
    }

    if (enrolledStudentIds.length > TournamentConfig.maxStudentsPerBeltPerTournament) {
      return const EnrollmentResult.fail(
          'Maximum ${TournamentConfig.maxStudentsPerBeltPerTournament} students per belt');
    }

    // 2. Validar longitud del fightOrder ANTES de buscar estudiantes
    if (fightOrder.length != TournamentConfig.fightsPerMatch) {
      return const EnrollmentResult.fail(
          'Fight order must have exactly ${TournamentConfig.fightsPerMatch} spots');
    }

    // 3. Validar índices del fightOrder
    for (final idx in fightOrder) {
      if (idx < 0 || idx >= enrolledStudentIds.length) {
        return EnrollmentResult.fail('Invalid fight order index: $idx');
      }
    }

    // 4. Recién ahora buscar los estudiantes
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

    // 5. Validar unicidad en el orden
    final uniqueInOrder = fightOrder.toSet().length;
    if (uniqueInOrder > enrolledStudentIds.length) {
      return const EnrollmentResult.fail('Not enough students for fight order');
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