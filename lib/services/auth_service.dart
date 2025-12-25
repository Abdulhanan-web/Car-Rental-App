// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _db
          .collection('users')
          .doc(result.user!.uid)
          .set(userModel.toJson());

      await result.user!.updateDisplayName(name);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An error occurred during sign up.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'An error occurred during login.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'requires-recent-login':
          return 'Please log in again to update your password.';
        default:
          return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _db.collection('users').doc(user.uid).delete();
        await user.delete();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please log in again to delete your account.';
      }
      return e.message ?? 'An error occurred.';
    } catch (e) {
      return e.toString();
    }
  }
}