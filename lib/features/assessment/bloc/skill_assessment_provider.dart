import 'package:flutter/material.dart';

enum SkillLevel { beginner, intermediate, advanced, mastery }

class Skill {
  final String id;
  final String name;
  final String description;
  final SkillLevel level;
  double progress;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    this.progress = 0.0,
  });

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    SkillLevel? level,
    double? progress,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      progress: progress ?? this.progress,
    );
  }
}

class LearningPath {
  final String id;
  final String name;
  final String description;
  final List<Skill> skills;
  double progress;
  final DateTime createdAt;

  LearningPath({
    required this.id,
    required this.name,
    required this.description,
    required this.skills,
    required this.createdAt,
    this.progress = 0.0,
  });

  LearningPath copyWith({
    String? id,
    String? name,
    String? description,
    List<Skill>? skills,
    double? progress,
    DateTime? createdAt,
  }) {
    return LearningPath(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SkillAssessmentProvider extends ChangeNotifier {
  final List<Skill> _skills = [
    Skill(
      id: '1',
      name: 'Basic Math',
      description: 'Understanding basic mathematical operations',
      level: SkillLevel.beginner,
    ),
    Skill(
      id: '2',
      name: 'Reading',
      description: 'Basic reading comprehension',
      level: SkillLevel.beginner,
    ),
  ];

  final List<LearningPath> _learningPaths = [
    LearningPath(
      id: '1',
      name: 'Math Fundamentals',
      description: 'Learn basic mathematical concepts',
      skills: [],
      createdAt: DateTime.now(),
    ),
    LearningPath(
      id: '2',
      name: 'Language Basics',
      description: 'Master basic language skills',
      skills: [],
      createdAt: DateTime.now(),
    ),
  ];

  Skill? _currentSkill;
  LearningPath? _currentPath;

  List<Skill> get skills => List.unmodifiable(_skills);
  List<LearningPath> get learningPaths => List.unmodifiable(_learningPaths);
  Skill? get currentSkill => _currentSkill;
  LearningPath? get currentPath => _currentPath;

  void setCurrentSkill(Skill skill) {
    _currentSkill = skill;
    notifyListeners();
  }

  void setCurrentPath(LearningPath path) {
    _currentPath = path;
    notifyListeners();
  }

  void updateProgress(String id, double progress, {bool isPath = false}) {
    if (isPath) {
      final index = _learningPaths.indexWhere((p) => p.id == id);
      if (index != -1) {
        _learningPaths[index] = _learningPaths[index].copyWith(progress: progress);
        notifyListeners();
      }
    } else {
      final index = _skills.indexWhere((s) => s.id == id);
      if (index != -1) {
        _skills[index] = _skills[index].copyWith(progress: progress);
        _updateAffectedLearningPaths(id);
        notifyListeners();
      }
    }
  }

  void _updateAffectedLearningPaths(String skillId) {
    for (var path in _learningPaths) {
      if (path.skills.any((s) => s.id == skillId)) {
        double totalProgress = 0;
        for (var skill in path.skills) {
          totalProgress += skill.progress;
        }
        final index = _learningPaths.indexOf(path);
        _learningPaths[index] = path.copyWith(
          progress: path.skills.isEmpty ? 0 : totalProgress / path.skills.length,
        );
      }
    }
  }
}