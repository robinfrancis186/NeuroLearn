import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Soft and calming palette
  static const Color primary = Color(0xFF4CAF50);    // Soft green - calming and natural
  static const Color secondary = Color(0xFF03A9F4);   // Sky blue - fresh and focused
  static const Color tertiary = Color(0xFFFF8A65);    // Coral - warm and friendly
  static const Color accent = Color(0xFFFFA726);     // Orange - energetic and positive

  // Background Colors - Easy on the eyes
  static const Color background = Color(0xFFF5F7FA); // Light gray-blue - gentle on eyes
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEF2F6); // Slightly darker surface
  static const Color lightBg = Color(0xFFE8F5E9);    // Light green background

  // Text Colors - High contrast for readability
  static const Color textPrimary = Color(0xFF2D3748);   // Dark gray - readable
  static const Color textSecondary = Color(0xFF4A5568); // Medium gray
  static const Color textTertiary = Color(0xFF718096);  // Light gray
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF2D3748);
  static const Color onSurface = Color(0xFF2D3748);

  // Semantic Colors - Gentle feedback colors
  static const Color success = Color(0xFF66BB6A);    // Soft green - achievement
  static const Color error = Color(0xFFEF5350);      // Soft red - gentle error
  static const Color warning = Color(0xFFFFB74D);    // Soft orange - attention
  static const Color info = Color(0xFF64B5F6);       // Soft blue - information

  // Subject Colors - Carefully chosen for distinction and meaning
  static const Map<String, Color> subjectColors = {
    'Math': Color(0xFF03A9F4),        // Sky blue - logic and numbers
    'Language': Color(0xFF4CAF50),    // Green - communication
    'Memory': Color(0xFF009688),      // Teal - concentration
    'Life Skills': Color(0xFF66BB6A), // Light green - growth and practical skills
    'Arts': Color(0xFFFF8A65),        // Coral - creativity
    'Music': Color(0xFF26A69A),       // Teal-green - expression
    'Social': Color(0xFF42A5F5),      // Light blue - interaction
  };

  // Progress and Achievement Colors - Motivating colors
  static const Color progressBackground = Color(0xFFE8F5E9);
  static const Color progressForeground = Color(0xFF4CAF50);
  static const Color bronze = Color(0xFFD7A07C);
  static const Color silver = Color(0xFFB8C4D4);
  static const Color gold = Color(0xFFFFD700);

  // Gradients - Smooth transitions
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF03A9F4),
    Color(0xFF4FC3F7),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFFA726),
    Color(0xFFFFB74D),
  ];

  // Misc
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x1A000000);
} 