// lib/widgets/app_drawer.dart
import 'package:traincoach/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos la instancia del servicio de autenticación
    final AuthService authService = AuthService();
    // 2. Obtenemos al usuario actual de Firebase
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // 3. Extraemos los datos del usuario, con valores por defecto si son nulos
    final String userName = currentUser?.displayName ?? "Nombre de Usuario";
    final String userEmail = currentUser?.email ?? "email@ejemplo.com";
    final String? userProfileImageUrl = currentUser?.photoURL;

    return Drawer(
      child: Column(
        children: <Widget>[
          // Cabecera con los datos reales del usuario
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/profile');
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                // --- CORRECCIÓN CLAVE AQUÍ ---
                // Muestra la imagen de la red SOLO si la URL no es nula y no está vacía.
                backgroundImage: (userProfileImageUrl != null && userProfileImageUrl.isNotEmpty)
                    ? NetworkImage(userProfileImageUrl)
                    : null,
                // Si no hay imagen, muestra un icono por defecto para evitar el error.
                child: (userProfileImageUrl == null || userProfileImageUrl.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          // Spacer empuja los siguientes elementos hacia abajo
          const Spacer(),

          // Botón de Ajustes
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ajustes'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          
          // Botón de Cerrar Sesión Funcional
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Llama a la función signOut de nuestro servicio
              await authService.signOut();
              // El AuthWrapper en main.dart se encargará del resto
            },
          ),
          // Un pequeño padding inferior
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
