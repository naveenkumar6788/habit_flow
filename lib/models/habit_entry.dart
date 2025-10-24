class HabitEntry {
  final String id;
  final String habitId;
  final String ownerId;
  final String dayKey; 
  final bool completed;

  HabitEntry({
    required this.id,
    required this.habitId,
    required this.ownerId,
    required this.dayKey,
    required this.completed,
  });

  Map<String, dynamic> toMap() => {
        'habitId': habitId,
        'ownerId': ownerId,
        'dayKey': dayKey,
        'completed': completed,
      };

  factory HabitEntry.fromMap(String id, Map<String, dynamic> map) => HabitEntry(
        id: id,
        habitId: map['habitId'] as String,
        ownerId: map['ownerId'] as String,
        dayKey: map['dayKey'] as String,
        completed: map['completed'] as bool? ?? false,
      );
}
