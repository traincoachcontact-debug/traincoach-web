// lib/screens/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// --- Importaciones de Firebase ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conversation_preview.dart';
import 'chat_screen.dart'; // La pantalla de chat individual

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Ya no necesitamos la lista local ni el booleano _isLoading,
  // el StreamBuilder se encargará de gestionar el estado.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tu función para formatear la fecha está perfecta, la mantenemos.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(timestamp); // HH:mm (ej. 14:30)
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return DateFormat.MMMd('es_ES').format(timestamp); // Mes y día en español
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Si no hay usuario, mostramos un mensaje para que inicie sesión.
      return const Center(child: Text('Por favor, inicia sesión para ver tus mensajes.'));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // 1. Creamos un Stream que escucha la colección 'chats'
        //    donde el usuario actual sea un participante.
        // 2. Ordenamos por el último mensaje para mostrar los más recientes primero.
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            // Nota: puede que necesites crear un índice compuesto en Firestore para esta consulta.
            // La consola de Firebase te dará un link para crearlo si es necesario.
            .orderBy('lastMessage.timestamp', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          // Mientras carga, muestra un indicador de progreso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Si hay un error
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las conversaciones.'));
          }
          // Si no hay datos (ninguna conversación)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes conversaciones aún.'));
          }

          // Si tenemos datos, construimos la lista
          final chatDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              
              // --- Lógica para obtener los datos del OTRO usuario ---
              final List<dynamic> participants = chatData['participants'];
              final String otherUserId = participants.firstWhere((id) => id != currentUser.uid, orElse: () => '');
              
              // Usamos un FutureBuilder para cargar los datos del otro usuario de forma asíncrona
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    // Puedes mostrar un placeholder mientras carga el nombre del usuario
                    return const ListTile(
                      leading: CircleAvatar(radius: 25, backgroundColor: Colors.grey),
                      title: Text('Cargando...'),
                    );
                  }

                  final otherUserData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final lastMessageData = chatData['lastMessage'] as Map<String, dynamic>? ?? {};

                  // Construimos el modelo de la conversación con datos reales
                  final convo = ConversationPreview(
                    chatId: chatDocs[index].id,
                    otherUserId: otherUserId,
                    otherUserName: otherUserData['displayName'] ?? 'Usuario',
                    otherUserAvatarUrl: otherUserData['photoURL'] ?? '',
                    lastMessage: lastMessageData['text'] ?? '',
                    lastMessageTimestamp: (lastMessageData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    // La lógica de 'unreadCount' necesitaría ser implementada
                    unreadCount: 0, 
                  );

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: convo.otherUserAvatarUrl.isNotEmpty 
                              ? NetworkImage(convo.otherUserAvatarUrl) 
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: (convo.otherUserAvatarUrl.isEmpty && convo.otherUserName.isNotEmpty)
                              ? Text(convo.otherUserName[0])
                              : null,
                        ),
                        title: Text(convo.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          convo.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatTimestamp(convo.lastMessageTimestamp), style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            if (convo.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  convo.unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              )
                            else
                              const SizedBox(height: 18) // Espacio para alinear
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: convo.chatId,
                                otherUserName: convo.otherUserName,
                                otherUserAvatarUrl: convo.otherUserAvatarUrl,
                                // --- CORRECCIÓN AQUÍ ---
                                // Añadimos el parámetro que faltaba
                                otherUserId: convo.otherUserId, 
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 80, endIndent: 16),
                    ],
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
