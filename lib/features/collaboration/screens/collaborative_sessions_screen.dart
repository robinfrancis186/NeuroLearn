import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth.dart';
import '../providers/collaborative_provider.dart';
import '../../../theme/app_colors.dart';
import 'collaborative_session_screen.dart';

class CollaborativeSessionsScreen extends StatefulWidget {
  const CollaborativeSessionsScreen({super.key});

  @override
  State<CollaborativeSessionsScreen> createState() => _CollaborativeSessionsScreenState();
}

class _CollaborativeSessionsScreenState extends State<CollaborativeSessionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionNameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _sessionNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
      await collaborativeProvider.fetchAvailableSessions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load sessions')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final collaborativeProvider = Provider.of<CollaborativeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentSubject = authProvider.user?.preferences['currentSubject'] ?? 'General';
      final userName = authProvider.userName ?? 'Anonymous';

      final sessionId = await collaborativeProvider.createSession(
        name: _sessionNameController.text,
        subject: currentSubject,
        participants: [userName],
        creatorName: userName,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollaborativeSessionScreen(sessionId: sessionId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create session')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinSession() async {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CollaborativeSessionScreen(sessionId: code),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join session')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborative Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCreateSessionCard(),
                  const SizedBox(height: 16),
                  _buildJoinSessionCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Available Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSessionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSessionsList() {
    return Consumer<CollaborativeProvider>(
      builder: (context, provider, child) {
        final sessions = provider.sessions;
        if (sessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No active sessions found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: AppColors.primary.withAlpha(100),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withAlpha(30),
                  child: session.creatorName.isNotEmpty
                      ? Text(
                          session.creatorName[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.person_outline),
                ),
                title: Text(session.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created by ${session.creatorName}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Subject: ${session.subject}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${session.participants.length} participants',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollaborativeSessionScreen(sessionId: session.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateSessionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _sessionNameController,
                decoration: const InputDecoration(
                  labelText: 'Session Name',
                  hintText: 'Enter a name for your session',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a session name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _createSession,
                child: const Text('Create Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinSessionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _joinCodeController,
              decoration: const InputDecoration(
                labelText: 'Session Code',
                hintText: 'Enter session code to join',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _joinSession,
              child: const Text('Join Session'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
} 