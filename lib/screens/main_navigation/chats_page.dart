// lib/screens/main_navigation/chats_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../models/chat_model.dart';
import '../chat/chat_detail_page.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: const Center(
          child: Text('Please login to view your chats'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 2,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getUserChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with car owners',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return _buildChatItem(chats[index], user.uid);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat, String currentUserId) {
    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
    final isUnread = chat.lastMessageSenderId != currentUserId &&
        chat.unreadCount > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatId: chat.id,
              otherUserId: otherUserId,
              otherUserName: chat.otherUserName ?? 'User',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
          color: isUnread ? Colors.blue[50] : Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue[200],
              child: Text(
                chat.otherUserName?[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.otherUserName ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread ? Colors.blue : Colors.grey[600],
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount > 9 ? '9+' : '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}