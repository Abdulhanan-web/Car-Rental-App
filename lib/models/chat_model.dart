// lib/models/chat_model.dart

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? otherUserName;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.otherUserName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'unreadCount': unreadCount,
    'otherUserName': otherUserName,
  };

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    id: json['id'],
    participants: List<String>.from(json['participants']),
    lastMessage: json['lastMessage'],
    lastMessageSenderId: json['lastMessageSenderId'],
    lastMessageTime: DateTime.parse(json['lastMessageTime']),
    unreadCount: json['unreadCount'] ?? 0,
    otherUserName: json['otherUserName'],
  );
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    chatId: json['chatId'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
  );
}