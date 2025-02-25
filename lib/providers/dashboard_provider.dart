import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentActivity {
  final String title;
  final String type;
  final DateTime timestamp;
  final double score;
  final IconData icon;

  StudentActivity({
    required this.title,
    required this.type,
    required this.timestamp,
    required this.score,
    required this.icon,
  });
}

class ScheduledActivity {
  final String title;
  final DateTime scheduledTime;
  final String subject;
  final String description;

  ScheduledActivity({
    required this.title,
    required this.scheduledTime,
    required this.subject,
    required this.description,
  });
}

class AssignedTask {
  final String title;
  final DateTime dueDate;
  final String status;
  final String subject;
  final String description;

  AssignedTask({
    required this.title,
    required this.dueDate,
    required this.status,
    required this.subject,
    required this.description,
  });
}

class DashboardProvider with ChangeNotifier {
  List<StudentActivity> _recentActivities = [];
  List<ScheduledActivity> _upcomingActivities = [];
  List<AssignedTask> _assignedTasks = [];
  Map<String, double> _subjectProgress = {};
  Map<String, double> _skillsProgress = {};

  List<StudentActivity> get recentActivities => _recentActivities;
  List<ScheduledActivity> get upcomingActivities => _upcomingActivities;
  List<AssignedTask> get assignedTasks => _assignedTasks;
  Map<String, double> get subjectProgress => _subjectProgress;
  Map<String, double> get skillsProgress => _skillsProgress;

  DashboardProvider() {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Load data from backend/local storage
    // For now, using mock data
    _initializeMockData();
    notifyListeners();
  }

  void _initializeMockData() {
    // Initialize subject progress
    _subjectProgress = {
      'Math': 0.7,
      'Language': 0.6,
      'Memory': 0.8,
      'Life Skills': 0.5,
    };

    // Initialize skills progress
    _skillsProgress = {
      'Problem Solving': 0.8,
      'Communication': 0.7,
      'Memory': 0.6,
      'Focus': 0.75,
    };

    // Initialize recent activities
    _recentActivities = [
      StudentActivity(
        title: 'Completed Math Quiz',
        type: 'quiz',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        score: 0.9,
        icon: Icons.calculate,
      ),
      StudentActivity(
        title: 'Language Practice',
        type: 'practice',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        score: 0.85,
        icon: Icons.language,
      ),
      // Add more activities...
    ];

    // Initialize upcoming activities
    _upcomingActivities = [
      ScheduledActivity(
        title: 'Math Practice',
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
        subject: 'Math',
        description: 'Practice multiplication tables',
      ),
      ScheduledActivity(
        title: 'Language Session',
        scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        subject: 'Language',
        description: 'Vocabulary building exercise',
      ),
      // Add more activities...
    ];

    // Initialize assigned tasks
    _assignedTasks = [
      AssignedTask(
        title: 'Complete Math Worksheet',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'In Progress',
        subject: 'Math',
        description: 'Practice addition and subtraction',
      ),
      AssignedTask(
        title: 'Read Story Book',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: 'Not Started',
        subject: 'Language',
        description: 'Read chapter 1 and answer questions',
      ),
      // Add more tasks...
    ];
  }

  Future<void> scheduleActivity(ScheduledActivity activity) async {
    _upcomingActivities.add(activity);
    // TODO: Save to backend/local storage
    notifyListeners();
  }

  Future<void> assignTask(AssignedTask task) async {
    _assignedTasks.add(task);
    // TODO: Save to backend/local storage
    notifyListeners();
  }

  Future<void> updateTaskStatus(String taskTitle, String newStatus) async {
    final taskIndex = _assignedTasks.indexWhere((task) => task.title == taskTitle);
    if (taskIndex != -1) {
      final task = _assignedTasks[taskIndex];
      _assignedTasks[taskIndex] = AssignedTask(
        title: task.title,
        dueDate: task.dueDate,
        status: newStatus,
        subject: task.subject,
        description: task.description,
      );
      // TODO: Save to backend/local storage
      notifyListeners();
    }
  }

  Future<void> updateSubjectProgress(String subject, double progress) async {
    _subjectProgress[subject] = progress;
    // TODO: Save to backend/local storage
    notifyListeners();
  }

  Future<void> updateSkillProgress(String skill, double progress) async {
    _skillsProgress[skill] = progress;
    // TODO: Save to backend/local storage
    notifyListeners();
  }

  Future<void> addActivity(StudentActivity activity) async {
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 10) {
      _recentActivities.removeLast();
    }
    // TODO: Save to backend/local storage
    notifyListeners();
  }

  Future<void> generateReport(String type) async {
    // TODO: Implement report generation logic
    // This would typically involve:
    // 1. Gathering data based on the report type (daily/weekly/monthly)
    // 2. Processing the data into a suitable format
    // 3. Generating a PDF or other report format
    // 4. Saving or sharing the report
  }
} 