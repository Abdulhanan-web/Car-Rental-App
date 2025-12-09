import 'package:flutter/material.dart';
class AddCarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Post a Car")
      ),
      body: const Center(child: Text("Car posting form goes here.")),
    );
  }
}