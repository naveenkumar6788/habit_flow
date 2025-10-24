class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final int points;
  final List<String> fcmTokens;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.points = 0,
    this.fcmTokens = const [],
  });

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'points': points,
        'fcmTokens': fcmTokens,
      };

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) => UserProfile(
        id: id,
        displayName: map['displayName'] as String?,
        email: map['email'] as String?,
        photoUrl: map['photoUrl'] as String?,
        points: (map['points'] ?? 0) as int,
        fcmTokens: (map['fcmTokens'] as List?)?.cast<String>() ?? const [],
      );
}
