// ============= lib/pages/chats_page.dart =============
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chats = context.watch<ChatProvider>().chats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rental', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A3D8A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Chats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: chats.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailPage(chatId: chat.id),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1A3D8A),
                          child: Text(chat.userName[0], style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(chat.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${chat.timestamp.hour}:${chat.timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
}
