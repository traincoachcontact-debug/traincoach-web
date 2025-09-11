// lib/screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
// --- Importaciones de Firebase ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId; 
  final String otherUserName;
  final String otherUserAvatarUrl;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.otherUserId, 
    required this.otherUserName,
    required this.otherUserAvatarUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// --- Lógica de Firebase para enviar mensajes (CORREGIDA) ---
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return; 

    setState(() => _isSending = true);
    _controller.clear();
    

    try {
      // 1. Preparamos el documento principal del chat.
      final chatDocRef = _firestore.collection('chats').doc(widget.chatId);

      // 2. Preparamos la información del mensaje y del 'lastMessage'.
      final messageData = {
        'text': text,
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final chatData = {
        'participants': [currentUser.uid, widget.otherUserId],
        'lastMessage': messageData,
      };

      // 3. --- CORRECCIÓN CLAVE ---
      // Usamos .set() con merge:true en un batch para asegurar que todo sea atómico.
      // Esto crea el chat si no existe, o lo actualiza si ya existe.
      WriteBatch batch = _firestore.batch();
      
      batch.set(chatDocRef, chatData, SetOptions(merge: true));
      batch.set(chatDocRef.collection('messages').doc(), messageData);

      await batch.commit();

      _scrollToBottom();

    } catch (e) {
      print("Error al enviar mensaje: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el mensaje.')),
        );
      }
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }
  
  // Tu lógica para bloquear usuarios se mantiene igual...
  Future<void> _blockUser() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear Usuario'),
        content: Text('¿Estás seguro de que quieres bloquear a ${widget.otherUserName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Bloquear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'blockedUsers': FieldValue.arrayUnion([widget.otherUserId])
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.otherUserName} ha sido bloqueado.'), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo bloquear al usuario.')));
        }
      }
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Tu UI se mantiene igual
  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Error: Usuario no autenticado.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: const Icon(Icons.block),
            tooltip: 'Bloquear Usuario',
            onPressed: _blockUser,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Envía un mensaje para empezar."));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                final messagesDocs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messagesDocs.length,
                  itemBuilder: (context, index) {
                    final messageData = messagesDocs[index].data() as Map<String, dynamic>;
                    final message = ChatMessage(
                      id: messagesDocs[index].id,
                      text: messageData['text'] ?? '',
                      timestamp: (messageData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                      senderId: messageData['senderId'] ?? '',
                      isUserMessage: messageData['senderId'] == currentUser.uid,
                    );
                    return _buildMessageBubble(message, message.isUserMessage);
                  },
                );
              },
            ),
          ),
          _buildTextInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Row(
      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isCurrentUser ? Theme.of(context).primaryColor : Colors.grey[700],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 8.0, bottom: MediaQuery.of(context).padding.bottom + 8.0, top: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, -2))]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Escribe tu mensaje...', border: InputBorder.none, filled: false),
              onSubmitted: _isSending ? null : _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _isSending ? null : () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
