class SurveyResponse {
  final String id;
  final String userId;
  final String type; // 'PRE' o 'POST'
  final DateTime completedAt;

  // Datos de control (solo en PRE)
  final String? career;
  final int? semester;
  final bool? hasOwnIncome;

  // Dimensión 1: Conocimiento financiero percibido (1-5)
  final int knowledgeIncomeExpenses;
  final int knowledgeBudget;
  final int knowledgeDecisions;
  final int knowledgeSavings;

  // Dimensión 2: Hábitos de ahorro (1-5)
  final int savingsConsistency;
  final int savingsConsideration;
  final int savingsAllocation;
  final int savingsGoals;

  // Dimensión 3: Control y seguimiento de gastos (1-5)
  final int trackingOrganization;
  final int trackingFrequency;
  final int trackingCategories;
  final int trackingAwareness;

  // Dimensión 4: Autorregulación financiera (1-5)
  final int selfRegulationPlanning;
  final int selfRegulationEvaluation;
  final int selfRegulationAdjustment;
  final int selfRegulationImprovement;

  // Dimensión 5: Uso de herramientas digitales (1-5)
  final int toolsPerception;
  final int toolsEaseOfUse;
  final int toolsInfluence;
  final int toolsMotivation;

  SurveyResponse({
    required this.id,
    required this.userId,
    required this.type,
    required this.completedAt,
    this.career,
    this.semester,
    this.hasOwnIncome,
    required this.knowledgeIncomeExpenses,
    required this.knowledgeBudget,
    required this.knowledgeDecisions,
    required this.knowledgeSavings,
    required this.savingsConsistency,
    required this.savingsConsideration,
    required this.savingsAllocation,
    required this.savingsGoals,
    required this.trackingOrganization,
    required this.trackingFrequency,
    required this.trackingCategories,
    required this.trackingAwareness,
    required this.selfRegulationPlanning,
    required this.selfRegulationEvaluation,
    required this.selfRegulationAdjustment,
    required this.selfRegulationImprovement,
    required this.toolsPerception,
    required this.toolsEaseOfUse,
    required this.toolsInfluence,
    required this.toolsMotivation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'completedAt': completedAt.toIso8601String(),
      'career': career,
      'semester': semester,
      'hasOwnIncome': hasOwnIncome,
      'knowledgeIncomeExpenses': knowledgeIncomeExpenses,
      'knowledgeBudget': knowledgeBudget,
      'knowledgeDecisions': knowledgeDecisions,
      'knowledgeSavings': knowledgeSavings,
      'savingsConsistency': savingsConsistency,
      'savingsConsideration': savingsConsideration,
      'savingsAllocation': savingsAllocation,
      'savingsGoals': savingsGoals,
      'trackingOrganization': trackingOrganization,
      'trackingFrequency': trackingFrequency,
      'trackingCategories': trackingCategories,
      'trackingAwareness': trackingAwareness,
      'selfRegulationPlanning': selfRegulationPlanning,
      'selfRegulationEvaluation': selfRegulationEvaluation,
      'selfRegulationAdjustment': selfRegulationAdjustment,
      'selfRegulationImprovement': selfRegulationImprovement,
      'toolsPerception': toolsPerception,
      'toolsEaseOfUse': toolsEaseOfUse,
      'toolsInfluence': toolsInfluence,
      'toolsMotivation': toolsMotivation,
    };
  }

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      completedAt: DateTime.parse(map['completedAt']),
      career: map['career'],
      semester: map['semester'],
      hasOwnIncome: map['hasOwnIncome'],
      knowledgeIncomeExpenses: map['knowledgeIncomeExpenses'] ?? 0,
      knowledgeBudget: map['knowledgeBudget'] ?? 0,
      knowledgeDecisions: map['knowledgeDecisions'] ?? 0,
      knowledgeSavings: map['knowledgeSavings'] ?? 0,
      savingsConsistency: map['savingsConsistency'] ?? 0,
      savingsConsideration: map['savingsConsideration'] ?? 0,
      savingsAllocation: map['savingsAllocation'] ?? 0,
      savingsGoals: map['savingsGoals'] ?? 0,
      trackingOrganization: map['trackingOrganization'] ?? 0,
      trackingFrequency: map['trackingFrequency'] ?? 0,
      trackingCategories: map['trackingCategories'] ?? 0,
      trackingAwareness: map['trackingAwareness'] ?? 0,
      selfRegulationPlanning: map['selfRegulationPlanning'] ?? 0,
      selfRegulationEvaluation: map['selfRegulationEvaluation'] ?? 0,
      selfRegulationAdjustment: map['selfRegulationAdjustment'] ?? 0,
      selfRegulationImprovement: map['selfRegulationImprovement'] ?? 0,
      toolsPerception: map['toolsPerception'] ?? 0,
      toolsEaseOfUse: map['toolsEaseOfUse'] ?? 0,
      toolsInfluence: map['toolsInfluence'] ?? 0,
      toolsMotivation: map['toolsMotivation'] ?? 0,
    );
  }
}
