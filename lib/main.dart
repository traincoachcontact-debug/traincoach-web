// lib/main.dart (Versión con impresión manual de token)

import 'package:traincoach/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:developer' as developer; // Importante para un log más claro

// Proyecto
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/ad_service.dart';

// Pantallas
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/blocked_users_screen.dart';

final AdService adService = AdService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Correcto para depuración
  );

  // ===================================================================
  // Imprimimos el token de forma manual y clara
  // ===================================================================
  // Este "listener" se activará en cuanto el token esté disponible.
  FirebaseAppCheck.instance.onTokenChange.listen((token) {
    if (token != null) {
      // Usamos developer.log para que se vea mejor en la consola
      developer.log(
        '************************************************************',
        name: 'MI_APP_CHECK_TOKEN'
      );
      developer.log(
        '>>>> COPIA ESTE TOKEN DE DEBUG DE APP CHECK: <<<<',
        name: 'MI_APP_CHECK_TOKEN'
      );
      developer.log(token, name: 'MI_APP_CHECK_TOKEN');
      developer.log(
        '************************************************************',
        name: 'MI_APP_CHECK_TOKEN'
      );
    }
  });
  // ===================================================================

  runApp(
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

// El resto de tu código (MyApp, AuthWrapper) se queda exactamente igual.
// No es necesario pegarlo aquí de nuevo. Mantenlo como está.

// Pega este código reemplazando tu clase MyApp actual en lib/main.dart

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'TrainCoach',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          debugShowCheckedModeBanner: false,
          locale: settingsProvider.locale,

          // =======================================================
          // --- CORRECCIÓN PARA EL ERROR DE LOCALIZACIÓN ---
          // Cambiamos "AppLocalizations.delegate" por la creación
          // directa de la clase "AppLocalizationsDelegate()".
          // Esto es más robusto y soluciona el error que ves.
          // =======================================================
          localizationsDelegates: const [
            AppLocalizationsDelegate(), // <--- CAMBIO CLAVE
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
            Locale('pt'),
          ],
          home: const AuthWrapper(),
          routes: {
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/blockedUsers': (context) => const BlockedUsersScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}