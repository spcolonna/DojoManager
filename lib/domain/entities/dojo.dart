import 'package:equatable/equatable.dart';

class Dojo extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String styleId;
  final int level;              
  final int md;                 // Monedas de Dojo
  final int gm;                 // Gemas del Maestro
  final List<String> unlockedUpgradeIds;
  final int maxStudentSlots;
  final int currentSeason;
  final int currentWeek;
  final bool hasActiveMasterPass;
  final bool tournamentActive;

  const Dojo({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.styleId,
    required this.level,
    required this.md,
    required this.gm,
    required this.unlockedUpgradeIds,
    required this.maxStudentSlots,
    required this.currentSeason,
    required this.currentWeek,
    required this.hasActiveMasterPass,
    this.tournamentActive = false,
  });

  Dojo copyWith({
    String? id, String? ownerId, String? name, String? styleId,
    int? level, int? md, int? gm, List<String>? unlockedUpgradeIds,
    int? maxStudentSlots, int? currentSeason, int? currentWeek,
    bool? hasActiveMasterPass,
    bool? tournamentActive,
  }) => Dojo(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    styleId: styleId ?? this.styleId,
    level: level ?? this.level,
    md: md ?? this.md,
    gm: gm ?? this.gm,
    unlockedUpgradeIds: unlockedUpgradeIds ?? this.unlockedUpgradeIds,
    maxStudentSlots: maxStudentSlots ?? this.maxStudentSlots,
    currentSeason: currentSeason ?? this.currentSeason,
    currentWeek: currentWeek ?? this.currentWeek,
    hasActiveMasterPass: hasActiveMasterPass ?? this.hasActiveMasterPass,
    tournamentActive: tournamentActive ?? this.tournamentActive,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'ownerId': ownerId, 'name': name,
    'styleId': styleId, 'level': level, 'md': md, 'gm': gm,
    'unlockedUpgradeIds': unlockedUpgradeIds,
    'maxStudentSlots': maxStudentSlots,
    'currentSeason': currentSeason,
    'currentWeek': currentWeek,
    'hasActiveMasterPass': hasActiveMasterPass,
    'tournamentActive': tournamentActive,
  };

  factory Dojo.fromMap(Map<String, dynamic> map) => Dojo(
    id: map['id'],
    ownerId: map['ownerId'],
    name: map['name'],
    styleId: map['styleId'],
    level: map['level'] ?? 1,
    md: map['md'] ?? 0,
    gm: map['gm'] ?? 0,
    unlockedUpgradeIds: List<String>.from(map['unlockedUpgradeIds'] ?? []),
    maxStudentSlots: map['maxStudentSlots'] ?? 2,
    currentSeason: map['currentSeason'] ?? 1,
    currentWeek: map['currentWeek'] ?? 1,
    hasActiveMasterPass: map['hasActiveMasterPass'] ?? false,
    tournamentActive: map['tournamentActive'] ?? false,
  );

  @override
  List<Object?> get props => [id];
}
