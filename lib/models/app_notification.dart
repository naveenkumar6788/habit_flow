class AppNotification {
  final String id;
  final String userId;
  final String type; 
  final String message;
  final String? refId;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.refId,
    required this.read,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'message': message,
        'refId': refId,
        'read': read,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) => AppNotification(
        id: id,
        userId: map['userId'] as String,
        type: map['type'] as String? ?? 'system',
        message: map['message'] as String? ?? '',
        refId: map['refId'] as String?,
        read: map['read'] as bool? ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now().toUtc(),
      );
}
