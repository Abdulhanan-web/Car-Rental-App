// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get or create chat between two users
  Future<String> getOrCreateChat(
      String currentUserId,
      String otherUserId,
      String otherUserName,
      ) async {
    try {
      // Check if chat already exists
      final existingChats = await _db
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChats.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new chat
      final chatId = DateTime.now().millisecondsSinceEpoch.toString();
      await _db.collection('chats').doc(chatId).set({
        'id': chatId,
        'participants': [currentUserId, otherUserId],
        'lastMessage': 'Chat started',
        'lastMessageSenderId': currentUserId,
        'lastMessageTime': DateTime.now().toIso8601String(),
        'unreadCount': 0,
        'otherUserName': otherUserName,
      });

      return chatId;
    } catch (e) {
      throw Exception('Error creating chat: $e');
    }
  }

  // Get user's chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromJson(doc.data()))
        .toList());
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final timestamp = DateTime.now();

      // Add message to messages subcollection
      await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': false,
      });

      // Update chat's last message
      await _db.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageSenderId': senderId,
        'lastMessageTime': timestamp.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromJson(doc.data()))
        .toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messages = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Reset unread count
      await _db.collection('chats').doc(chatId).update({'unreadCount': 0});
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}