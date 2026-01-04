// ============= lib/providers/auth_provider.dart =============
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  bool get isAuthenticated => _user != null;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _user = User(id: '1', name: 'Abdul Hanan', email: email);
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _user = User(id: '1', name: name, email: email);
    notifyListeners();
  }

  void updateProfile(String name, String email, String phone) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: name,
        email: email,
        phone: phone,
        memberSince: _user!.memberSince,
      );
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
