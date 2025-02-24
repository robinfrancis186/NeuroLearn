import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsProvider with ChangeNotifier {
  double _absence = 90;
  double _tasksAndExam = 70;
  double _quiz = 85;
  double _gradesCompleted = 75;
  String _period = 'January - June 2021';

  double get absence => _absence;
  double get tasksAndExam => _tasksAndExam;
  double get quiz => _quiz;
  double get gradesCompleted => _gradesCompleted;
  String get period => _period;

  StatisticsProvider() {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    _absence = prefs.getDouble('stats_absence') ?? 90;
    _tasksAndExam = prefs.getDouble('stats_tasks_exam') ?? 70;
    _quiz = prefs.getDouble('stats_quiz') ?? 85;
    _gradesCompleted = prefs.getDouble('stats_grades_completed') ?? 75;
    _period = prefs.getString('stats_period') ?? 'January - June 2021';
    notifyListeners();
  }

  Future<void> updateStatistics({
    double? absence,
    double? tasksAndExam,
    double? quiz,
    double? gradesCompleted,
    String? period,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (absence != null) {
      _absence = absence;
      await prefs.setDouble('stats_absence', absence);
    }
    if (tasksAndExam != null) {
      _tasksAndExam = tasksAndExam;
      await prefs.setDouble('stats_tasks_exam', tasksAndExam);
    }
    if (quiz != null) {
      _quiz = quiz;
      await prefs.setDouble('stats_quiz', quiz);
    }
    if (gradesCompleted != null) {
      _gradesCompleted = gradesCompleted;
      await prefs.setDouble('stats_grades_completed', gradesCompleted);
    }
    if (period != null) {
      _period = period;
      await prefs.setString('stats_period', period);
    }

    notifyListeners();
  }
} 