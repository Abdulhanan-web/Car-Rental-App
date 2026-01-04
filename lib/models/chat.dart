// ============= lib/models/chat.dart =============
class Chat {
  final String id;
  final String userName;
  final List<ChatMessage> messages;
  final DateTime timestamp;

  Chat({
    required this.id,
    required this.userName,
    required this.messages,
    required this.timestamp,
  });

  String get lastMessage => messages.isNotEmpty ? messages.last.text : '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map, List<ChatMessage> messages) {
    return Chat(
      id: map['id'],
      userName: map['userName'],
      messages: messages,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });

  Map<String, dynamic> toMap(String chatId) {
    return {
      'chatId': chatId,
      'text': text,
      'isMe': isMe ? 1 : 0,
      'time': time.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      isMe: map['isMe'] == 1,
      time: DateTime.parse(map['time']),
    );
  }
}
