import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env_config.dart';
import 'core/services/notification_service.dart';
import 'features/home/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await EnvConfig.load();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar Notificaciones
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sagx UP',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
