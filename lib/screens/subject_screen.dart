import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/learning_provider.dart';
import '../services/tts_service.dart';

abstract class SubjectScreen extends StatefulWidget {
  final String subject;
  final Color color;
  final IconData icon;

  const SubjectScreen({
    super.key,
    required this.subject,
    required this.color,
    required this.icon,
  });
}

abstract class SubjectScreenState<T extends SubjectScreen> extends State<T> {
  final TTSService _tts = TTSService();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    // TTSService is already initialized in its constructor
    // No need to call initTTS explicitly
  }

  Future<void> speak(String text) async {
    // Schedule the state update for the next frame
    Future(() {
      if (mounted) {
        Provider.of<LearningProvider>(context, listen: false).setAvatarSpeaking(true);
      }
    });

    await _tts.speak(text, context: widget.subject.toLowerCase().replaceAll(' ', '_'));

    // Schedule the state update for the next frame
    Future(() {
      if (mounted) {
        Provider.of<LearningProvider>(context, listen: false).setAvatarSpeaking(false);
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: widget.color.withOpacity(0.2),
      ),
      body: Column(
        children: [
          _buildAvatarSection(),
          _buildContentSection(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: widget.color.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: widget.color,
            child: Icon(widget.icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              getWelcomeMessage(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: buildSubjectContent(),
      ),
    );
  }

  String getWelcomeMessage();
  Widget buildSubjectContent();
} 