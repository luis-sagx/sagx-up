import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'transaction_service.dart';
import 'budget_service.dart';

class GamificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  // ========== ACHIEVEMENTS ==========

  /// Verificar y desbloquear logros automáticamente
  Future<List<Achievement>> checkAndUnlockAchievements(String userId) async {
    try {
      final List<Achievement> unlockedAchievements = [];

      // Obtener TODOS los logros del usuario (desbloqueados y pendientes)
      final allAchievements = await getUserAchievements(userId);

      // Crear mapa: título -> logro existente
      final Map<String, Achievement> existingAchievementsMap = {};
      for (var achievement in allAchievements) {
        existingAchievementsMap[achievement.title] = achievement;
      }

      // Obtener datos necesarios
      final expenses = await _transactionService.getUserExpenses(userId);
      final incomes = await _transactionService.getUserIncomes(userId);
      final budgetStatus = await _budgetService.getBudgetStatus(userId);

      // Verificar cada template
      for (var template in AchievementTemplates.templates) {
        final title = template['title'] as String;
        final existingAchievement = existingAchievementsMap[title];

        // Si ya está desbloqueado (tiene unlockedAt), skip
        if (existingAchievement != null &&
            existingAchievement.unlockedAt != null) {
          continue;
        }

        bool shouldUnlock = false;

        // Lógica de desbloqueo según categoría
        switch (template['category']) {
          case 'milestone':
            if (title == 'Primera transacción') {
              shouldUnlock = expenses.isNotEmpty || incomes.isNotEmpty;
            } else if (title == 'Control total') {
              final totalExpenses = expenses.fold<double>(
                0,
                (sum, e) => sum + e.amount,
              );
              final impulsiveExpenses = expenses
                  .where((e) => e.isImpulsive)
                  .fold<double>(0, (sum, e) => sum + e.amount);
              final impulsivePercentage = totalExpenses > 0
                  ? (impulsiveExpenses / totalExpenses) * 100
                  : 0;
              shouldUnlock = impulsivePercentage < 20;
            }
            break;

          case 'streak':
            if (title == 'Racha de 7 días') {
              shouldUnlock = await _checkStreakDays(userId, 7);
            }
            break;

          case 'budget':
            if (title == 'Presupuesto cumplido') {
              if (budgetStatus['hasBudget']) {
                final percentageUsed = budgetStatus['percentageUsed'] as double;
                shouldUnlock = percentageUsed <= 100;
              }
            }
            break;

          case 'savings':
            if (title == 'Ahorrador novato') {
              final totalIncome = incomes.fold<double>(
                0,
                (sum, i) => sum + i.amount,
              );
              final totalExpense = expenses.fold<double>(
                0,
                (sum, e) => sum + e.amount,
              );
              final savings = totalIncome - totalExpense;
              final savingsPercentage = totalIncome > 0
                  ? (savings / totalIncome) * 100
                  : 0;
              shouldUnlock = savingsPercentage >= 10;
            }
            break;
        }

        // Si debe desbloquearse
        if (shouldUnlock) {
          if (existingAchievement != null) {
            // Actualizar logro existente agregando unlockedAt
            await _db
                .collection('achievements')
                .doc(existingAchievement.id)
                .update({'unlockedAt': FieldValue.serverTimestamp()});

            final updatedAchievement = existingAchievement.copyWith(
              unlockedAt: DateTime.now(),
            );
            unlockedAchievements.add(updatedAchievement);

            // Actualizar puntos del usuario
            await _addPoints(userId, template['points'] as int);
          } else {
            // Crear nuevo logro
            final achievement = Achievement(
              userId: userId,
              title: title,
              description: template['description'] as String,
              icon: template['icon'] as String,
              points: template['points'] as int,
              category: template['category'] as String,
            );

            final docRef = await _db
                .collection('achievements')
                .add(achievement.toMap());
            unlockedAchievements.add(achievement.copyWith(id: docRef.id));

            // Actualizar puntos del usuario
            await _addPoints(userId, template['points'] as int);
          }
        }
      }

      return unlockedAchievements;
    } catch (e) {
      print('Error verificando logros: $e');
      return [];
    }
  }

  /// Verificar racha de días consecutivos con transacciones
  Future<bool> _checkStreakDays(String userId, int requiredDays) async {
    try {
      final now = DateTime.now();
      final daysToCheck = requiredDays;

      // Obtener transacciones de los últimos N días
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final expenses = await _transactionService.getUserExpenses(
        userId,
        month: month,
      );
      final incomes = await _transactionService.getUserIncomes(
        userId,
        month: month,
      );

      // Crear set de fechas con transacciones
      final Set<String> transactionDates = {};
      for (var expense in expenses) {
        final dateStr =
            '${expense.date.year}-${expense.date.month}-${expense.date.day}';
        transactionDates.add(dateStr);
      }
      for (var income in incomes) {
        final dateStr =
            '${income.date.year}-${income.date.month}-${income.date.day}';
        transactionDates.add(dateStr);
      }

      // Verificar días consecutivos
      int consecutiveDays = 0;
      for (int i = 0; i < daysToCheck; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final dateStr = '${checkDate.year}-${checkDate.month}-${checkDate.day}';

        if (transactionDates.contains(dateStr)) {
          consecutiveDays++;
        } else {
          break; // Rompe la racha
        }
      }

      return consecutiveDays >= requiredDays;
    } catch (e) {
      print('Error verificando racha: $e');
      return false;
    }
  }

  /// Obtener logros del usuario
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _db
          .collection('achievements')
          .where('userId', isEqualTo: userId)
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error obteniendo logros: $e');
      return [];
    }
  }

  // ========== POINTS & LEVELS ==========

  /// Agregar puntos al usuario y actualizar nivel
  Future<void> _addPoints(String userId, int points) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final currentPoints = userData['points'] ?? 0;
      final newPoints = currentPoints + points;

      // Calcular nuevo nivel
      final newLevel = _calculateLevel(newPoints);

      await _db.collection('users').doc(userId).update({
        'points': newPoints,
        'level': newLevel,
      });
    } catch (e) {
      print('Error agregando puntos: $e');
    }
  }

  /// Calcular nivel basado en puntos
  String _calculateLevel(int points) {
    if (points >= 1000) return 'Maestro Financiero';
    if (points >= 750) return 'Estratégico';
    if (points >= 500) return 'Responsable';
    if (points >= 300) return 'Organizado';
    if (points >= 150) return 'Novato';
    return 'Principiante';
  }

  /// Award points for registering a transaction
  Future<void> awardPointsForTransaction(
    String userId, {
    required bool isExpense,
  }) async {
    try {
      // Award 10 points for expense, 15 for income
      final pointsToAward = isExpense ? 10 : 15;
      await _addPoints(userId, pointsToAward);
    } catch (e) {
      print('Error awarding transaction points: $e');
    }
  }

  /// Backfill points for existing transactions (one-time utility)
  Future<void> backfillPoints(String userId, int totalPoints) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      // Calculate new level
      final newLevel = _calculateLevel(totalPoints);

      await _db.collection('users').doc(userId).update({
        'points': totalPoints,
        'level': newLevel,
      });
    } catch (e) {
      print('Error backfilling points: $e');
    }
  }

  /// Calcular nivel numérico basado en puntos (público)
  int calculateLevel(int points) {
    if (points >= 1000) return 6;
    if (points >= 750) return 5;
    if (points >= 500) return 4;
    if (points >= 300) return 3;
    if (points >= 150) return 2;
    return 1;
  }

  /// Obtener puntos necesarios para el siguiente nivel
  int pointsForNextLevel(int currentLevel) {
    switch (currentLevel) {
      case 1:
        return 150;
      case 2:
        return 300;
      case 3:
        return 500;
      case 4:
        return 750;
      case 5:
        return 1000;
      default:
        return 1000; // Nivel máximo
    }
  }

  /// Obtener puntos y nivel actual del usuario
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {
          'points': 0,
          'level': 'Principiante',
          'nextLevel': 'Novato',
          'pointsToNextLevel': 150,
        };
      }

      final userData = userDoc.data()!;
      final points = userData['points'] ?? 0;
      final level = userData['level'] ?? 'Principiante';

      // Calcular próximo nivel
      final levelInfo = _getNextLevelInfo(points, level);

      return {
        'points': points,
        'level': level,
        'nextLevel': levelInfo['nextLevel'],
        'pointsToNextLevel': levelInfo['pointsNeeded'],
      };
    } catch (e) {
      print('Error obteniendo progreso: $e');
      return {
        'points': 0,
        'level': 'Principiante',
        'nextLevel': 'Novato',
        'pointsToNextLevel': 150,
      };
    }
  }

  /// Obtener información del próximo nivel
  Map<String, dynamic> _getNextLevelInfo(
    int currentPoints,
    String currentLevel,
  ) {
    final levels = [
      {'name': 'Principiante', 'minPoints': 0},
      {'name': 'Novato', 'minPoints': 150},
      {'name': 'Organizado', 'minPoints': 300},
      {'name': 'Responsable', 'minPoints': 500},
      {'name': 'Estratégico', 'minPoints': 750},
      {'name': 'Maestro Financiero', 'minPoints': 1000},
    ];

    for (int i = 0; i < levels.length - 1; i++) {
      if (levels[i]['name'] == currentLevel) {
        final nextLevel = levels[i + 1];
        return {
          'nextLevel': nextLevel['name'],
          'pointsNeeded': (nextLevel['minPoints'] as int) - currentPoints,
        };
      }
    }

    return {'nextLevel': 'Máximo alcanzado', 'pointsNeeded': 0};
  }

  // ========== REWARDS ==========

  /// Dar puntos por acciones del usuario
  Future<void> rewardAction(String userId, String action) async {
    try {
      int points = 0;

      switch (action) {
        case 'expense_registered':
          points = AppConstants.pointsPerExpenseRegistered;
          break;
        case 'income_registered':
          points = AppConstants.pointsPerIncomeRegistered;
          break;
        case 'budget_set':
          points = 25;
          break;
        case 'budget_complied':
          points = AppConstants.pointsPerBudgetCompliance;
          break;
      }

      if (points > 0) {
        await _addPoints(userId, points);
      }
    } catch (e) {
      print('Error recompensando acción: $e');
    }
  }

  /// Stream de logros en tiempo real
  Stream<List<Achievement>> watchUserAchievements(String userId) {
    return _db
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Achievement.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
