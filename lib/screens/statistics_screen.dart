import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statistics = Provider.of<StatisticsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statistics.period,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatisticsCard(statistics),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(StatisticsProvider statistics) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatItem(
                        icon: Icons.person_outline,
                        label: 'Absence',
                        percentage: statistics.absence.toInt(),
                        color: const Color(0xFF4A90E2),
                      ),
                      const SizedBox(height: 24),
                      _buildStatItem(
                        icon: Icons.assignment_outlined,
                        label: 'Tasks & Exam',
                        percentage: statistics.tasksAndExam.toInt(),
                        color: const Color(0xFF66BB6A),
                      ),
                      const SizedBox(height: 24),
                      _buildStatItem(
                        icon: Icons.timer_outlined,
                        label: 'Quiz',
                        percentage: statistics.quiz.toInt(),
                        color: const Color(0xFFFFA726),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: statistics.gradesCompleted / 100,
                          backgroundColor: const Color(0xFF66BB6A).withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
                          strokeWidth: 12,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${statistics.gradesCompleted.toInt()}%',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Grades Completed',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int percentage,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 