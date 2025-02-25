import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  mastery
}

class Skill {
  final String id;
  final String name;
  final String description;
  final String subject;
  final List<String> prerequisites;
  final List<String> nextSkills;
  final Map<String, dynamic> assessmentCriteria;
  double progress;
  SkillLevel level;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    this.prerequisites = const [],
    this.nextSkills = const [],
    required this.assessmentCriteria,
    this.progress = 0.0,
    this.level = SkillLevel.beginner,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'subject': subject,
    'prerequisites': prerequisites,
    'nextSkills': nextSkills,
    'assessmentCriteria': assessmentCriteria,
    'progress': progress,
    'level': level.index,
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    subject: json['subject'],
    prerequisites: List<String>.from(json['prerequisites']),
    nextSkills: List<String>.from(json['nextSkills']),
    assessmentCriteria: json['assessmentCriteria'],
    progress: json['progress'],
    level: SkillLevel.values[json['level']],
  );
}

class LearningPath {
  final String id;
  final String name;
  final String description;
  final List<String> skillIds;
  final DateTime createdAt;
  DateTime? completedAt;
  double progress;

  LearningPath({
    required this.id,
    required this.name,
    required this.description,
    required this.skillIds,
    required this.createdAt,
    this.completedAt,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'skillIds': skillIds,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'progress': progress,
  };

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    skillIds: List<String>.from(json['skillIds']),
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    progress: json['progress'],
  );
}

class SkillAssessmentProvider with ChangeNotifier {
  final Map<String, Skill> _skills = {};
  final Map<String, LearningPath> _learningPaths = {};
  final Map<String, List<String>> _subjectSkills = {};
  
  Map<String, Skill> get skills => _skills;
  Map<String, LearningPath> get learningPaths => _learningPaths;
  Map<String, List<String>> get subjectSkills => _subjectSkills;

  SkillAssessmentProvider() {
    _initializeSkills();
    _loadData();
  }

  void _initializeSkills() {
    // Initialize with default skills for each subject
    _addSkill(Skill(
      id: 'math_basic_numbers',
      name: 'Basic Numbers',
      description: 'Understanding and working with numbers 1-10',
      subject: 'Math',
      nextSkills: ['math_basic_addition'],
      assessmentCriteria: {
        'number_recognition': 0.0,
        'counting': 0.0,
        'number_sequence': 0.0,
      },
    ));

    _addSkill(Skill(
      id: 'math_basic_addition',
      name: 'Basic Addition',
      description: 'Adding numbers 1-10',
      subject: 'Math',
      prerequisites: ['math_basic_numbers'],
      nextSkills: ['math_basic_subtraction'],
      assessmentCriteria: {
        'single_digit_addition': 0.0,
        'number_bonds': 0.0,
        'word_problems': 0.0,
      },
    ));

    _addSkill(Skill(
      id: 'language_phonics',
      name: 'Basic Phonics',
      description: 'Understanding letter sounds',
      subject: 'Language',
      nextSkills: ['language_sight_words'],
      assessmentCriteria: {
        'letter_sounds': 0.0,
        'blending': 0.0,
        'segmenting': 0.0,
      },
    ));

    // Add more default skills...
  }

