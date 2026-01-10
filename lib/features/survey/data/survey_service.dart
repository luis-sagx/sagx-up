import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/survey_response_model.dart';

class SurveyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Guardar respuesta de encuesta
  Future<void> saveSurveyResponse(SurveyResponse response) async {
    try {
      await _firestore
          .collection('surveys')
          .doc(response.id)
          .set(response.toMap());
    } catch (e) {
      throw Exception('Error al guardar encuesta: $e');
    }
  }

  // Obtener encuesta PRE de un usuario
  Future<SurveyResponse?> getPreSurvey(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('surveys')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'PRE')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return SurveyResponse.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      throw Exception('Error al obtener encuesta PRE: $e');
    }
  }

  // Obtener encuesta POST de un usuario
  Future<SurveyResponse?> getPostSurvey(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('surveys')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'POST')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return SurveyResponse.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      throw Exception('Error al obtener encuesta POST: $e');
    }
  }

  // Verificar si el usuario completó la encuesta PRE
  Future<bool> hasCompletedPreSurvey(String userId) async {
    try {
      final survey = await getPreSurvey(userId);
      return survey != null;
    } catch (e) {
      return false;
    }
  }

  // Verificar si el usuario completó la encuesta POST
  Future<bool> hasCompletedPostSurvey(String userId) async {
    try {
      final survey = await getPostSurvey(userId);
      return survey != null;
    } catch (e) {
      return false;
    }
  }

  // Verificar si han pasado 14 días desde el registro
  bool canCompletePostSurvey(DateTime registrationDate) {
    final daysSinceRegistration = DateTime.now()
        .difference(registrationDate)
        .inDays;
    return daysSinceRegistration >= 2;
  }

  // Obtener todas las encuestas (para panel de admin)
  Future<List<SurveyResponse>> getAllSurveys() async {
    try {
      final querySnapshot = await _firestore
          .collection('surveys')
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SurveyResponse.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener encuestas: $e');
    }
  }

  // Obtener encuestas de un usuario específico
  Future<List<SurveyResponse>> getUserSurveys(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('surveys')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => SurveyResponse.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener encuestas del usuario: $e');
    }
  }
}
