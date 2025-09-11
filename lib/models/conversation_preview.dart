// lib/models/conversation_preview.dart
class ConversationPreview {
  final String chatId; // ID único de la conversación/chat
  final String otherUserId; // ID del otro usuario
  final String otherUserName; // Nombre del otro usuario
  final String otherUserAvatarUrl; // URL del avatar del otro usuario
  final String lastMessage; // Texto del último mensaje
  final DateTime lastMessageTimestamp; // Hora del último mensaje
  final int unreadCount; // Número de mensajes no leídos (opcional)

  ConversationPreview({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
  });
}