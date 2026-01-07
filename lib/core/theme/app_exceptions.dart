import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, this.code);

  @override
  String toString() => message;
}

class AuthExceptionHandler {
  static String handleException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'El correo electrónico no es válido';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';
        case 'user-not-found':
          return 'No existe una cuenta con este correo';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este correo ya está registrado';
        case 'operation-not-allowed':
          return 'Operación no permitida';
        case 'weak-password':
          return 'La contraseña debe tener al menos 6 caracteres';
        case 'invalid-credential':
          return 'Credenciales inválidas. Verifica tu correo y contraseña';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet';
        case 'requires-recent-login':
          return 'Por seguridad, vuelve a iniciar sesión';
        default:
          return 'Error: ${e.message ?? 'Algo salió mal'}';
      }
    }
    return 'Error inesperado. Intenta de nuevo';
  }
}
