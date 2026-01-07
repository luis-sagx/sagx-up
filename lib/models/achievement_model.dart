import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String icon; // Nombre del icono
  final int points;
  final DateTime unlockedAt;
  final String category; // 'streak', 'budget', 'savings', 'milestone'

  Achievement({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    DateTime? unlockedAt,
    required this.category,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'category': category,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map, String id) {
    return Achievement(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'emoji_events',
      points: map['points'] ?? 0,
      unlockedAt: (map['unlockedAt'] as Timestamp).toDate(),
      category: map['category'] ?? 'milestone',
    );
  }
}

// Logros predefinidos del sistema
class AchievementTemplates {
  static const List<Map<String, dynamic>> templates = [
    {
      'title': 'Primera transacción',
      'description': 'Registraste tu primer gasto o ingreso',
      'icon': 'star',
      'points': 10,
      'category': 'milestone',
    },
    {
      'title': 'Racha de 7 días',
      'description': 'Registraste transacciones durante 7 días consecutivos',
      'icon': 'local_fire_department',
      'points': 50,
      'category': 'streak',
    },
    {
      'title': 'Presupuesto cumplido',
      'description': 'Completaste un mes sin exceder tu presupuesto',
      'icon': 'check_circle',
      'points': 100,
      'category': 'budget',
    },
    {
      'title': 'Ahorrador novato',
      'description': 'Ahorraste al menos 10% de tus ingresos',
      'icon': 'savings',
      'points': 75,
      'category': 'savings',
    },
    {
      'title': 'Control total',
      'description': 'Mantuviste gastos impulsivos bajo 20%',
      'icon': 'psychology',
      'points': 150,
      'category': 'milestone',
    },
  ];
}
