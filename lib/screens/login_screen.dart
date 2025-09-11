// Crea este archivo en: lib/screens/login_screen.dart
import 'package:traincoach/services/auth_service.dart'; // Importa el servicio que creamos
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instanciamos el servicio de autenticación
    final AuthService authService = AuthService();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Puedes añadir el logo de tu app aquí
            Text(
              'Bienvenido a TrainCoach',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.login), // Puedes usar un logo de Google aquí
              label: const Text('Iniciar sesión con Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                // Al presionar el botón, llamamos a la función de inicio de sesión.
                // No necesitamos manejar el resultado aquí, porque el "guardia"
                // en main.dart detectará el cambio y nos llevará a la MainScreen.
                await authService.signInWithGoogle();
              },
            ),
          ],
        ),
      ),
    );
  }
}
