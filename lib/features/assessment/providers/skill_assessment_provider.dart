import 'package:flutter/foundation.dart';

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  mastery,
}

class Skill {
  final String id;
  final String name;
  final String description;
  final SkillLevel currentLevel;
  final double progress;
  final List<String> criteria;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.currentLevel,
    required this.progress,
    required this.criteria,
  });
}

class LearningPath {
  final String id;
  final String name;
  final String description;
  final List<String> objectives;
  final double progress;
  final bool isCompleted;

  LearningPath({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.progress,
    this.isCompleted = false,
  });
}

class SkillAssessmentProvider extends ChangeNotifier {
  final List<Skill> _skills = [];
  final List<LearningPath> _learningPaths = [];
  Skill? _currentSkill;
  LearningPath? _currentPath;

  // Getters
  List<Skill> get skills => List.unmodifiable(_skills);
  List<LearningPath> get learningPaths => List.unmodifiable(_learningPaths);
  Skill? get currentSkill => _currentSkill;
  LearningPath? get currentPath => _currentPath;

  // Methods
  Future<void> fetchSkills() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _skills.clear();
    _skills.addAll([
      Skill(
        id: '1',
        name: 'Basic Mathematics',
        description: 'Understanding fundamental mathematical concepts',
        currentLevel: SkillLevel.beginner,
        progress: 0.3,
        criteria: [
          'Can perform basic addition and subtraction',
          'Understands multiplication tables up to 5',
          'Can solve simple word problems',
        ],
      ),
      Skill(
        id: '2',
        name: 'Reading Comprehension',
        description: 'Understanding and interpreting written text',
        currentLevel: SkillLevel.intermediate,
        progress: 0.6,
        criteria: [
          'Can read simple sentences fluently',
          'Understands basic vocabulary',
          'Can answer questions about a short text',
        ],
      ),
    ]);

    notifyListeners();
  }

  Future<void> fetchLearningPaths() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _learningPaths.clear();
    _learningPaths.addAll([
      LearningPath(
        id: '1',
        name: 'Mathematics Fundamentals',
        description: 'Master basic mathematical concepts step by step',
        objectives: [
          'Learn numbers and counting',
          'Practice addition and subtraction',
          'Understand basic multiplication',
        ],
        progress: 0.4,
      ),
      LearningPath(
        id: '2',
        name: 'Reading Basics',
        description: 'Build strong reading and comprehension skills',
        objectives: [
          'Learn alphabet and phonics',
          'Practice word recognition',
          'Read simple sentences',
        ],
        progress: 0.7,
      ),
    ]);

    notifyListeners();
  }

  void setCurrentSkill(String skillId) {
    _currentSkill = _skills.firstWhere(
      (skill) => skill.id == skillId,
      orElse: () => throw Exception('Skill not found'),
    );
    notifyListeners();
  }

  void setCurrentPath(String pathId) {
    _currentPath = _learningPaths.firstWhere(
      (path) => path.id == pathId,
      orElse: () => throw Exception('Learning path not found'),
    );
    notifyListeners();
  }

  Future<void> updateSkillProgress(String skillId, double progress) async {
    final index = _skills.indexWhere((skill) => skill.id == skillId);
    if (index == -1) return;

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final skill = _skills[index];
    _skills[index] = Skill(
      id: skill.id,
      name: skill.name,
      description: skill.description,
      currentLevel: _calculateSkillLevel(progress),
      progress: progress,
      criteria: skill.criteria,
    );

    if (_currentSkill?.id == skillId) {
      _currentSkill = _skills[index];
    }

    notifyListeners();
  }

  Future<void> updatePathProgress(String pathId, double progress) async {
    final index = _learningPaths.indexWhere((path) => path.id == pathId);
    if (index == -1) return;

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final path = _learningPaths[index];
    _learningPaths[index] = LearningPath(
      id: path.id,
      name: path.name,
      description: path.description,
      objectives: path.objectives,
      progress: progress,
      isCompleted: progress >= 1.0,
    );

    if (_currentPath?.id == pathId) {
      _currentPath = _learningPaths[index];
    }

    notifyListeners();
  }

  SkillLevel _calculateSkillLevel(double progress) {
    if (progress < 0.3) return SkillLevel.beginner;
    if (progress < 0.6) return SkillLevel.intermediate;
    if (progress < 0.9) return SkillLevel.advanced;
    return SkillLevel.mastery;
  }
} 