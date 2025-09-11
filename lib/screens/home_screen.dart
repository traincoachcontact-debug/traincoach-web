// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Importa las pantallas a las que podrías navegar
import 'chat_screen.dart';
import 'profile_screen.dart'; // Para navegar al perfil de un visitante

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Ya no necesitamos ninguna lista o variable de estado simulada.

  // Función para iniciar un chat, ahora recibe el ID del otro usuario
  void _startChatWithUser(Map<String, dynamic> otherUserData, String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    List<String> ids = [currentUser.uid, otherUserId];
    ids.sort(); // Ordena los IDs para que el chatId sea siempre el mismo
    String chatId = ids.join('_');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          otherUserId: otherUserId,
          otherUserName: otherUserData['displayName'] ?? 'Usuario',
          otherUserAvatarUrl: otherUserData['photoURL'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un simple ListView, ya que los StreamBuilders internos manejarán sus propios estados de carga.
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSectionTitle(context, 'Descubre otros usuarios'),
        _buildUsersList(), // Widget que muestra a todos los usuarios
        _buildSectionTitle(context, 'Han visto tu perfil'),
        _buildProfileViewersList(), // Widget que muestra a los visitantes reales
      ],
    );
  }

  // Widget helper para los títulos de sección
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Widget CONECTADO A FIREBASE para mostrar usuarios ---
  Widget _buildUsersList() {
    final currentUser = _auth.currentUser;

    return Container(
      height: 160, // Aumentamos un poco la altura para el botón
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('uid', isNotEqualTo: currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay otros usuarios.'));
          }

          final userDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            scrollDirection: Axis.horizontal,
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final userData = userDocs[index].data() as Map<String, dynamic>;
              final String userId = userDocs[index].id;
              final String userName = userData['displayName'] ?? 'Usuario';
              final String? userAvatarUrl = userData['photoURL'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Container(
                  width: 120, // Un poco más ancho para el botón
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Al tocar la foto, vas al perfil del usuario
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId))),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: (userAvatarUrl != null && userAvatarUrl.isNotEmpty) ? NetworkImage(userAvatarUrl) : null,
                          child: (userAvatarUrl == null || userAvatarUrl.isEmpty) ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?') : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(userName, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      // --- BOTÓN DE CHAT AÑADIDO AQUÍ ---
                      SizedBox(
                        height: 30, // Contenedor para que el botón no ocupe mucho espacio
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor),
                          tooltip: 'Iniciar chat',
                          onPressed: () => _startChatWithUser(userData, userId),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Widget CONECTADO A FIREBASE para mostrar quién vio tu perfil ---
  Widget _buildProfileViewersList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const SizedBox.shrink(); // No mostrar nada si no hay usuario

    return StreamBuilder<QuerySnapshot>(
      // Escuchamos la subcolección 'profileViewers' del usuario actual
      stream: _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('profileViewers')
          .orderBy('timestamp', descending: true) // Los más recientes primero
          .limit(10) // Limitamos a los últimos 10 para no sobrecargar
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Nadie ha visto tu perfil recientemente.')));
        }

        final viewerDocs = snapshot.data!.docs;

        // Usamos un ListView.builder para construir la lista de visitantes
        return ListView.builder(
          shrinkWrap: true, // Importante para anidar dentro de otro ListView
          physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll de esta lista
          itemCount: viewerDocs.length,
          itemBuilder: (context, index) {
            final viewerData = viewerDocs[index].data() as Map<String, dynamic>;
            final String viewerId = viewerData['viewerId'];
            final Timestamp? timestamp = viewerData['timestamp'];

            // Por cada visitante, buscamos sus datos de perfil con un FutureBuilder
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(viewerId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Cargando visitante...'));
                }
                final viewerProfile = userSnapshot.data!.data() as Map<String, dynamic>;
                final String viewerName = viewerProfile['displayName'] ?? 'Usuario';
                final String? viewerAvatarUrl = viewerProfile['photoURL'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (viewerAvatarUrl != null && viewerAvatarUrl.isNotEmpty) ? NetworkImage(viewerAvatarUrl) : null,
                     child: (viewerAvatarUrl == null || viewerAvatarUrl.isEmpty) ? Text(viewerName.isNotEmpty ? viewerName[0].toUpperCase() : '?') : null,
                  ),
                  title: Text(viewerName),
                  subtitle: Text(timestamp != null ? _formatTimeAgo(timestamp.toDate()) : 'Hace un tiempo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navegar al perfil del visitante
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: viewerId)));
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Pequeña función para formatear el tiempo
  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }
}
