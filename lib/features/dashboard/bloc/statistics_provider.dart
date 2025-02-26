import 'package:flutter/material.dart';

class StatisticsProvider extends ChangeNotifier {
  int _level = 5;
  int _streak = 12;
  int _points = 850;
  List<double> _weeklyProgress = [3.0, 2.0, 5.0, 3.1, 4.0, 3.0, 4.0];
  Map<String, double> _subjectProgress = {
    'Math': 0.75,
    'Language': 0.60,
    'Memory': 0.45,
    'Life Skills': 0.30,
  };

  // Getters
  int get level => _level;
  int get streak => _streak;
  int get points => _points;
  List<double> get weeklyProgress => List.unmodifiable(_weeklyProgress);
  Map<String, double> get subjectProgress => Map.unmodifiable(_subjectProgress);

  // Methods to update statistics
  void incrementLevel() {
    _level++;
    notifyListeners();
  }

  void incrementStreak() {
    _streak++;
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    notifyListeners();
  }

  void addPoints(int amount) {
    _points += amount;
    if (_points >= 1000) {
      _points -= 1000;
      incrementLevel();
    }
    notifyListeners();
  }

  void updateProgress(String subject, double progress) {
    if (_subjectProgress.containsKey(subject)) {
      _subjectProgress[subject] = progress;
      notifyListeners();
    }
  }

  void updateWeeklyProgress(List<double> progress) {
    if (progress.length == 7) {
      _weeklyProgress = List.from(progress);
      notifyListeners();
    }
  }
} 