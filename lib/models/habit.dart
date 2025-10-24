class Habit {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final bool archived;

  Habit({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.archived = false,
  });

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'archived': archived,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

  factory Habit.fromMap(String id, Map<String, dynamic> map) => Habit(
        id: id,
        ownerId: map['ownerId'] as String,
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        archived: map['archived'] as bool? ?? false,
      );
}
