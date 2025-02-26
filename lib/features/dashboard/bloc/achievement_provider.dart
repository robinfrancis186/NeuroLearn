import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String type; // 'bronze', 'silver', 'gold'
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_login',
      title: 'First Steps',
      description: 'Login to the app for the first time',
      type: 'bronze',
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Achievement(
      id: 'complete_profile',
      title: 'Identity Established',
      description: 'Complete your profile information',
      type: 'bronze',
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Achievement(
      id: 'first_lesson',
      title: 'Learning Pioneer',
      description: 'Complete your first lesson',
      type: 'silver',
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Achievement(
      id: 'streak_7',
      title: 'Consistency is Key',
      description: 'Maintain a 7-day learning streak',
      type: 'gold',
      isUnlocked: false,
    ),
  ];

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => _achievements.where((a) => !a.isUnlocked).toList();

  void unlockAchievement(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = Achievement(
        id: _achievements[index].id,
        title: _achievements[index].title,
        description: _achievements[index].description,
        type: _achievements[index].type,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  bool isAchievementUnlocked(String achievementId) {
    return _achievements.any((a) => a.id == achievementId && a.isUnlocked);
  }

  Achievement? getAchievement(String achievementId) {
    try {
      return _achievements.firstWhere((a) => a.id == achievementId);
    } catch (e) {
      return null;
    }
  }
} 