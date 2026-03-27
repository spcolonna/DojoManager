class TrainingSession {
  final String dayKey;
  final List<String> activityIds;
  final int xpGained;
  final int phGained;
  final int fatigueAfter;
  final bool leveledUp;
  final String? newBeltKey;
  final DateTime date;

  const TrainingSession({
    required this.dayKey,
    required this.activityIds,
    required this.xpGained,
    required this.phGained,
    required this.fatigueAfter,
    required this.leveledUp,
    this.newBeltKey,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'dayKey': dayKey,
    'activityIds': activityIds,
    'xpGained': xpGained,
    'phGained': phGained,
    'fatigueAfter': fatigueAfter,
    'leveledUp': leveledUp,
    'newBeltKey': newBeltKey,
    'date': date.toIso8601String(),
  };

  factory TrainingSession.fromMap(Map<String, dynamic> map) => TrainingSession(
    dayKey: map['dayKey'] ?? '',
    activityIds: List<String>.from(map['activityIds'] ?? []),
    xpGained: map['xpGained'] ?? 0,
    phGained: map['phGained'] ?? 0,
    fatigueAfter: map['fatigueAfter'] ?? 0,
    leveledUp: map['leveledUp'] ?? false,
    newBeltKey: map['newBeltKey'],
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
  );
}