import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("My Profile")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("User Details Here", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 50),

            // Logout Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              onPressed: () {
                // Call the service to sign out
                AuthService().signOut();
                // The SplashScreen listener handles the redirection to WelcomePage
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}