import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
// You might need to import your splash or welcome screen to navigate there:
import '../splash/splash_screen.dart'; // <--- ASSUMED TARGET

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('User Profile Details Here'),
            const SizedBox(height: 30),

            // LOGOUT BUTTON IMPLEMENTATION
            ElevatedButton(
              onPressed: () async {
                // 1. Call the logout method
                await AuthService().logout();

                // 2. Navigate back to the very first screen (Splash/Welcome)
                // We use pushAndRemoveUntil to clear the entire navigation stack
                // (MainNavigation, Home, Profile, etc.) so the user can't hit back.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(), // <--- Navigate to your unauthenticated root
                  ),
                      (Route<dynamic> route) => false, // This ensures all previous routes are removed
                );
              },
              child: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Use a distinguishing color
                  minimumSize: const Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}