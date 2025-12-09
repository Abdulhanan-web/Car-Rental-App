import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../auth/welcome_page.dart';
import '../main_navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Start listening to the auth state immediately
    _checkAuthState();
  }

  void _checkAuthState() {
    // This listener automatically determines if a user is currently logged in
    AuthService().authStateChanges.listen((User? user) {
      if (user == null) {
        // User is NOT logged in: redirect to Welcome
        _navigateTo(WelcomePage());
      } else {
        // User IS logged in: redirect to Main App
        _navigateTo(MainNavigation());
      }
    });
  }

  void _navigateTo(Widget page) {
    // We use pushReplacement to prevent the user from navigating back to the splash screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => page),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Loading App..."),
          ],
        ),
      ),
    );
  }
}