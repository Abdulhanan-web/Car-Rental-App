// lib/screens/chat/chat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../services/firestore_service.dart';
import '../../models/chat_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatDetailPage({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      setState(() {
        _currentUserName = profile?.name ?? 'User';
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _chatService.markMessagesAsRead(widget.chatId, user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[200],
              child: Text(
                widget.otherUserName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.otherUserName),
          ],
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(currentUser),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: currentUser == null
                  ? null
                  : () => _sendMessage(currentUser),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(User currentUser) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: currentUser.uid,
        senderName: _currentUserName,
        message: message,
      );

      _messageController.clear();

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}