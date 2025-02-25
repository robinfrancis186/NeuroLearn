import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum SpeechPriority {
  immediate, // For critical feedback that should interrupt current speech
  high,      // For important instructions
  normal,    // For regular interactions
  low,       // For background information
}

class SpeechRequest {
  final String text;
  final SpeechPriority priority;
  final String? context;
  final String? voiceId;
  final Completer<void> completer;

  SpeechRequest({
    required this.text,
    this.priority = SpeechPriority.normal,
    this.context,
    this.voiceId,
  }) : completer = Completer<void>();

  @override
  String toString() => 'SpeechRequest(text: $text, priority: $priority, context: $context)';
}

class VoiceProfile {
  final String id;
  final String name;
  final String referenceAudioPath;
  final Map<String, dynamic> parameters;

  VoiceProfile({
    required this.id,
    required this.name,
    required this.referenceAudioPath,
    required this.parameters,
  });
}

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;

  final _audioPlayer = AudioPlayer();
  final _uuid = const Uuid();
  final Queue<SpeechRequest> _priorityQueue = Queue<SpeechRequest>();
  
  bool _isProcessing = false;
  SpeechRequest? _currentRequest;
  final Map<String, VoiceProfile> _voiceProfiles = {};
  String? _defaultVoiceId;

  VoiceService._internal();

  /// Register a new voice profile with a reference audio file
  Future<String> registerVoice({
    required String name,
    required File referenceAudio,
    Map<String, dynamic> parameters = const {},
  }) async {
    final voiceId = _uuid.v4();
    final directory = await getApplicationDocumentsDirectory();
    final voicePath = '${directory.path}/voices/$voiceId.wav';
    
    // Create voices directory if it doesn't exist
    await Directory('${directory.path}/voices').create(recursive: true);
    
    // Copy reference audio to app storage
    await referenceAudio.copy(voicePath);
    
    _voiceProfiles[voiceId] = VoiceProfile(
      id: voiceId,
      name: name,
      referenceAudioPath: voicePath,
      parameters: parameters,
    );

    // Set as default if first voice
    _defaultVoiceId ??= voiceId;
    
    return voiceId;
  }

  /// Set the default voice to use
  void setDefaultVoice(String voiceId) {
    if (_voiceProfiles.containsKey(voiceId)) {
      _defaultVoiceId = voiceId;
    }
  }

  /// Queue a speech request
  Future<void> speak(
    String text, {
    SpeechPriority priority = SpeechPriority.normal,
    String? context,
    String? voiceId,
  }) {
    final request = SpeechRequest(
      text: text,
      priority: priority,
      context: context,
      voiceId: voiceId ?? _defaultVoiceId,
    );
    
    _priorityQueue.add(request);
    _processQueue();
    
    return request.completer.future;
  }

  /// Stop current speech and clear queue
  Future<void> stop() async {
    _priorityQueue.clear();
    if (_currentRequest != null) {
      _currentRequest!.completer.complete();
      _currentRequest = null;
    }
    await _audioPlayer.stop();
    _isProcessing = false;
  }

  /// Process the speech queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_priorityQueue.isNotEmpty) {
      _currentRequest = _priorityQueue.removeFirst();
      
      try {
        // Generate speech audio using voice cloning if voice ID is provided
        final audioFile = await _generateSpeech(
          _currentRequest!.text,
          voiceId: _currentRequest!.voiceId,
        );
        
        if (audioFile != null) {
          await _audioPlayer.setFilePath(audioFile.path);
          await _audioPlayer.play();
          await _audioPlayer.processingStateStream.firstWhere(
            (state) => state == ProcessingState.completed,
          );
        }
        
        _currentRequest!.completer.complete();
      } catch (e) {
        _currentRequest!.completer.completeError(e);
      }
    }

    _currentRequest = null;
    _isProcessing = false;
  }

  /// Generate speech audio using voice cloning
  Future<File?> _generateSpeech(String text, {String? voiceId}) async {
    // TODO: Implement actual voice cloning logic
    // For now, return null to fall back to system TTS
    return null;
  }

  /// Dispose resources
  void dispose() {
    stop();
    _audioPlayer.dispose();
  }
} 