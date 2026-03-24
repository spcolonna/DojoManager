import 'package:dartz/dartz.dart';
import '../../entities/student.dart';
import '../../repositories/i_student_repository.dart';
import '../../../core/config/skill_tree_config.dart';

class SpendSkillPointsUseCase {
  final IStudentRepository _repo;

  SpendSkillPointsUseCase(this._repo);

  Future<Either<String, Student>> execute({
    required Student student,
    required String nodeId,
  }) async {
    // Encontrar la definición del nodo
    SkillNodeDefinition? nodeDef;
    String? branchId;
    for (final branch in SkillTreeConfig.branches) {
      for (final node in branch.nodes) {
        if (node.id == nodeId) {
          nodeDef = node;
          branchId = branch.id;
          break;
        }
      }
      if (nodeDef != null) break;
    }

    if (nodeDef == null) return const Left('node_not_found');
    if (student.unlockedNodeIds.contains(nodeId)) return const Left('node_already_unlocked');

    // Verificar requisito de faja para nodos Elite
    if (nodeDef.isElite && student.belt.level < SkillTreeConfig.minBeltLevelForEliteNodes) {
      return const Left('belt_level_too_low_for_elite');
    }

    // Calcular costo con modificador de estilo
    double costMultiplier = 1.0;
    if (branchId != null) {
      final mods = SkillTreeConfig.styleBranchModifiers[student.styleId];
      costMultiplier = mods?[branchId] ?? 1.0;
    }
    final baseCost = SkillTreeConfig.phCostByNodeDepth[nodeDef.depth.clamp(0, 4)];
    final finalCost = (baseCost * costMultiplier).ceil();

    if (student.skillPoints < finalCost) return const Left('insufficient_skill_points');

    // Aplicar stat bonuses
    var stats = student.stats;
    for (final entry in nodeDef.statBonuses.entries) {
      switch (entry.key) {
        case 'str': stats = stats.copyWith(str: stats.str + entry.value); break;
        case 'spd': stats = stats.copyWith(spd: stats.spd + entry.value); break;
        case 'tec': stats = stats.copyWith(tec: stats.tec + entry.value); break;
        case 'def': stats = stats.copyWith(def: stats.def + entry.value); break;
        case 'men': stats = stats.copyWith(men: stats.men + entry.value); break;
      }
    }

    final updated = student.copyWith(
      stats: stats,
      skillPoints: student.skillPoints - finalCost,
      unlockedNodeIds: [...student.unlockedNodeIds, nodeId],
    );

    return _repo.saveStudent(updated);
  }
}
