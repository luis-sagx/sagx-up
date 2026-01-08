class AppUser {
  final String uid;
  final String name;
  final String email;
  final String level;
  final int points;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.level,
    this.points = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'level': level,
      'points': points,
      'createdAt': createdAt,
    };
  }
}
