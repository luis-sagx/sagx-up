import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/metrics_model.dart';
import '../../../models/expense_model.dart';
import '../../../models/income_model.dart';
import '../../../models/budget_model.dart';

class MetricsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Determina si el usuario está en período PRE o POST
  /// Todos los usuarios son POST
  Future<String> determinePeriod(String userId) async {
    return 'post';
  }

  /// Calcula las métricas financieras del mes actual
  Future<FinancialMetrics?> calculateMonthlyMetrics(String userId) async {
    try {
      final now = DateTime.now();
      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      // Obtener período (pre/post)
      final period = await determinePeriod(userId);

      // Obtener gastos del mes
      final expensesSnapshot = await _db
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: month)
          .get();

      final expenses = expensesSnapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList();

      // Obtener ingresos del mes
      final incomesSnapshot = await _db
          .collection('incomes')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: month)
          .get();

      final incomes = incomesSnapshot.docs
          .map((doc) => Income.fromMap(doc.data(), doc.id))
          .toList();

      // Calcular totales
      final totalExpenses = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      final totalIncome = incomes.fold<double>(
        0,
        (sum, income) => sum + income.amount,
      );

      final savings = totalIncome - totalExpenses;

      // Calcular gastos impulsivos
      final impulsiveExpenses = expenses.where((e) => e.isImpulsive).toList();
      final impulsiveTotal = impulsiveExpenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      final impulsivePercentage = totalExpenses > 0
          ? (impulsiveTotal / totalExpenses) * 100
          : 0.0;

      // Obtener presupuesto del mes
      final budgetSnapshot = await _db
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: month)
          .limit(1)
          .get();

      double budgetCompliance = 100.0;
      if (budgetSnapshot.docs.isNotEmpty) {
        final budget = Budget.fromMap(
          budgetSnapshot.docs.first.data(),
          budgetSnapshot.docs.first.id,
        );

        if (budget.monthlyLimit > 0) {
          budgetCompliance = totalExpenses <= budget.monthlyLimit
              ? 100.0
              : (budget.monthlyLimit / totalExpenses) * 100;
        }
      }

      // Calcular frecuencia de registro (días con transacciones)
      final transactionDates = <DateTime>{};
      for (var expense in expenses) {
        transactionDates.add(
          DateTime(expense.date.year, expense.date.month, expense.date.day),
        );
      }
      for (var income in incomes) {
        transactionDates.add(
          DateTime(income.date.year, income.date.month, income.date.day),
        );
      }
      final registrationFrequency = transactionDates.length;

      // Calcular porcentaje de ahorro
      final savingsPercentage = totalIncome > 0
          ? (savings / totalIncome) * 100
          : 0.0;

      // Calcular score de control financiero
      final controlScore = FinancialMetrics.calculateControlScore(
        budgetCompliance: budgetCompliance,
        impulsivePercentage: impulsivePercentage,
        savingsPercentage: savingsPercentage.clamp(0, 100),
        registrationFrequency: registrationFrequency,
      );

      // Crear objeto de métricas
      final metrics = FinancialMetrics(
        userId: userId,
        totalExpenses: totalExpenses,
        totalIncome: totalIncome,
        savings: savings,
        impulsiveExpensesPercentage: impulsivePercentage,
        budgetCompliancePercentage: budgetCompliance,
        controlScore: controlScore,
        period: period,
        month: month,
      );

      // Guardar en Firestore
      final docRef = await _db.collection('metrics').add(metrics.toMap());

      return metrics.copyWith(id: docRef.id);
    } catch (e) {
      print('Error calculando métricas: $e');
      return null;
    }
  }

  /// Obtener métricas de un mes específico
  Future<FinancialMetrics?> getMonthlyMetrics(
    String userId,
    String month,
  ) async {
    try {
      final snapshot = await _db
          .collection('metrics')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: month)
          .orderBy('calculatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return FinancialMetrics.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      print('Error obteniendo métricas: $e');
      return null;
    }
  }

  /// Obtener historial de métricas (últimos 6 meses)
  Future<List<FinancialMetrics>> getMetricsHistory(String userId) async {
    try {
      final snapshot = await _db
          .collection('metrics')
          .where('userId', isEqualTo: userId)
          .orderBy('month', descending: true)
          .limit(6)
          .get();

      return snapshot.docs
          .map((doc) => FinancialMetrics.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error obteniendo historial: $e');
      return [];
    }
  }

  /// Comparar métricas PRE vs POST
  Future<Map<String, dynamic>> comparePrePost(String userId) async {
    try {
      // Obtener métricas PRE
      final preMetrics = await _db
          .collection('metrics')
          .where('userId', isEqualTo: userId)
          .where('period', isEqualTo: 'pre')
          .get();

      // Obtener métricas POST
      final postMetrics = await _db
          .collection('metrics')
          .where('userId', isEqualTo: userId)
          .where('period', isEqualTo: 'post')
          .get();

      if (preMetrics.docs.isEmpty || postMetrics.docs.isEmpty) {
        return {'hasData': false};
      }

      // Calcular promedios PRE
      final preList = preMetrics.docs
          .map((doc) => FinancialMetrics.fromMap(doc.data(), doc.id))
          .toList();

      final preAvgScore =
          preList.fold<double>(0, (sum, m) => sum + m.controlScore) /
          preList.length;

      final preAvgImpulsive =
          preList.fold<double>(
            0,
            (sum, m) => sum + m.impulsiveExpensesPercentage,
          ) /
          preList.length;

      // Calcular promedios POST
      final postList = postMetrics.docs
          .map((doc) => FinancialMetrics.fromMap(doc.data(), doc.id))
          .toList();

      final postAvgScore =
          postList.fold<double>(0, (sum, m) => sum + m.controlScore) /
          postList.length;

      final postAvgImpulsive =
          postList.fold<double>(
            0,
            (sum, m) => sum + m.impulsiveExpensesPercentage,
          ) /
          postList.length;

      // Calcular mejoras
      final scoreImprovement = postAvgScore - preAvgScore;
      final impulsiveReduction = preAvgImpulsive - postAvgImpulsive;

      return {
        'hasData': true,
        'pre': {
          'avgScore': preAvgScore,
          'avgImpulsive': preAvgImpulsive,
          'count': preList.length,
        },
        'post': {
          'avgScore': postAvgScore,
          'avgImpulsive': postAvgImpulsive,
          'count': postList.length,
        },
        'improvement': {
          'score': scoreImprovement,
          'impulsive': impulsiveReduction,
          'scorePercentage': preAvgScore > 0
              ? (scoreImprovement / preAvgScore) * 100
              : 0,
        },
      };
    } catch (e) {
      print('Error comparando Pre/Post: $e');
      return {'hasData': false, 'error': e.toString()};
    }
  }
}
