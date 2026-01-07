import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_exceptions.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro
  Future<User?> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthExceptionHandler.handleException(e), e.code);
    } catch (e) {
      throw AuthException('Error inesperado al registrarse', 'unknown');
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthExceptionHandler.handleException(e), e.code);
    } catch (e) {
      throw AuthException('Error inesperado al iniciar sesión', 'unknown');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión', 'logout-error');
    }
  }

  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
