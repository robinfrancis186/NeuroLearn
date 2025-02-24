import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int maxProgress;
  final int currentProgress;
  final int stars;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.maxProgress,
    required this.currentProgress,
    required this.stars,
  });

  double get progressPercentage => currentProgress / maxProgress;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'maxProgress': maxProgress,
    'currentProgress': currentProgress,
    'stars': stars,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    maxProgress: json['maxProgress'],
    currentProgress: json['currentProgress'],
    stars: json['stars'],
  );
}

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [];
  int _totalAchievements = 20;
  double _overallProgress = 0.8;

  List<Achievement> get achievements => _achievements;
  int get totalAchievements => _totalAchievements;
  double get overallProgress => _overallProgress;

  AchievementProvider() {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    // Initialize with default achievements
    _achievements = [
      Achievement(
        id: 'studious',
        title: 'Studious',
        description: 'You have completed this lesson 10 times.',
        maxProgress: 10,
        currentProgress: 10,
        stars: 3,
      ),
      Achievement(
        id: 'quickie',
        title: 'Quickie',
        description: 'You have completed this quiz in less than 3 minutes, 10 times.',
        maxProgress: 10,
        currentProgress: 8,
        stars: 3,
      ),
      Achievement(
        id: 'ambitious',
        title: 'Ambitious',
        description: 'You have achieved 15 milestones.',
        maxProgress: 15,
        currentProgress: 12,
        stars: 3,
      ),
      Achievement(
        id: 'perfectionist',
        title: 'Perfectionist',
        description: 'You have scored 100% on quizzes 20 times.',
        maxProgress: 20,
        currentProgress: 15,
        stars: 3,
      ),
    ];

    // Load saved progress from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    for (var achievement in _achievements) {
      final progress = prefs.getInt('achievement_${achievement.id}_progress');
      if (progress != null) {
        achievement = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          maxProgress: achievement.maxProgress,
          currentProgress: progress,
          stars: achievement.stars,
        );
      }
    }
    notifyListeners();
  }

  Future<void> updateProgress(String achievementId, int progress) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      final achievement = _achievements[index];
      final newProgress = achievement.currentProgress + progress;
      
      if (newProgress <= achievement.maxProgress) {
        _achievements[index] = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          maxProgress: achievement.maxProgress,
          currentProgress: newProgress,
          stars: achievement.stars,
        );

        // Save progress
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('achievement_${achievement.id}_progress', newProgress);
        
        notifyListeners();
      }
    }
  }
} 