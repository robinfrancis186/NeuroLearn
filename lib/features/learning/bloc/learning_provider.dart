import 'package:flutter/material.dart';

class LearningProvider with ChangeNotifier {
  int _currentLevel = 1;
  double _progress = 0.0;
  String _currentSubject = 'Math';
  bool _isAvatarSpeaking = false;

  int get currentLevel => _currentLevel;
  double get progress => _progress;
  String get currentSubject => _currentSubject;
  bool get isAvatarSpeaking => _isAvatarSpeaking;

  void updateProgress(double newProgress) {
    _progress = newProgress;
    if (_progress >= 1.0) {
      _levelUp();
    }
    notifyListeners();
  }

  void _levelUp() {
    _currentLevel++;
    _progress = 0.0;
    notifyListeners();
  }

  void setCurrentSubject(String subject) {
    _currentSubject = subject;
    notifyListeners();
  }

  void setAvatarSpeaking(bool isSpeaking) {
    _isAvatarSpeaking = isSpeaking;
    notifyListeners();
  }

  void resetProgress() {
    _currentLevel = 1;
    _progress = 0.0;
    notifyListeners();
  }
} 