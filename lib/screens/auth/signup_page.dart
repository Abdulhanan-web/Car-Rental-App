//signup_page.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Dispose controllers to free up memory
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void attemptSignup() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? error = await AuthService().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      // Success: User is now logged in. The SplashScreen listener takes over navigation.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup Failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email"), keyboardType: TextInputType.emailAddress),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),

            const SizedBox(height: 40),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: attemptSignup,
              child: const Text("Sign Up"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}