import 'package:dartz/dartz.dart';
import '../../entities/dojo.dart';
import '../../repositories/i_dojo_repository.dart';
import '../../../core/config/dojo_upgrade_config.dart';

class UpgradeDojoUseCase {
  final IDojoRepository _repo;

  UpgradeDojoUseCase(this._repo);

  Future<Either<String, Dojo>> execute({
    required Dojo dojo,
    required String upgradeId,
  }) async {
    final def = DojoUpgradeConfig.upgrades
        .where((u) => u.id == upgradeId)
        .firstOrNull;

    if (def == null) return const Left('upgrade_not_found');
    if (dojo.unlockedUpgradeIds.contains(upgradeId)) return const Left('upgrade_already_unlocked');

    // Verificar prerequisito
    if (def.prerequisiteId != null && !dojo.unlockedUpgradeIds.contains(def.prerequisiteId)) {
      return const Left('prerequisite_not_met');
    }

    if (dojo.md < def.costMD) return const Left('insufficient_md');

    final updatedDojo = dojo.copyWith(
      md: dojo.md - def.costMD,
      unlockedUpgradeIds: [...dojo.unlockedUpgradeIds, upgradeId],
      maxStudentSlots: dojo.maxStudentSlots + def.studentSlotsAdded,
    );

    return _repo.saveDojo(updatedDojo);
  }
}
