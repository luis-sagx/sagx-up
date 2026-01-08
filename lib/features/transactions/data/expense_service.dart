import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/expense_model.dart';

class ExpenseService {
  final _db = FirebaseFirestore.instance;

  // Crear gasto
  Future<String> createExpense(Expense expense) async {
    final docRef = await _db.collection('expenses').add(expense.toMap());
    return docRef.id;
  }

  // Obtener gastos del usuario
  Future<List<Expense>> getUserExpenses(String userId) async {
    final snapshot = await _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Obtener gastos del mes actual
  Future<List<Expense>> getMonthlyExpenses(
    String userId,
    DateTime month,
  ) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Obtener gastos por categoría
  Future<Map<String, double>> getExpensesByCategory(
    String userId,
    DateTime month,
  ) async {
    final expenses = await getMonthlyExpenses(userId, month);
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  // Actualizar gasto
  Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) return;
    await _db.collection('expenses').doc(expense.id).update(expense.toMap());
  }

  // Eliminar gasto
  Future<void> deleteExpense(String expenseId) async {
    await _db.collection('expenses').doc(expenseId).delete();
  }

  // Obtener total de gastos del mes
  Future<double> getMonthlyTotal(String userId, DateTime month) async {
    final expenses = await getMonthlyExpenses(userId, month);
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  // Obtener porcentaje de gastos impulsivos
  Future<double> getImpulsiveExpensesPercentage(
    String userId,
    DateTime month,
  ) async {
    final expenses = await getMonthlyExpenses(userId, month);
    if (expenses.isEmpty) return 0;

    final impulsiveCount = expenses.where((e) => e.isImpulsive).length;
    return (impulsiveCount / expenses.length) * 100;
  }

  // Stream de gastos en tiempo real
  Stream<List<Expense>> getUserExpensesStream(String userId) {
    return _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
