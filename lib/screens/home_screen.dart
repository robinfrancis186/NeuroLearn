import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../providers/learning_provider.dart';
import '../widgets/subject_card.dart';
import '../widgets/progress_indicator.dart';
import 'settings_screen.dart';
import 'ask_question_screen.dart';
import 'available_quizzes_screen.dart';
import 'progress_screen.dart';
import 'achievement_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroLearn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProgressScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvailableQuizzesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildHeader(context),
            _buildAvatarSection(context),
            _buildQuickPractice(context),
            _buildRecommendedSection(context),
            _buildAllSubjects(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final learningProvider = Provider.of<LearningProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level ${learningProvider.currentLevel}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Keep going!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          CustomProgressIndicator(
            progress: learningProvider.progress,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: AvatarGlow(
        glowColor: Theme.of(context).colorScheme.primary,
        endRadius: 90.0,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        showTwoGlows: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          radius: 60,
          child: const Icon(
            Icons.face,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPractice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Practice',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is 2 + 3 when x = 2?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter your answer',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Check Answer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended for You',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecommendedCard(
                  context,
                  'Introduction to Mathematics',
                  'Start your journey with basic math concepts',
                  Icons.calculate,
                  Colors.blue,
                  '25 mins',
                ),
                _buildRecommendedCard(
                  context,
                  'Geometry Fundamentals',
                  'Explore shapes, angles, and spatial relationships',
                  Icons.architecture,
                  Colors.green,
                  '30 mins',
                ),
                _buildRecommendedCard(
                  context,
                  'Basic Algebra',
                  'Learn about variables, equations, and expressions',
                  Icons.functions,
                  Colors.purple,
                  '20 mins',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String duration,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Start Lesson'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllSubjects(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Subjects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: const [
              SubjectCard(
                subject: 'Math',
                icon: Icons.calculate,
                color: Colors.blue,
              ),
              SubjectCard(
                subject: 'Language',
                icon: Icons.language,
                color: Colors.green,
              ),
              SubjectCard(
                subject: 'Memory',
                icon: Icons.psychology,
                color: Colors.purple,
              ),
              SubjectCard(
                subject: 'Life Skills',
                icon: Icons.accessibility_new,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 