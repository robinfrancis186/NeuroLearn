import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _dailyReminders = true;
  bool _darkMode = false;
  String _language = 'English';
  final List<String> _availableLanguages = ['English', 'Spanish', 'French', 'Chinese'];

  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  bool get dailyReminders => _dailyReminders;
  bool get darkMode => _darkMode;
  String get language => _language;
  List<String> get availableLanguages => _availableLanguages;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _emailNotifications = prefs.getBool('emailNotifications') ?? true;
    _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    _dailyReminders = prefs.getBool('dailyReminders') ?? true;
    _darkMode = prefs.getBool('darkMode') ?? false;
    _language = prefs.getString('language') ?? 'English';
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailNotifications', value);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
    notifyListeners();
  }

  Future<void> setDailyReminders(bool value) async {
    _dailyReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminders', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }
} 