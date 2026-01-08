import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialMetrics {
  final String? id;
  final String userId;
  final double totalExpenses;
  final double totalIncome;
  final double savings;
  final double impulsiveExpensesPercentage;
  final double budgetCompliancePercentage;
  final int controlScore; // Score de control financiero (0-100)
  final String period; // 'pre' o 'post'
  final String month; // Formato: "2026-01"
  final DateTime calculatedAt;

  FinancialMetrics({
    this.id,
    required this.userId,
    required this.totalExpenses,
    required this.totalIncome,
    required this.savings,
    required this.impulsiveExpensesPercentage,
    required this.budgetCompliancePercentage,
    required this.controlScore,
    required this.period,
    required this.month,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'savings': savings,
      'impulsiveExpensesPercentage': impulsiveExpensesPercentage,
      'budgetCompliancePercentage': budgetCompliancePercentage,
      'controlScore': controlScore,
      'period': period,
      'month': month,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }

  factory FinancialMetrics.fromMap(Map<String, dynamic> map, String id) {
    return FinancialMetrics(
      id: id,
      userId: map['userId'] ?? '',
      totalExpenses: (map['totalExpenses'] ?? 0).toDouble(),
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      savings: (map['savings'] ?? 0).toDouble(),
      impulsiveExpensesPercentage: (map['impulsiveExpensesPercentage'] ?? 0)
          .toDouble(),
      budgetCompliancePercentage: (map['budgetCompliancePercentage'] ?? 0)
          .toDouble(),
      controlScore: map['controlScore'] ?? 0,
      period: map['period'] ?? 'pre',
      month: map['month'] ?? '',
      calculatedAt: (map['calculatedAt'] as Timestamp).toDate(),
    );
  }

  // Calcular score de control financiero
  static int calculateControlScore({
    required double budgetCompliance,
    required double impulsivePercentage,
    required double savingsPercentage,
    required int registrationFrequency, // días con registros en el mes
  }) {
    // Fórmula ponderada (0-100)
    double score = 0;

    // Cumplimiento de presupuesto (40%)
    score += (budgetCompliance / 100) * 40;

    // Control de gastos impulsivos (30%)
    score += ((100 - impulsivePercentage) / 100) * 30;

    // Capacidad de ahorro (20%)
    score += (savingsPercentage / 100) * 20;

    // Disciplina de registro (10%)
    score += (registrationFrequency / 30) * 10;

    return score.clamp(0, 100).round();
  }

  FinancialMetrics copyWith({
    String? id,
    String? userId,
    double? totalExpenses,
    double? totalIncome,
    double? savings,
    double? impulsiveExpensesPercentage,
    double? budgetCompliancePercentage,
    int? controlScore,
    String? period,
    String? month,
    DateTime? calculatedAt,
  }) {
    return FinancialMetrics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalIncome: totalIncome ?? this.totalIncome,
      savings: savings ?? this.savings,
      impulsiveExpensesPercentage:
          impulsiveExpensesPercentage ?? this.impulsiveExpensesPercentage,
      budgetCompliancePercentage:
          budgetCompliancePercentage ?? this.budgetCompliancePercentage,
      controlScore: controlScore ?? this.controlScore,
      period: period ?? this.period,
      month: month ?? this.month,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
