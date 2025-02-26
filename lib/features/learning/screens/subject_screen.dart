import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/learning_provider.dart';
import '../../../shared/services/tts_service.dart';

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
  bool _isLoading = false;
  bool _isSpeaking = false;

  Future<void> speak(String text) async {
    if (_isSpeaking) return;
    
    setState(() {
      _isSpeaking = true;
    });

    try {
      // Update avatar speaking state
      Provider.of<LearningProvider>(context, listen: false).setAvatarSpeaking(true);
      
      final tts = TTSService();
      await tts.speak(text);
      
    } catch (e) {
      debugPrint('Error speaking: $e');
    } finally {
      setState(() {
        _isSpeaking = false;
      });
      Provider.of<LearningProvider>(context, listen: false).setAvatarSpeaking(false);
    }
  }

  String getWelcomeMessage();

  Widget buildSubjectContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => speak(getWelcomeMessage()),
          ),
        ],
      ),
      body: Stack(
        children: [
          buildSubjectContent(),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 