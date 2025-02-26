import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../features/learning/learning.dart';
import '../shared/widgets/subject_card.dart';
import '../shared/widgets/progress_indicator.dart';
import '../core/constants/app_colors.dart';
import 'settings_screen.dart';
import 'ask_question_screen.dart';
import 'available_quizzes_screen.dart';
import 'progress_screen.dart';
import 'achievement_screen.dart';
import 'collaborative_sessions_screen.dart';
import 'dashboard_screen.dart';
import 'skill_assessment_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'NeuroLearn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
            tooltip: 'Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementScreen()),
              );
            },
            tooltip: 'Achievements',
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProgressScreen()),
              );
            },
            tooltip: 'Progress',
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvailableQuizzesScreen()),
              );
            },
            tooltip: 'Quizzes',
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CollaborativeSessionsScreen()),
              );
            },
            tooltip: 'Collaborative Learning',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Skills & Learning',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillAssessmentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AskQuestionScreen()),
          );
        },
        icon: const Icon(Icons.question_answer),
        label: const Text('Ask Question'),
        elevation: 4,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSubjects(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final learningProvider = Provider.of<LearningProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AvatarGlow(
                glowColor: AppColors.primary,
                endRadius: 40,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                animate: learningProvider.isAvatarSpeaking,
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: AppColors.onPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Ready to continue learning?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem(
                context,
                'Level',
                learningProvider.currentLevel.toString(),
                Icons.star,
              ),
              _buildProgressItem(
                context,
                'Progress',
                '${(learningProvider.progress * 100).toInt()}%',
                Icons.trending_up,
              ),
              _buildProgressItem(
                context,
                'Subject',
                learningProvider.currentSubject,
                Icons.book,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjects(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Subject',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              SubjectCard(
                subject: 'Math',
                icon: Icons.calculate,
                color: AppColors.subjectColors['Math']!,
              ),
              SubjectCard(
                subject: 'Language',
                icon: Icons.translate,
                color: AppColors.subjectColors['Languages']!,
              ),
              SubjectCard(
                subject: 'Memory',
                icon: Icons.psychology,
                color: AppColors.subjectColors['Science']!,
              ),
              SubjectCard(
                subject: 'Life Skills',
                icon: Icons.emoji_objects,
                color: AppColors.subjectColors['Arts']!,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 