  void _addSkill(Skill skill) {
    _skills[skill.id] = skill;
    _subjectSkills.putIfAbsent(skill.subject, () => []).add(skill.id);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load skills progress
    final skillsJson = prefs.getString('skills_data');
    if (skillsJson != null) {
      final Map<String, dynamic> data = jsonDecode(skillsJson);
      data.forEach((id, skillData) {
        if (_skills.containsKey(id)) {
          _skills[id]!.progress = skillData['progress'];
          _skills[id]!.level = SkillLevel.values[skillData['level']];
        }
      });
    }

    // Load learning paths
    final pathsJson = prefs.getString('learning_paths');
    if (pathsJson != null) {
      final List<dynamic> paths = jsonDecode(pathsJson);
      for (var pathData in paths) {
        final path = LearningPath.fromJson(pathData);
        _learningPaths[path.id] = path;
      }
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save skills progress
    final skillsData = Map.fromEntries(
      _skills.entries.map((e) => MapEntry(e.key, {
        'progress': e.value.progress,
        'level': e.value.level.index,
      }))
    );
    await prefs.setString('skills_data', jsonEncode(skillsData));

    // Save learning paths
    final pathsData = _learningPaths.values.map((p) => p.toJson()).toList();
    await prefs.setString('learning_paths', jsonEncode(pathsData));
  }

  Future<void> updateSkillProgress(String skillId, Map<String, double> assessment) async {
    if (!_skills.containsKey(skillId)) return;

    final skill = _skills[skillId]!;
    double totalProgress = 0;
    int criteriaCount = 0;

    // Update individual criteria scores
    assessment.forEach((criteria, score) {
      if (skill.assessmentCriteria.containsKey(criteria)) {
        skill.assessmentCriteria[criteria] = score;
        totalProgress += score;
        criteriaCount++;
      }
    });

    // Calculate overall progress
    if (criteriaCount > 0) {
      skill.progress = totalProgress / criteriaCount;
      
      // Update skill level based on progress
      if (skill.progress >= 0.9) {
        skill.level = SkillLevel.mastery;
      } else if (skill.progress >= 0.75) {
        skill.level = SkillLevel.advanced;
      } else if (skill.progress >= 0.5) {
        skill.level = SkillLevel.intermediate;
      }

      await _saveData();
      notifyListeners();

      // Update related learning paths
      _updateAffectedLearningPaths(skillId);
    }
  }

  void _updateAffectedLearningPaths(String skillId) {
    for (var path in _learningPaths.values) {
      if (path.skillIds.contains(skillId)) {
        _updateLearningPathProgress(path.id);
      }
    }
  }

  Future<String> generateLearningPath({
    required String subject,
    required String name,
    String? description,
  }) async {
    // Get all skills for the subject
    final subjectSkillIds = _subjectSkills[subject] ?? [];
    if (subjectSkillIds.isEmpty) return '';

    // Sort skills by prerequisites to create a logical sequence
    final orderedSkills = _sortSkillsByPrerequisites(subjectSkillIds);

    // Create new learning path
    final path = LearningPath(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description ?? 'Personalized learning path for $subject',
      skillIds: orderedSkills,
      createdAt: DateTime.now(),
    );

    _learningPaths[path.id] = path;
    _updateLearningPathProgress(path.id);
    await _saveData();
    notifyListeners();

    return path.id;
  }

  List<String> _sortSkillsByPrerequisites(List<String> skillIds) {
    final sorted = <String>[];
    final remaining = Set<String>.from(skillIds);
    
    while (remaining.isNotEmpty) {
      bool added = false;
      
      for (final skillId in remaining.toList()) {
        final skill = _skills[skillId]!;
        if (skill.prerequisites.isEmpty || 
            skill.prerequisites.every((prereq) => sorted.contains(prereq))) {
          sorted.add(skillId);
          remaining.remove(skillId);
          added = true;
        }
      }
      
      if (!added) {
        // If no skills were added in this iteration, add the first remaining skill
        // to prevent infinite loops in case of circular dependencies
        final skillId = remaining.first;
        sorted.add(skillId);
        remaining.remove(skillId);
      }
    }
    
    return sorted;
  }

  void _updateLearningPathProgress(String pathId) {
    final path = _learningPaths[pathId];
    if (path == null) return;

    double totalProgress = 0;
    for (var skillId in path.skillIds) {
      if (_skills.containsKey(skillId)) {
        totalProgress += _skills[skillId]!.progress;
      }
    }

    path.progress = totalProgress / path.skillIds.length;
    if (path.progress >= 1.0) {
      path.completedAt = DateTime.now();
    }

    notifyListeners();
  }

  List<String> getNextRecommendedSkills(String currentSkillId) {
    final currentSkill = _skills[currentSkillId];
    if (currentSkill == null) return [];

    // If current skill is not mastered, don't recommend next skills
    if (currentSkill.progress < 0.75) return [currentSkillId];

    return currentSkill.nextSkills.where((skillId) {
      final skill = _skills[skillId];
      if (skill == null) return false;

      // Check if prerequisites are met
      return skill.prerequisites.every((prereqId) {
        final prereq = _skills[prereqId];
        return prereq != null && prereq.progress >= 0.75;
      });
    }).toList();
  }

  Map<String, double> getSkillGaps(String subject) {
    final gaps = <String, double>{};
    final subjectSkillIds = _subjectSkills[subject] ?? [];

    for (var skillId in subjectSkillIds) {
      final skill = _skills[skillId];
      if (skill != null && skill.progress < 0.75) {
        gaps[skillId] = 0.75 - skill.progress;
      }
    }

    return gaps;
  }
} 