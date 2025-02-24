import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;

  Future<void> login(String username, String password) async {
    // TODO: Implement actual authentication logic
    _isAuthenticated = true;
    _userId = "user_123";
    _userName = username;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    notifyListeners();
  }
} 