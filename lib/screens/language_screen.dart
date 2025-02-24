import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;
import 'subject_screen.dart';

class LanguageScreen extends SubjectScreen {
  const LanguageScreen({super.key})
      : super(
          subject: 'Language',
          color: Colors.green,
          icon: Icons.language,
        );

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends SubjectScreenState<LanguageScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _currentWord = '';
  List<String> _words = [
    'apple',
    'banana',
    'cat',
    'dog',
    'elephant',
    'fish',
    'giraffe',
    'house',
  ];
  String _spokenWords = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _selectNewWord();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => print('Error: $error'),
    );
  }

  void _selectNewWord() {
    final random = math.Random();
    setState(() {
      _currentWord = _words[random.nextInt(_words.length)];
      _spokenWords = '';
    });
    speak('Can you say the word: $_currentWord');
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenWords = result.recognizedWords.toLowerCase();
              if (_spokenWords == _currentWord.toLowerCase()) {
                speak('Excellent pronunciation!');
                Future.delayed(
                  const Duration(seconds: 2),
                  _selectNewWord,
                );
              }
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  String getWelcomeMessage() {
    return "Let's practice pronunciation!";
  }

  @override
  Widget buildSubjectContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _currentWord,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  Icons.volume_up,
                  size: 40,
                  color: widget.color,
                ),
                const SizedBox(height: 20),
                Text(
                  _spokenWords.isEmpty ? 'Tap the microphone and speak' : _spokenWords,
                  style: TextStyle(
                    fontSize: 24,
                    color: _spokenWords == _currentWord.toLowerCase()
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => speak(_currentWord),
              icon: const Icon(Icons.volume_up),
              label: const Text('Hear Word'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color.withOpacity(0.2),
                foregroundColor: widget.color,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Stop' : 'Speak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening
                    ? Colors.red.withOpacity(0.2)
                    : widget.color.withOpacity(0.2),
                foregroundColor: _isListening ? Colors.red : widget.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _selectNewWord,
          icon: const Icon(Icons.refresh),
          label: const Text('New Word'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color.withOpacity(0.2),
            foregroundColor: widget.color,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
} 