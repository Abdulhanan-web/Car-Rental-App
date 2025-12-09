import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth changes (Logged In vs Logged Out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SIGN UP (Create Auth user + Save data to Firestore)
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create User in Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 2. Save supplementary data to Cloud Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw 'Database write timed out. Check your Firestore setup.';
          },
        );
      }
      return null; // Success

    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN (Sign in existing user)
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}