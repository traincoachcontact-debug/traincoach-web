// lib/models/chat_message.dart
class ChatMessage {
  final String id; // Identificador único del mensaje
  final String text; // Contenido del mensaje
  final DateTime timestamp; // Hora de envío
  final String senderId; // Quién envió ('user', 'assistant', o ID de usuario real)
  final bool isUserMessage; // Conveniencia para saber si es del usuario actual

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.senderId,
    required this.isUserMessage,
  });
}