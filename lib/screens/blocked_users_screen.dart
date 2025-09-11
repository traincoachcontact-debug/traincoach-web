// lib/screens/blocked_users_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
// --- Importaciones de Firebase ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/blocked_user_model.dart'; // Importa tu modelo

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // Ya no necesitamos la lista local ni el isLoading,
  // el StreamBuilder y FutureBuilder manejarán el estado.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// --- Lógica de Firebase para desbloquear a un usuario ---
  Future<void> _unblockUser(String userId, String userName) async {
    // Mantenemos tu excelente diálogo de confirmación
    bool? confirmUnblock = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Desbloquear Usuario'),
          content: Text('¿Estás seguro de que deseas desbloquear a $userName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Desbloquear', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmUnblock == true) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      try {
        // Usamos FieldValue.arrayRemove para quitar el ID del array de bloqueados
        await _firestore.collection('users').doc(currentUser.uid).update({
          'blockedUsers': FieldValue.arrayRemove([userId])
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$userName ha sido desbloqueado.'), backgroundColor: Colors.green),
          );
        }
        // No es necesario un setState, el StreamBuilder reconstruirá la UI automáticamente.
      } catch (e) {
        print("Error al desbloquear usuario: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al desbloquear a $userName.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Scaffold(appBar: AppBar(title: const Text('Usuarios Bloqueados')), body: const Center(child: Text("Inicia sesión para ver esta sección.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Bloqueados'),
      ),
      // 1. Usamos un StreamBuilder para escuchar los cambios en NUESTRO perfil
      //    (específicamente, cuando la lista 'blockedUsers' cambia).
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('No se pudo cargar tu perfil.'));
          }

          // Obtenemos la lista de IDs de usuarios bloqueados
          final List<dynamic> blockedUserIds = (userSnapshot.data!.data() as Map<String, dynamic>)['blockedUsers'] ?? [];

          if (blockedUserIds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No tienes usuarios bloqueados en este momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          // 2. Usamos un FutureBuilder para cargar los perfiles de CADA ID bloqueado.
          return FutureBuilder<List<QueryDocumentSnapshot>>(
            // Usamos una consulta 'whereIn' para obtener todos los documentos de una vez
            future: _firestore.collection('users').where(FieldPath.documentId, whereIn: blockedUserIds).get().then((snapshot) => snapshot.docs),
            builder: (context, blockedUsersSnapshot) {
              if (blockedUsersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (blockedUsersSnapshot.hasError || !blockedUsersSnapshot.hasData) {
                return const Center(child: Text('Error al cargar la lista de usuarios.'));
              }

              final blockedUsersDocs = blockedUsersSnapshot.data!;

              return ListView.separated(
                itemCount: blockedUsersDocs.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final userData = blockedUsersDocs[index].data() as Map<String, dynamic>;
                  // Creamos el modelo con los datos reales
                  final user = BlockedUser(
                    id: blockedUsersDocs[index].id,
                    name: userData['displayName'] ?? 'Usuario sin nombre',
                    avatarUrl: userData['photoURL'],
                  );
                  
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                          ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                          : null,
                    ),
                    title: Text(user.name),
                    trailing: TextButton(
                      child: Text(
                        'Desbloquear',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                      onPressed: () => _unblockUser(user.id, user.name),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

