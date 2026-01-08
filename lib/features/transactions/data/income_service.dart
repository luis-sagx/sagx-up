import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/income_model.dart';

class IncomeService {
  final _db = FirebaseFirestore.instance;

  // Crear ingreso
  Future<String> createIncome(Income income) async {
    final docRef = await _db.collection('incomes').add(income.toMap());
    return docRef.id;
  }

  // Obtener ingresos del usuario
  Future<List<Income>> getUserIncomes(String userId) async {
    final snapshot = await _db
        .collection('incomes')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Income.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Obtener ingresos del mes
  Future<List<Income>> getMonthlyIncomes(String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection('incomes')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Income.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Actualizar ingreso
  Future<void> updateIncome(Income income) async {
    if (income.id == null) return;
    await _db.collection('incomes').doc(income.id).update(income.toMap());
  }

  // Eliminar ingreso
  Future<void> deleteIncome(String incomeId) async {
    await _db.collection('incomes').doc(incomeId).delete();
  }

  // Obtener total de ingresos del mes
  Future<double> getMonthlyTotal(String userId, DateTime month) async {
    final incomes = await getMonthlyIncomes(userId, month);
    return incomes.fold<double>(0, (sum, income) => sum + income.amount);
  }

  // Stream de ingresos en tiempo real
  Stream<List<Income>> getUserIncomesStream(String userId) {
    return _db
        .collection('incomes')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Income.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
