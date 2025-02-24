import 'package:flutter/material.dart';

class QuizInfo {
  final String title;
  final String description;
  final int duration;
  final int questions;
  final String difficulty;
  final List<Reward> rewards;
  final bool isTimed;

  QuizInfo({
    required this.title,
    required this.description,
    required this.duration,
    required this.questions,
    required this.difficulty,
    required this.rewards,
    this.isTimed = false,
  });
}

class Reward {
  final String badge;
  final int xp;

  Reward({required this.badge, required this.xp});
}

class AvailableQuizzesScreen extends StatelessWidget {
  AvailableQuizzesScreen({super.key});

  final List<QuizInfo> quizzes = [
    QuizInfo(
      title: 'Mathematics Basics',
      description: 'Test your fundamental math skills',
      duration: 15,
      questions: 10,
      difficulty: 'Easy',
      isTimed: true,
      rewards: [
        Reward(badge: 'Quick Thinker Badge', xp: 100),
      ],
    ),
    QuizInfo(
      title: 'Algebra Fundamentals',
      description: 'Master algebraic concepts',
      duration: 20,
      questions: 15,
      difficulty: 'Medium',
      rewards: [
        Reward(badge: 'Algebra Master Badge', xp: 150),
      ],
    ),
    QuizInfo(
      title: 'Geometry Quiz',
      description: 'Explore shapes and spatial relationships',
      duration: 18,
      questions: 12,
      difficulty: 'Easy',
      isTimed: true,
      rewards: [
        Reward(badge: 'Geometry Guru Badge', xp: 120),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.quiz),
            const SizedBox(width: 8),
            const Text('Available Quizzes'),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.emoji_events, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Level 5',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement challenge mode
              },
              icon: const Icon(Icons.flash_on),
              label: const Text('Challenge Mode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        quiz.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (quiz.isTimed) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer, size: 16),
                              const SizedBox(width: 4),
                              const Text('Timed'),
                            ],
                          ),
                          backgroundColor: Colors.amber.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(quiz.description),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            context,
                            Icons.timer_outlined,
                            'Duration',
                            '${quiz.duration} mins',
                          ),
                          _buildInfoItem(
                            context,
                            Icons.quiz_outlined,
                            'Questions',
                            quiz.questions.toString(),
                          ),
                          _buildInfoItem(
                            context,
                            Icons.speed,
                            'Difficulty',
                            quiz.difficulty,
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          const Text(
                            'Rewards:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ...quiz.rewards.map((reward) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.military_tech, size: 20),
                                  const SizedBox(width: 4),
                                  Text(reward.badge),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${reward.xp} XP',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement quiz start
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Start Quiz'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 