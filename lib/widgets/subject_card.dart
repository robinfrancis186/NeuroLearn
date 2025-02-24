import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/learning_provider.dart';
import '../screens/math_screen.dart';
import '../screens/language_screen.dart';
import '../screens/memory_screen.dart';
import '../screens/life_skills_screen.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.icon,
    required this.color,
  });

  void _navigateToSubject(BuildContext context) {
    Provider.of<LearningProvider>(context, listen: false).changeSubject(subject);
    
    Widget screen;
    switch (subject) {
      case 'Math':
        screen = const MathScreen();
        break;
      case 'Language':
        screen = const LanguageScreen();
        break;
      case 'Memory':
        screen = const MemoryScreen();
        break;
      case 'Life Skills':
        screen = const LifeSkillsScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSubject(context),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 