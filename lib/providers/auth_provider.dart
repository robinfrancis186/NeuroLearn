import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String currentSubject;
  final String avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.currentSubject = 'Math',
    this.avatarUrl = '',
  });
}

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  User? get currentUser => _currentUser;

  AuthProvider() {
    // Auto-login for demo purposes
    login("Demo User", "password");
  }

  Future<void> login(String username, String password) async {
    // TODO: Implement actual authentication logic
    _isAuthenticated = true;
    _userId = "user_123";
    _userName = username;
    
    // Create a mock user for demo purposes
    _currentUser = User(
      id: _userId!,
      name: _userName!,
      email: 'demo@example.com',
      currentSubject: 'Math',
    );
    
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _currentUser = null;
    notifyListeners();
  }
  
  void updateCurrentSubject(String subject) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        currentSubject: subject,
        avatarUrl: _currentUser!.avatarUrl,
      );
      notifyListeners();
    }
  }
} 