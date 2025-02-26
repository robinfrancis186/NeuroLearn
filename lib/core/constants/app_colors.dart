import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);

  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;

  // Subject colors
  static const Map<String, Color> subjectColors = {
    'Math': Color(0xFF1976D2),
    'Science': Color(0xFF388E3C),
    'History': Color(0xFFD32F2F),
    'Literature': Color(0xFF7B1FA2),
    'Languages': Color(0xFF1976D2),
    'Arts': Color(0xFFE64A19),
    'Music': Color(0xFF00796B),
    'Technology': Color(0xFF0097A7),
  };

  // Progress colors
  static const Color progressBackground = Color(0xFFE0E0E0);
  static const Color progressForeground = Color(0xFF4CAF50);

  // Achievement colors
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);

  // Misc
  static const Color divider = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x1F000000);
} 