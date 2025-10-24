class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'postId': postId,
        'userId': userId,
        'text': text,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) => CommentModel(
        id: id,
        postId: map['postId'] as String,
        userId: map['userId'] as String,
        text: map['text'] as String? ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now().toUtc(),
      );
}
