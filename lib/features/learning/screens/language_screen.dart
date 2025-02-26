import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;
import 'subject_screen.dart';
import '../../../core/constants/app_colors.dart';

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
  final List<String> _words = [
    'apple',
    'banana',
    'cat',
    'dog',
    'elephant',
    'fish',
    'giraffe',
    'house',
  ];
  
  String _currentWord = '';
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
      onError: (error) => debugPrint('Error: $error'),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _currentWord,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => speak(_currentWord),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up,
                      size: 40,
                      color: widget.color,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildPronunciationFeedback(),
                const SizedBox(height: 30),
                _buildMicButton(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildWordList(),
      ],
    );
  }

  Widget _buildPronunciationFeedback() {
    if (_spokenWords.isEmpty) {
      return Text(
        'Tap the microphone and say the word',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      );
    }

    bool isCorrect = _spokenWords.toLowerCase() == _currentWord.toLowerCase();
    
    return Column(
      children: [
        Text(
          'You said:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _spokenWords,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isCorrect 
                ? const Color(0xFF4CAF50).withAlpha(30) 
                : const Color(0xFFF44336).withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct!' : 'Try again',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isListening ? 80 : 64,
        height: _isListening ? 80 : 64,
        decoration: BoxDecoration(
          color: _isListening 
              ? widget.color 
              : widget.color.withAlpha(230),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(100),
              blurRadius: _isListening ? 12 : 8,
              spreadRadius: _isListening ? 2 : 0,
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: _isListening ? 40 : 32,
        ),
      ),
    );
  }

  Widget _buildWordList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Word List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _words.map((word) {
                bool isActive = word == _currentWord;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentWord = word;
                      _spokenWords = '';
                    });
                    speak('Can you say the word: $word');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? widget.color.withAlpha(30) 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive 
                            ? widget.color 
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? widget.color : Colors.grey[800],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
} 