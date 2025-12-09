import 'package:flutter/material.dart';
class MyAdsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("My Listings")
      ),
      body: const Center(child: Text("Your posted ads go here.")),
    );
  }
}