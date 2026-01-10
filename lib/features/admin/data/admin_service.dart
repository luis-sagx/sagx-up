import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Retrieve data from all users to generate statistics
  Future<Map<String, dynamic>> getAllUsersStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      int totalUsers = usersSnapshot.docs.length;
      int preGroup = 0;
      int postGroup = 0;

      double preTotalIncome = 0;
      double preTotalExpenses = 0;
      double postTotalIncome = 0;
      double postTotalExpenses = 0;

      List<Map<String, dynamic>> allUsersData = [];

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final String uid = userDoc.id;
        final String period =
            userData['survey_period'] ?? 'PRE'; // Default to PRE if not set

        // This is an expensive operation (N+1 reads) but necessary without aggregation functions
        // In a real production app with thousands of users, use Cloud Functions.
        final transactionSummary = await _getUserTransactionSummary(uid);

        final double userIncome = transactionSummary['totalIncome'] ?? 0.0;
        final double userExpense = transactionSummary['totalExpense'] ?? 0.0;

        if (period == 'PRE') {
          preGroup++;
          preTotalIncome += userIncome;
          preTotalExpenses += userExpense;
        } else {
          postGroup++;
          postTotalIncome += userIncome;
          postTotalExpenses += userExpense;
        }

        allUsersData.add({
          'uid': uid,
          'email': userData['email'] ?? 'Unknown',
          'period': period,
          'income': userIncome.toStringAsFixed(2),
          'expense': userExpense.toStringAsFixed(2),
          'balance': (userIncome - userExpense).toStringAsFixed(2),
          'joinDate':
              userData['createdAt']?.toDate().toString() ??
              DateTime.now().toString(),
        });
      }

      return {
        'totalUsers': totalUsers,
        'preStats': {
          'count': preGroup,
          'avgIncome': preGroup > 0 ? preTotalIncome / preGroup : 0,
          'avgExpense': preGroup > 0 ? preTotalExpenses / preGroup : 0,
          'totalIncome': preTotalIncome,
          'totalExpense': preTotalExpenses,
        },
        'postStats': {
          'count': postGroup,
          'avgIncome': postGroup > 0 ? postTotalIncome / postGroup : 0,
          'avgExpense': postGroup > 0 ? postTotalExpenses / postGroup : 0,
          'totalIncome': postTotalIncome,
          'totalExpense': postTotalExpenses,
        },
        'rawList': allUsersData,
      };
    } catch (e) {
      print('Error getting admin stats: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> _getUserTransactionSummary(String uid) async {
    // We'll just look at the current month or ALL time?
    // For scientific analysis, usually ALL time or a specific window is needed.
    // For now we do ALL time to keep it simple.

    double income = 0;
    double expense = 0;

    // Get incomes
    final incomesSnapshot = await _firestore
        .collection('incomes')
        .where('userId', isEqualTo: uid)
        .get();

    for (var doc in incomesSnapshot.docs) {
      income += (doc.data()['amount'] ?? 0.0);
    }

    // Get expenses
    final expensesSnapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: uid)
        .get();

    for (var doc in expensesSnapshot.docs) {
      expense += (doc.data()['amount'] ?? 0.0);
    }

    return {'totalIncome': income, 'totalExpense': expense};
  }
}
