// lib/screens/settings_screen.dart
import 'dart:async';
import 'package:traincoach/screens/blocked_users_screen.dart';
import 'package:flutter/material.dart';

// Importa las pantallas necesarias
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estado local para los switches de notificación
  bool _allowAllNotifications = true;
  bool _allowMessageNotifications = true;
  bool _allowProfileViewNotifications = false;

  @override
  void initState() {
    super.initState();
    // Aquí cargarías los ajustes guardados del usuario
  }

  // Lógica de Logout (Simulada)
  Future<void> _logoutUser() async {
    // ... tu lógica de logout ...
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  // Muestra el diálogo de confirmación para cerrar sesión
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _logoutUser();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: <Widget>[
          // --- Sección Cuenta/Seguridad ---
          _buildSectionHeader('Cuenta y Seguridad'),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Usuarios Bloqueados'),
            subtitle: const Text('Gestiona los usuarios que has bloqueado'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navegación limpia
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlockedUsersScreen()),
              );
            },
          ),
          const Divider(),

          // --- Sección Notificaciones ---
          _buildSectionHeader('Notificaciones'),
          SwitchListTile(
            title: const Text('Permitir Notificaciones'),
            subtitle: const Text('Recibir alertas y actualizaciones'),
            secondary: const Icon(Icons.notifications_active),
            value: _allowAllNotifications,
            onChanged: (bool value) {
              setState(() {
                _allowAllNotifications = value;
                if (!value) {
                  _allowMessageNotifications = false;
                  _allowProfileViewNotifications = false;
                }
              });
              // _saveNotificationSetting('allow_all_notifications', value);
            },
          ),
          SwitchListTile(
            title: const Text('Notificaciones de Mensajes'),
            subtitle: const Text('Recibir alertas de nuevos mensajes'),
            secondary: const Icon(Icons.message),
            value: _allowMessageNotifications,
            onChanged: _allowAllNotifications
                ? (bool value) => setState(() => _allowMessageNotifications = value)
                : null,
          ),
          SwitchListTile(
            title: const Text('Notificaciones de Visitas al Perfil'),
            subtitle: const Text('Saber quién ha visto tu perfil'),
            secondary: const Icon(Icons.visibility),
            value: _allowProfileViewNotifications,
            onChanged: _allowAllNotifications
                ? (bool value) => setState(() => _allowProfileViewNotifications = value)
                : null,
          ),
          const Divider(),

          // --- NUEVA SECCIÓN LEGAL Y ACERCA DE ---
          _buildSectionHeader('Legal y Acerca de'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
              );
            },
          ),
          const Divider(),
          
          // --- Sección Salir ---
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _showLogoutConfirmationDialog,
          ),
        ],
      ),
    );
  }

  // Helper para crear cabeceras de sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
