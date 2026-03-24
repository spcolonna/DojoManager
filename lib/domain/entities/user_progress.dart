class UserProgress {
  final String userId;
  final bool onboardingCompleted;
  final DateTime? createdAt;

  const UserProgress({
    required this.userId,
    required this.onboardingCompleted,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'onboardingCompleted': onboardingCompleted,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory UserProgress.fromMap(String userId, Map<String, dynamic> map) =>
      UserProgress(
        userId: userId,
        onboardingCompleted: map['onboardingCompleted'] ?? false,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'])
            : null,
      );
}