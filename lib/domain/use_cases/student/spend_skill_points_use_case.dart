import '../../entities/student.dart';
import '../../../core/config/skill_tree_config.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';

class SpendSkillPointsResult {
  final bool success;
  final String? error;
  final Student? updatedStudent;

  const SpendSkillPointsResult.ok(this.updatedStudent)
      : success = true, error = null;
  const SpendSkillPointsResult.fail(this.error)
      : success = false, updatedStudent = null;
}

class SpendSkillPointsUseCase {
  final FirebaseDojoRepository _repo;

  SpendSkillPointsUseCase(this._repo);

  Future<SpendSkillPointsResult> execute({
    required Student student,
    required String nodeId,
    required String branchId,
    required int nodeDepth,
  }) async {
    // 1. Verificar que no esté ya desbloqueado
    if (student.unlockedNodeIds.contains(nodeId)) {
      return const SpendSkillPointsResult.fail('Node already unlocked');
    }

    // 2. Calcular costo con modificador de estilo
    final baseCost = SkillTreeConfig.phCostByNodeDepth[nodeDepth];
    final modifier = SkillTreeConfig.styleBranchModifiers[student.styleId]?[branchId] ?? 1.0;
    final finalCost = (baseCost * modifier).round();

    // 3. Verificar requisito de faja para nodos Elite
    final isElite = nodeDepth >= 4;
    if (isElite && student.belt.level < SkillTreeConfig.minBeltLevelForEliteNodes) {
      return SpendSkillPointsResult.fail(
          'Requires Belt Level ${SkillTreeConfig.minBeltLevelForEliteNodes}');
    }

    // 4. Verificar PH suficientes
    if (student.skillPoints < finalCost) {
      return SpendSkillPointsResult.fail(
          'Not enough skill points ($finalCost required, ${student.skillPoints} available)');
    }

    // 5. Aplicar y guardar
    final updated = student.copyWith(
      skillPoints: student.skillPoints - finalCost,
      unlockedNodeIds: [...student.unlockedNodeIds, nodeId],
    );

    final result = await _repo.updateStudent(updated);
    return result.fold(
          (err) => SpendSkillPointsResult.fail(err),
          (s)   => SpendSkillPointsResult.ok(s),
    );
  }
}