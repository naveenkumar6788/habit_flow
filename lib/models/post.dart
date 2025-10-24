class Post {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final List<String> likes;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likes = const [],
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'content': content,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'likes': likes,
      };

  factory Post.fromMap(String id, Map<String, dynamic> map) => Post(
        id: id,
        userId: map['userId'] as String,
        content: map['content'] as String? ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now().toUtc(),
        likes: (map['likes'] as List?)?.cast<String>() ?? const [],
      );
}
