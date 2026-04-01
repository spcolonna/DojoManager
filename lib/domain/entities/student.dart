import 'package:equatable/equatable.dart';
import 'package:grand_dojo/domain/entities/training_session.dart';
import '../value_objects/belt.dart';
import '../value_objects/student_stats.dart';

enum StudentTier { bronze, silver, gold, platinum }

class Student extends Equatable {
  final String id;
  final String dojoId;
  final String nameKey;        // clave i18n o nombre custom
  final String avatarAsset;    // path al PNG del personaje
  final String styleId;        // id del MartialStyle
  final Belt belt;
  final int currentXP;         // XP acumulado en el nivel actual
  final StudentStats stats;
  final StudentTier tier;
  final int skillPoints;       // PH acumulados sin gastar
  final List<String> unlockedNodeIds; // IDs de nodos del árbol desbloqueados
  final int fatiguePercent;    // 0–100, acumulado en la semana
  final bool isInjured;
  final int injuryWeeksRemaining;
  final List<TrainingSession> trainingHistory;
  final Map<String, double> learningCoefficients;

  const Student({
    required this.id,
    required this.dojoId,
    required this.nameKey,
    required this.avatarAsset,
    required this.styleId,
    required this.belt,
    required this.currentXP,
    required this.stats,
    required this.tier,
    required this.skillPoints,
    required this.unlockedNodeIds,
    required this.fatiguePercent,
    required this.isInjured,
    required this.injuryWeeksRemaining,
    this.trainingHistory = const [],
    this.learningCoefficients = const {},
  });

  bool get canFight => !isInjured && fatiguePercent < 100;

  Student copyWith({
    String? id, String? dojoId, String? nameKey, String? avatarAsset,
    String? styleId, Belt? belt, int? currentXP, StudentStats? stats,
    StudentTier? tier, int? skillPoints, List<String>? unlockedNodeIds,
    int? fatiguePercent, bool? isInjured, int? injuryWeeksRemaining,
    List<TrainingSession>? trainingHistory,
    Map<String, double>? learningCoefficients,
  }) => Student(
    id: id ?? this.id,
    dojoId: dojoId ?? this.dojoId,
    nameKey: nameKey ?? this.nameKey,
    avatarAsset: avatarAsset ?? this.avatarAsset,
    styleId: styleId ?? this.styleId,
    belt: belt ?? this.belt,
    currentXP: currentXP ?? this.currentXP,
    stats: stats ?? this.stats,
    tier: tier ?? this.tier,
    skillPoints: skillPoints ?? this.skillPoints,
    unlockedNodeIds: unlockedNodeIds ?? this.unlockedNodeIds,
    fatiguePercent: fatiguePercent ?? this.fatiguePercent,
    isInjured: isInjured ?? this.isInjured,
    injuryWeeksRemaining: injuryWeeksRemaining ?? this.injuryWeeksRemaining,
    trainingHistory: trainingHistory ?? this.trainingHistory,
    learningCoefficients: learningCoefficients ?? this.learningCoefficients,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'dojoId': dojoId, 'nameKey': nameKey,
    'avatarAsset': avatarAsset, 'styleId': styleId,
    'beltLevel': belt.level, 'beltDan': belt.danLevel,
    'currentXP': currentXP,
    'stats': stats.toMap(),
    'tier': tier.name,
    'skillPoints': skillPoints,
    'unlockedNodeIds': unlockedNodeIds,
    'fatiguePercent': fatiguePercent,
    'isInjured': isInjured,
    'injuryWeeksRemaining': injuryWeeksRemaining,
    'trainingHistory': trainingHistory.map((s) => s.toMap()).toList(),
    'learningCoefficients': learningCoefficients,
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    id: map['id'],
    dojoId: map['dojoId'],
    nameKey: map['nameKey'],
    avatarAsset: map['avatarAsset'],
    styleId: map['styleId'],
    belt: Belt(level: map['beltLevel'] ?? 1, danLevel: map['beltDan'] ?? 0),
    currentXP: map['currentXP'] ?? 0,
    stats: StudentStats.fromMap(map['stats'] ?? {}),
    tier: StudentTier.values.firstWhere((t) => t.name == map['tier'], orElse: () => StudentTier.bronze),
    skillPoints: map['skillPoints'] ?? 0,
    unlockedNodeIds: List<String>.from(map['unlockedNodeIds'] ?? []),
    fatiguePercent: map['fatiguePercent'] ?? 0,
    isInjured: map['isInjured'] ?? false,
    injuryWeeksRemaining: map['injuryWeeksRemaining'] ?? 0,
    trainingHistory: (map['trainingHistory'] as List? ?? [])
        .map((s) => TrainingSession.fromMap(s))
        .toList(),
    learningCoefficients: Map<String, double>.from(
      (map['learningCoefficients'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ) ?? {},
    ),
  );

  @override
  List<Object?> get props => [id];
}
