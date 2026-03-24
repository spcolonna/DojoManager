/// Mejoras del dojo: costos, efectos, prerrequisitos y claves i18n.
class DojoUpgradeConfig {
  DojoUpgradeConfig._();

  static const List<DojoUpgradeDefinition> upgrades = [
    DojoUpgradeDefinition(
      id: 'basic_training_room',
      costMD: 100,
      studentSlotsAdded: 1,
      titleKey: 'upgrade_basic_training_room_title',
      descKey: 'upgrade_basic_training_room_desc',
      iconAsset: 'assets/images/ui/upgrade_basic_training_room.png',
      prerequisiteId: null,
    ),
    DojoUpgradeDefinition(
      id: 'expanded_tatami',
      costMD: 250,
      studentSlotsAdded: 1,
      titleKey: 'upgrade_expanded_tatami_title',
      descKey: 'upgrade_expanded_tatami_desc',
      iconAsset: 'assets/images/ui/upgrade_expanded_tatami.png',
      prerequisiteId: 'basic_training_room',
    ),
    DojoUpgradeDefinition(
      id: 'cardio_area',
      costMD: 300,
      fatigueReductionPercent: 10,
      titleKey: 'upgrade_cardio_area_title',
      descKey: 'upgrade_cardio_area_desc',
      iconAsset: 'assets/images/ui/upgrade_cardio_area.png',
      prerequisiteId: 'basic_training_room',
    ),
    DojoUpgradeDefinition(
      id: 'locker_room',
      costMD: 500,
      studentSlotsAdded: 1,
      titleKey: 'upgrade_locker_room_title',
      descKey: 'upgrade_locker_room_desc',
      iconAsset: 'assets/images/ui/upgrade_locker_room.png',
      prerequisiteId: 'expanded_tatami',
    ),
    DojoUpgradeDefinition(
      id: 'martial_library',
      costMD: 400,
      xpBonusPercent: 5,
      titleKey: 'upgrade_martial_library_title',
      descKey: 'upgrade_martial_library_desc',
      iconAsset: 'assets/images/ui/upgrade_martial_library.png',
      prerequisiteId: 'cardio_area',
    ),
    DojoUpgradeDefinition(
      id: 'sparring_room',
      costMD: 600,
      titleKey: 'upgrade_sparring_room_title',
      descKey: 'upgrade_sparring_room_desc',
      iconAsset: 'assets/images/ui/upgrade_sparring_room.png',
      prerequisiteId: 'locker_room',
    ),
    DojoUpgradeDefinition(
      id: 'full_dojo',
      costMD: 1500,
      studentSlotsAdded: 2,
      titleKey: 'upgrade_full_dojo_title',
      descKey: 'upgrade_full_dojo_desc',
      iconAsset: 'assets/images/ui/upgrade_full_dojo.png',
      prerequisiteId: 'sparring_room',
    ),
  ];
}

class DojoUpgradeDefinition {
  final String id;
  final int costMD;
  final int studentSlotsAdded;
  final int fatigueReductionPercent;
  final int xpBonusPercent;
  final String titleKey;
  final String descKey;
  final String iconAsset;
  final String? prerequisiteId;

  const DojoUpgradeDefinition({
    required this.id,
    required this.costMD,
    this.studentSlotsAdded = 0,
    this.fatigueReductionPercent = 0,
    this.xpBonusPercent = 0,
    required this.titleKey,
    required this.descKey,
    required this.iconAsset,
    this.prerequisiteId,
  });
}
