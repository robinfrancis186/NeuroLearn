import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'NeuroLearn';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.neurolearn.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Cache Configuration
  static const Duration cacheDuration = Duration(days: 7);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Performance Configuration
  static const int frameUpdateThreshold = 16; // milliseconds
  static const int maxConcurrentOperations = 3;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Feature Flags
  static const bool enableVoiceCloning = true;
  static const bool enableCollaboration = true;
  static const bool enablePerformanceMetrics = true;
  
  // Theme Configuration
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
  
  // Learning Configuration
  static const int maxAttemptsPerQuestion = 3;
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxCollaborativeParticipants = 5;
  
  // Dashboard Configuration
  static const int maxRecentActivities = 10;
  static const Duration activityRefreshInterval = Duration(minutes: 5);
  
  // Device Support
  static const Set<TargetPlatform> supportedPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
  };
} 