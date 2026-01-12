import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración segura de variables de entorno
class EnvConfig {
  /// Cargar variables de entorno al iniciar la app
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // Si el archivo .env no existe, continuar sin error
      print('Warning: No se pudo cargar .env: $e');
    }
  }

  /// Obtener la API key de Gemini
  static String get geminiApiKey {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY no encontrada. Configure la variable de entorno.',
      );
    }
    return apiKey;
  }
}
