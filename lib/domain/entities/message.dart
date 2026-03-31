enum MessageType { tournamentInvite, cupInvite, devMessage, system }

class AppMessage {
  final String id;
  final MessageType type;
  final String titleKey;
  final String bodyKey;
  final Map<String, dynamic> params;
  final bool isRead;
  final DateTime createdAt;

  const AppMessage({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    this.params = const {},
    required this.isRead,
    required this.createdAt,
  });

  AppMessage copyWith({bool? isRead}) => AppMessage(
    id: id, type: type, titleKey: titleKey, bodyKey: bodyKey,
    params: params, isRead: isRead ?? this.isRead, createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'titleKey': titleKey,
    'bodyKey': bodyKey,
    'params': params,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppMessage.fromMap(Map<String, dynamic> map) => AppMessage(
    id: map['id'] ?? '',
    type: MessageType.values.firstWhere(
          (t) => t.name == map['type'],
      orElse: () => MessageType.system,
    ),
    titleKey: map['titleKey'] ?? '',
    bodyKey: map['bodyKey'] ?? '',
    params: Map<String, dynamic>.from(map['params'] ?? {}),
    isRead: map['isRead'] ?? false,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}