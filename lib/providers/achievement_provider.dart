import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final int stars;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.stars,
  });
}

class AchievementProvider extends ChangeNotifier {
  final int _totalAchievements = 20;
  final double _overallProgress = 0.8;
  
  final List<Achievement> _achievements = [
    Achievement(
      title: 'Studious',
      description: 'You have completed this lesson 10 times.',
      icon: Icons.school,
      progress: 0.8,
      stars: 3,
    ),
    Achievement(
      title: 'Quickie',
      description: 'You have completed this quiz in less than 3 minutes, 10 times.',
      icon: Icons.timer,
      progress: 0.6,
      stars: 2,
    ),
    Achievement(
      title: 'Ambitious',
      description: 'You have achieved 15 milestones.',
      icon: Icons.emoji_events,
      progress: 0.9,
      stars: 3,
    ),
  ];

  List<Achievement> get achievements => _achievements;
  int get totalAchievements => _totalAchievements;
  double get overallProgress => _overallProgress;
  int get completedAchievements => _achievements.where((a) => a.progress >= 1.0).length;
  int get inProgressAchievements => _achievements.where((a) => a.progress < 1.0).length;
} 