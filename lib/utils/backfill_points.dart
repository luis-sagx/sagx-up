import '../features/transactions/data/transaction_service.dart';
import '../features/achievements/data/gamification_service.dart';
import '../core/services/firebase_service.dart';

/// Utility to backfill points for existing transactions
class BackfillPointsUtility {
  final _transactionService = TransactionService();
  final _gamificationService = GamificationService();
  final _firebaseService = FirebaseService();

  /// Calculate and award points for all existing transactions
  Future<Map<String, dynamic>> backfillAllPoints() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user authenticated'};
      }

      // Get all transactions
      final expenses = await _transactionService.getUserExpenses(user.uid);
      final incomes = await _transactionService.getUserIncomes(user.uid);

      // Calculate points
      final expensePoints = expenses.length * 10; // 10 points per expense
      final incomePoints = incomes.length * 15; // 15 points per income
      final totalPoints = expensePoints + incomePoints;

      // Award points directly
      await _gamificationService.backfillPoints(user.uid, totalPoints);

      // Check and unlock achievements
      await _gamificationService.checkAndUnlockAchievements(user.uid);

      return {
        'success': true,
        'expenseCount': expenses.length,
        'incomeCount': incomes.length,
        'expensePoints': expensePoints,
        'incomePoints': incomePoints,
        'totalPoints': totalPoints,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
