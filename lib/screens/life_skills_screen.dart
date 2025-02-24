import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'subject_screen.dart';

class LifeSkillsScreen extends SubjectScreen {
  const LifeSkillsScreen({super.key})
      : super(
          subject: 'Life Skills',
          color: Colors.orange,
          icon: Icons.accessibility_new,
        );

  @override
  State<LifeSkillsScreen> createState() => _LifeSkillsScreenState();
}

class _LifeSkillsScreenState extends SubjectScreenState<LifeSkillsScreen> {
  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Morning Routine',
      'tasks': [
        'Wake up',
        'Brush teeth',
        'Take a shower',
        'Get dressed',
        'Eat breakfast',
      ],
      'icon': Icons.wb_sunny,
    },
    {
      'title': 'Personal Hygiene',
      'tasks': [
        'Wash hands',
        'Comb hair',
        'Use tissue',
        'Clean face',
        'Cut nails',
      ],
      'icon': Icons.cleaning_services,
    },
    {
      'title': 'Safety Skills',
      'tasks': [
        'Look both ways',
        'Use crosswalk',
        'Emergency numbers',
        'Ask for help',
        'Stay with group',
      ],
      'icon': Icons.security,
    },
    {
      'title': 'Social Skills',
      'tasks': [
        'Say hello',
        'Say please',
        'Say thank you',
        'Share things',
        'Wait your turn',
      ],
      'icon': Icons.people,
    },
  ];

  int _currentActivityIndex = 0;
  List<bool> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _resetTasks();
    _explainActivity();
  }

  void _resetTasks() {
    setState(() {
      _completedTasks = List.filled(
        _activities[_currentActivityIndex]['tasks'].length,
        false,
      );
    });
  }

  void _explainActivity() {
    final activity = _activities[_currentActivityIndex];
    speak("Let's practice ${activity['title']}. I'll help you learn these important tasks.");
  }

  void _toggleTask(int index) {
    setState(() {
      _completedTasks[index] = !_completedTasks[index];
      
      if (_completedTasks[index]) {
        speak("Great job! You've learned how to ${_activities[_currentActivityIndex]['tasks'][index]}");
      }

      if (_completedTasks.every((task) => task)) {
        speak("Excellent! You've completed all tasks in this activity!");
      }
    });
  }

  void _changeActivity(int index) {
    setState(() {
      _currentActivityIndex = index;
      _resetTasks();
      _explainActivity();
    });
  }

  @override
  String getWelcomeMessage() {
    return "Let's learn important life skills!";
  }

  @override
  Widget buildSubjectContent() {
    final currentActivity = _activities[_currentActivityIndex];
    
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final activity = _activities[index];
              final isSelected = index == _currentActivityIndex;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Row(
                    children: [
                      Icon(
                        activity['icon'],
                        size: 20,
                        color: isSelected ? Colors.white : widget.color,
                      ),
                      const SizedBox(width: 8),
                      Text(activity['title']),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => _changeActivity(index),
                  selectedColor: widget.color,
                  backgroundColor: widget.color.withOpacity(0.1),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentActivity['tasks'].length,
            itemBuilder: (context, index) {
              final task = currentActivity['tasks'][index];
              final isCompleted = _completedTasks[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : widget.color.withOpacity(0.1),
                child: ListTile(
                  leading: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted ? Colors.green : widget.color,
                  ),
                  title: Text(
                    task,
                    style: TextStyle(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  onTap: () => _toggleTask(index),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _resetTasks,
            icon: const Icon(Icons.refresh),
            label: const Text('Start Over'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color.withOpacity(0.2),
              foregroundColor: widget.color,
            ),
          ),
        ),
      ],
    );
  }
} 