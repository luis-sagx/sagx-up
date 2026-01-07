class AppUser {
  final String uid;
  final String name;
  final String email;
  final String level;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.level,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'level': level,
      'createdAt': createdAt,
    };
  }
}
