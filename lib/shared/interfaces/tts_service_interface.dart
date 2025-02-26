import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../services/tts_config.dart';

enum SpeechPriority { low, normal, high }

abstract class ITTSService {
  /// Speaks the provided text
  Future<void> speak(
    String text, {
    SpeechPriority priority,
    String? context,
    String? voiceId,
  });

  /// Stops any ongoing speech
  Future<void> stop();

  /// Sets the voice to use for speech
  Future<void> setVoice(String voice);

  /// Updates the TTS configuration
  Future<void> updateConfig(F5TTSConfig newConfig);

  /// Queues speech with priority
  Future<void> queueSpeech(
    String text, {
    String? context,
    int priority,
    bool useReferenceAudio,
    String? referenceAudioPath,
    String? referenceText,
  });

  /// Disposes resources
  void dispose();
} 