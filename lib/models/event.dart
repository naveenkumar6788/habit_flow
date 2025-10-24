class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final List<String> rsvps;
  final String createdBy;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.createdBy,
    this.rsvps = const [],
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'rsvps': rsvps,
        'createdBy': createdBy,
      };

  factory EventModel.fromMap(String id, Map<String, dynamic> map) => EventModel(
        id: id,
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        dateTime: DateTime.tryParse(map['dateTime'] as String? ?? '') ?? DateTime.now().toUtc(),
        rsvps: (map['rsvps'] as List?)?.cast<String>() ?? const [],
        createdBy: map['createdBy'] as String? ?? '',
      );
}
