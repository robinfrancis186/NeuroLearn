import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6D57FC);    // 01 - Main purple
  static const Color secondary = Color(0xFF261E58);   // 02 - Dark blue
  static const Color dark = Color(0xFF0C0A1C);       // 03 - Almost black
  static const Color lightBg = Color(0xFFE8E4FF);    // 04 - Light purple bg
  static const Color accent = Color(0xFFB0A4FD);     // 05 - Soft purple

  // Additional semantic colors derived from our palette
  static const Color textPrimary = dark;
  static const Color textSecondary = secondary;
  static const Color background = Colors.white;
  static const Color surface = lightBg;
  
  // Gradient combinations
  static const List<Color> primaryGradient = [
    primary,
    accent,
  ];
  
  static const List<Color> surfaceGradient = [
    lightBg,
    Colors.white,
  ];
} 