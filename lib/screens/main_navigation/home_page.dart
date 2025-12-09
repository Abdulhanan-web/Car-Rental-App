import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Home")
      ),
      body: const Center(
        child: Text("Welcome to the main car listing feed!", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}