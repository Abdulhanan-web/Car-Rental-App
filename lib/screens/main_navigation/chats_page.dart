import 'package:flutter/material.dart';
class ChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Chats")
      ),
      body: const Center(child: Text("Messages will appear here.")),
    );
  }
}