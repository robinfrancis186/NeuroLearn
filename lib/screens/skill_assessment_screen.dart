import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_assessment_provider.dart';
import '../theme/app_colors.dart';

class SkillAssessmentScreen extends StatelessWidget {
  const SkillAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skills & Learning'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Skills'),
              Tab(text: 'Learning Paths'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SkillsTab(),
            _LearningPathsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreatePathDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreatePathDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateLearningPathDialog(),
    );
  }
}

class _SkillsTab extends StatelessWidget {
  const _SkillsTab();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SkillAssessmentProvider>(context);
    final skills = provider.skills.values.toList()
      ..sort((a, b) => a.subject.compareTo(b.subject));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return _SkillCard(skill: skill);
      },
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(skill.name),
        subtitle: Text(skill.subject),
        leading: _buildLevelIcon(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Assessment Criteria',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...skill.assessmentCriteria.entries.map((entry) {
                  return _CriteriaProgressBar(
                    label: entry.key.replaceAll('_', ' ').toUpperCase(),
                    progress: entry.value,
                  );
                }),
                if (skill.prerequisites.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Prerequisites',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: skill.prerequisites.map((prereq) {
                      return Chip(label: Text(prereq));
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIcon() {
    IconData icon;
    Color color;

    switch (skill.level) {
      case SkillLevel.beginner:
        icon = Icons.star_border;
        color = Colors.grey;
        break;
      case SkillLevel.intermediate:
        icon = Icons.star_half;
        color = Colors.blue;
        break;
      case SkillLevel.advanced:
        icon = Icons.star;
        color = Colors.orange;
        break;
      case SkillLevel.mastery:
        icon = Icons.workspace_premium;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _CriteriaProgressBar extends StatelessWidget {
  final String label;
  final double progress;

  const _CriteriaProgressBar({
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.lightBg,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value >= 0.9) return Colors.purple;
    if (value >= 0.75) return Colors.green;
    if (value >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

class _LearningPathsTab extends StatelessWidget {
  const _LearningPathsTab();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SkillAssessmentProvider>(context);
    final paths = provider.learningPaths.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (paths.isEmpty) {
      return const Center(
        child: Text('No learning paths yet. Create one to get started!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final path = paths[index];
        return _LearningPathCard(path: path);
      },
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  final LearningPath path;

  const _LearningPathCard({required this.path});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SkillAssessmentProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(path.name),
            subtitle: Text(path.description),
            trailing: CircularProgressIndicator(
              value: path.progress,
              backgroundColor: AppColors.lightBg,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...path.skillIds.map((skillId) {
                  final skill = provider.skills[skillId];
                  if (skill == null) return const SizedBox.shrink();

                  return ListTile(
                    title: Text(skill.name),
                    subtitle: LinearProgressIndicator(
                      value: skill.progress,
                      backgroundColor: AppColors.lightBg,
                    ),
                    leading: Icon(
                      Icons.check_circle,
                      color: skill.progress >= 0.75 ? Colors.green : Colors.grey,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateLearningPathDialog extends StatefulWidget {
  const _CreateLearningPathDialog();

  @override
  State<_CreateLearningPathDialog> createState() => _CreateLearningPathDialogState();
}

class _CreateLearningPathDialogState extends State<_CreateLearningPathDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSubject = 'Math';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Learning Path'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
              ),
              items: const [
                DropdownMenuItem(value: 'Math', child: Text('Mathematics')),
                DropdownMenuItem(value: 'Language', child: Text('Language')),
                DropdownMenuItem(value: 'Memory', child: Text('Memory')),
                DropdownMenuItem(value: 'Life Skills', child: Text('Life Skills')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSubject = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Path Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createPath,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createPath() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<SkillAssessmentProvider>(context, listen: false);
    final pathId = await provider.generateLearningPath(
      subject: _selectedSubject,
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (mounted && pathId.isNotEmpty) {
      Navigator.pop(context);
    }
  }
} 