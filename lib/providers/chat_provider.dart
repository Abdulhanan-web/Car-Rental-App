// ============= lib/providers/chat_provider.dart =============
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../database/db_helper.dart';

class ChatProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Chat> _chats = [];

  ChatProvider() {
    _loadChats();
  }

  List<Chat> get chats => _chats;

  Future<void> _loadChats() async {
    final chatMaps = await _dbHelper.getChats();
    List<Chat> loadedChats = [];
    for (var map in chatMaps) {
      final messageMaps = await _dbHelper.getMessages(map['id']);
      final messages = messageMaps.map((m) => ChatMessage.fromMap(m)).toList();
      loadedChats.add(Chat.fromMap(map, messages));
    }
    _chats = loadedChats;
    
    if (_chats.isEmpty) {
      await _addDummyChats();
    }
    notifyListeners();
  }

  Future<void> _addDummyChats() async {
    final dummyChat1 = Chat(
      id: '1',
      userName: 'Alice',
      messages: [
        ChatMessage(text: 'Hello!', isMe: false, time: DateTime.now().subtract(const Duration(hours: 1))),
        ChatMessage(text: 'Is the car still available?', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 30))),
      ],
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    );
    
    final dummyChat2 = Chat(
      id: '2',
      userName: 'Bob',
      messages: [
        ChatMessage(text: 'Thanks for the info!', isMe: false, time: DateTime.now().subtract(const Duration(hours: 2))),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    );

    await _dbHelper.insertChat(dummyChat1.toMap());
    for (var msg in dummyChat1.messages) {
      await _dbHelper.insertMessage(msg.toMap(dummyChat1.id));
    }

    await _dbHelper.insertChat(dummyChat2.toMap());
    for (var msg in dummyChat2.messages) {
      await _dbHelper.insertMessage(msg.toMap(dummyChat2.id));
    }

    await _loadChats();
  }

  Future<void> sendMessage(String chatId, String text) async {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final newMessage = ChatMessage(text: text, isMe: true, time: DateTime.now());
      await _dbHelper.insertMessage(newMessage.toMap(chatId));
      
      // Update chat timestamp in DB
      _chats[index].messages.add(newMessage);
      final updatedChat = Chat(
        id: _chats[index].id,
        userName: _chats[index].userName,
        messages: _chats[index].messages,
        timestamp: DateTime.now(),
      );
      await _dbHelper.insertChat(updatedChat.toMap());
      
      _chats[index] = updatedChat;
      notifyListeners();
    }
  }
}
