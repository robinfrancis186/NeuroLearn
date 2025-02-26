import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'tts_config.dart';
import 'package:crypto/crypto.dart';
import 'dart:async'; // Add this import for StreamSubscription
import 'voice_service.dart' as voice;
import '../interfaces/tts_service_interface.dart';

// Speech request class with priority
class SpeechRequest {
  final String text;
  final String? context;
  final int priority;
  final Completer<void> completer;
  final bool useReferenceAudio;
  final String? referenceAudioPath;
  final String? referenceText;

  SpeechRequest({
    required this.text,
    this.context,
    this.priority = 1, // Default priority (higher number = higher priority)
    this.useReferenceAudio = false,
    this.referenceAudioPath,
    this.referenceText,
  }) : completer = Completer<void>();

  Future<void> get future => completer.future;
}

@LazySingleton(as: ITTSService)
class TTSService implements ITTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  
  late final AudioPlayer _audioPlayer;
  late final FlutterTts _flutterTts;
  bool _isF5TTSAvailable = true;
  F5TTSConfig _config = F5TTSConfig();  // Initialize with default values
  final Map<String, File> _audioCache = {};
  final Map<String, String> _customVoicePaths = {};
  
  // Priority queue for speech requests
  final List<SpeechRequest> _requestQueue = [];
  bool _isProcessingQueue = false;
  
  // Voice cloning storage
  final Map<String, Map<String, dynamic>> _clonedVoices = {};

  final voice.VoiceService _voiceService = voice.VoiceService();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  TTSService._internal() {
    _audioPlayer = AudioPlayer();
    _flutterTts = FlutterTts();
    _setupFlutterTts();
    _initTTS(); // Start async initialization
    _loadCustomVoices();
    _loadVoiceProfiles(); // Load saved voice profiles
    _loadClonedVoices(); // Load saved cloned voices
    _initialize();
  }

  String? _currentVoice;
  final Map<String, Map<String, dynamic>> _voices = {
    'default': {
      'name': 'cheerful',
      'style_text': 'cheerful and friendly, speaking clearly and naturally',
      'emotion': 'happy',
      'language': 'en',
      'pitch': 1.0,
      'speed': 1.0,
    },
    'math': {
      'name': 'teacher',
      'style_text': 'patient and clear teaching style, explaining concepts step by step',
      'emotion': 'confident',
      'language': 'en',
      'pitch': 0.9,
      'speed': 0.85,
    },
    'language': {
      'name': 'friendly',
      'style_text': 'encouraging and supportive, speaking slowly and clearly for language learning',
      'emotion': 'happy',
      'language': 'en',
      'pitch': 1.1,
      'speed': 0.8,
    },
    'memory': {
      'name': 'encouraging',
      'style_text': 'enthusiastic and motivating, speaking with clear emphasis on important words',
      'emotion': 'excited',
      'language': 'en',
      'pitch': 1.2,
      'speed': 1.1,
    },
    'life_skills': {
      'name': 'supportive',
      'style_text': 'gentle and patient guidance, speaking in a calm and reassuring manner',
      'emotion': 'calm',
      'language': 'en',
      'pitch': 0.95,
      'speed': 0.9,
    },
  };

  // Getter for voice profiles
  Map<String, Map<String, dynamic>> get voiceProfiles => _voices;
  
  // Getter for cloned voices
  Map<String, Map<String, dynamic>> get clonedVoices => _clonedVoices;
  
  // Stream controller for audio streaming
  StreamSubscription<void>? _audioStreamSubscription;
  bool _isStreaming = false;
  
  Future<void> _setupFlutterTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    // Set up completion listener
    _flutterTts.setCompletionHandler(() {
      _isStreaming = false;
    });
  }

  Future<void> _initTTS() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<void> setVoice(String voice) async {
    _currentVoice = voice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice', voice);
  }

  Future<void> updateConfig(F5TTSConfig newConfig) async {
    _config = newConfig;
    await _config.save();
    await _initTTS(); // Reinitialize with new config
  }

  // New method to add a speech request to the queue
  Future<void> queueSpeech(String text, {
    String? context, 
    int priority = 1,
    bool useReferenceAudio = false,
    String? referenceAudioPath,
    String? referenceText,
  }) async {
    final request = SpeechRequest(
      text: text,
      context: context,
      priority: priority,
      useReferenceAudio: useReferenceAudio,
      referenceAudioPath: referenceAudioPath,
      referenceText: referenceText,
    );
    
    // Add to queue based on priority
    int insertIndex = 0;
    while (insertIndex < _requestQueue.length && 
           _requestQueue[insertIndex].priority >= request.priority) {
      insertIndex++;
    }
    
    _requestQueue.insert(insertIndex, request);
    
    // Start processing the queue if not already processing
    if (!_isProcessingQueue) {
      _processQueue();
    }
    
    return request.future;
  }
  
  // Process the speech request queue
  Future<void> _processQueue() async {
    if (_requestQueue.isEmpty || _isProcessingQueue) return;
    
    _isProcessingQueue = true;
    
    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeAt(0);
      
      try {
        if (request.useReferenceAudio && request.referenceAudioPath != null) {
          await _speakWithReferenceAudio(
            request.text,
            request.referenceAudioPath!,
            referenceText: request.referenceText,
            context: request.context,
          );
        } else {
          await speak(request.text, context: request.context);
        }
        request.completer.complete();
      } catch (e) {
        request.completer.completeError(e);
      }
    }
    
    _isProcessingQueue = false;
  }

  // Modified speak method to support priority queue
  Future<void> speak(
    String text, {
    SpeechPriority priority = SpeechPriority.normal,
    String? context,
    String? voiceId,
  }) async {
    if (!_isInitialized) {
      await _initTTS();
    }

    if (_isSpeaking) {
      await stop();
    }

    try {
      _isSpeaking = true;
      await _initialize();

      // Convert SpeechPriority from interface to voice service
      voice.SpeechPriority voicePriority;
      switch (priority) {
        case SpeechPriority.low:
          voicePriority = voice.SpeechPriority.low;
          break;
        case SpeechPriority.high:
          voicePriority = voice.SpeechPriority.high;
          break;
        case SpeechPriority.normal:
        default:
          voicePriority = voice.SpeechPriority.normal;
          break;
      }

      // Try to use voice cloning first
      try {
        await _voiceService.speak(
          text,
          priority: voicePriority,
          context: context,
          voiceId: voiceId,
        );
      } catch (e) {
        // Fall back to system TTS if voice cloning fails
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('Error speaking: $e');
    } finally {
      _isSpeaking = false;
    }
  }

  // New method to speak with reference audio (voice cloning)
  Future<void> _speakWithReferenceAudio(
    String text,
    String referenceAudioPath, {
    String? referenceText,
    String? context,
  }) async {
    if (!_isF5TTSAvailable) {
      await _fallbackSpeak(text, context: context);
      return;
    }

    try {
      final voiceConfig = _voices[context ?? _currentVoice ?? 'default'] ?? _voices['default']!;
      final style = _getStyleForContext(context);
      
      final client = http.Client();
      try {
        // Read reference audio file as bytes
        final referenceFile = File(referenceAudioPath);
        if (!await referenceFile.exists()) {
          throw Exception('Reference audio file not found');
        }
        
        final referenceBytes = await referenceFile.readAsBytes();
        final referenceBase64 = 'data:audio/wav;base64,${base64Encode(referenceBytes)}';
        
        final response = await client.post(
          Uri.parse('${_config.baseUrl}/run/predict'),
          headers: _config.headers,
          body: jsonEncode({
            'data': [
              text,                     // Input text
              voiceConfig['style_text'],// Style text
              style['speaking_rate'],   // Speed
              style['clarity'],         // Clarity
              voiceConfig['emotion'],   // Emotion
              style['expressiveness'],  // Expressiveness
              voiceConfig['language'],  // Language
              true,                     // Use reference audio
              referenceBase64,          // Reference audio
              referenceText ?? '',      // Reference text
            ]
          }),
        ).timeout(Duration(seconds: _config.timeoutSeconds * 2)); // Double timeout for voice cloning

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final audioBase64 = responseData['data'][0];
          
          // Convert base64 to bytes and save to file
          final bytes = base64Decode(audioBase64.split(',')[1]);
          final audioFile = await _saveAudioFile(bytes, text, voiceConfig, style);
          
          await _playAudioFile(audioFile);
        } else {
          debugPrint('Voice cloning request failed: ${response.statusCode}');
          await _fallbackSpeak(text, context: context);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Voice cloning error: $e');
      await _fallbackSpeak(text, context: context);
    }
  }
  
  // New method to create and save a cloned voice
  Future<bool> createClonedVoice(
    String voiceId,
    String referenceAudioPath, {
    String? referenceText,
    String? name,
    String? description,
  }) async {
    if (!_isF5TTSAvailable) {
      return false;
    }
    
    try {
      // Read reference audio file as bytes
      final referenceFile = File(referenceAudioPath);
      if (!await referenceFile.exists()) {
        throw Exception('Reference audio file not found');
      }
      
      // Create a copy of the reference audio in the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final voicesDir = Directory('${appDir.path}/cloned_voices');
      if (!await voicesDir.exists()) {
        await voicesDir.create(recursive: true);
      }
      
      final fileName = '${voiceId}_${DateTime.now().millisecondsSinceEpoch}.wav';
      final savedPath = '${voicesDir.path}/$fileName';
      await referenceFile.copy(savedPath);
      
      // Save voice metadata
      _clonedVoices[voiceId] = {
        'name': name ?? voiceId,
        'description': description ?? 'Cloned voice',
        'referenceAudioPath': savedPath,
        'referenceText': referenceText ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      await _saveClonedVoices();
      return true;
    } catch (e) {
      debugPrint('Error creating cloned voice: $e');
      return false;
    }
  }
  
  // Method to speak with a cloned voice
  Future<void> _speakWithClonedVoice(String text, String voiceId) async {
    final voiceData = _clonedVoices[voiceId];
    if (voiceData == null) {
      await _fallbackSpeak(text);
      return;
    }
    
    await _speakWithReferenceAudio(
      text,
      voiceData['referenceAudioPath'],
      referenceText: voiceData['referenceText'],
    );
  }
  
  // Delete a cloned voice
  Future<bool> deleteClonedVoice(String voiceId) async {
    if (!_clonedVoices.containsKey(voiceId)) {
      return false;
    }
    
    try {
      final voiceData = _clonedVoices[voiceId]!;
      final audioPath = voiceData['referenceAudioPath'];
      
      // Delete the reference audio file
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Remove from cloned voices map
      _clonedVoices.remove(voiceId);
      await _saveClonedVoices();
      
      return true;
    } catch (e) {
      debugPrint('Error deleting cloned voice: $e');
      return false;
    }
  }
  
  // Save cloned voices to SharedPreferences
  Future<void> _saveClonedVoices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_cloned_voices', jsonEncode(_clonedVoices));
  }
  
  // Load cloned voices from SharedPreferences
  Future<void> _loadClonedVoices() async {
    final prefs = await SharedPreferences.getInstance();
    final voicesJson = prefs.getString('tts_cloned_voices');
    
    if (voicesJson != null) {
      try {
        final Map<String, dynamic> voices = jsonDecode(voicesJson);
        _clonedVoices.clear();
        
        voices.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            // Verify the reference audio file exists
            final audioPath = value['referenceAudioPath'];
            if (audioPath != null && File(audioPath).existsSync()) {
              _clonedVoices[key] = value;
            }
          }
        });
      } catch (e) {
        debugPrint('Error loading cloned voices: $e');
      }
    }
  }

  Future<void> _playAudioFile(File file) async {
    await _audioPlayer.setFilePath(file.path);
    await _audioPlayer.play();
  }

  Future<File> _saveAudioFile(List<int> bytes, String text, Map<String, dynamic> voiceConfig, Map<String, double> style) async {
    final cacheKey = _generateCacheKey(text, voiceConfig, style);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$cacheKey.wav');
    await file.writeAsBytes(bytes);

    if (_config.enableCache) {
      _audioCache[cacheKey] = file;
      await _cleanCache(); // Ensure cache size is within limits
    }

    return file;
  }

  String _generateCacheKey(String text, Map<String, dynamic> voiceConfig, Map<String, double> style) {
    final data = {
      'text': text,
      'voice': voiceConfig['name'],
      'style': style,
    };
    final jsonStr = jsonEncode(data);
    return sha256.convert(utf8.encode(jsonStr)).toString();
  }

  Future<void> _cleanCache() async {
    if (!_config.enableCache) return;

    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(tempDir.path);
    final files = await cacheDir.list().where((entity) => 
      entity is File && entity.path.endsWith('.wav')
    ).toList();

    // Calculate total size
    int totalSize = 0;
    for (var entity in files) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    // Remove oldest files if cache is too large
    if (totalSize > _config.maxCacheSize * 1024 * 1024) {
      files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      
      for (var entity in files) {
        if (entity is File) {
          final size = await entity.length();
          await entity.delete();
          totalSize -= size;
          
          // Remove from cache map
          _audioCache.removeWhere((key, value) => value.path == entity.path);

          if (totalSize <= _config.maxCacheSize * 1024 * 1024) break;
        }
      }
    }
  }

  Map<String, double> _getStyleForContext(String? context) {
    switch (context) {
      case 'math':
        return {
          'speaking_rate': 0.9,
          'clarity': 1.2,
          'expressiveness': 0.8,
        };
      case 'language':
        return {
          'speaking_rate': 0.8,
          'clarity': 1.3,
          'expressiveness': 1.0,
        };
      case 'memory':
        return {
          'speaking_rate': 1.0,
          'clarity': 1.0,
          'expressiveness': 1.2,
        };
      case 'life_skills':
        return {
          'speaking_rate': 0.9,
          'clarity': 1.1,
          'expressiveness': 1.1,
        };
      default:
        return {
          'speaking_rate': 1.0,
          'clarity': 1.0,
          'expressiveness': 1.0,
        };
    }
  }

  Future<void> _fallbackSpeak(String text, {String? context}) async {
    final voiceConfig = context != null ? 
        _voices[context] ?? _voices['default']! : 
        _voices['default']!;
    
    // Apply voice-specific pitch and speed settings
    await _flutterTts.setPitch(voiceConfig['pitch'] ?? 1.0);
    await _flutterTts.setSpeechRate((voiceConfig['speed'] ?? 1.0) * 0.5); // Scale down a bit for Flutter TTS
    
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    _isStreaming = false;
    _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;
    await _audioPlayer.stop();
    await _flutterTts.stop();
    await _voiceService.stop();
  }

  void dispose() {
    _voiceService.dispose();
    _flutterTts.stop();
  }

  Future<void> _loadCustomVoices() async {
    final prefs = await SharedPreferences.getInstance();
    final voicesJson = prefs.getString('custom_voices');
    if (voicesJson != null) {
      final Map<String, dynamic> voices = jsonDecode(voicesJson);
      _customVoicePaths.clear();
      voices.forEach((key, value) {
        if (value is String) {
          _customVoicePaths[key] = value;
        }
      });
    }
  }

  Future<void> addCustomVoice(String name, String path) async {
    _customVoicePaths[name] = path;
    await _saveCustomVoices();
  }

  Future<void> removeCustomVoice(String name) async {
    _customVoicePaths.remove(name);
    await _saveCustomVoices();
  }

  Future<void> _saveCustomVoices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_voices', jsonEncode(_customVoicePaths));
  }

  Future<void> _playCustomVoice(String voiceName, String text) async {
    final voicePath = _customVoicePaths[voiceName];
    if (voicePath == null) return;

    try {
      final file = File(voicePath);
      if (await file.exists()) {
        await _audioPlayer.setFilePath(voicePath);
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error playing custom voice: $e');
      await _fallbackSpeak(text);
    }
  }

  // New method to handle streaming for long text
  Future<void> _streamText(String text, Map<String, dynamic> voiceConfig, Map<String, double> style) async {
    _isStreaming = true;
    
    // Split text into sentences or chunks
    final chunks = _splitTextIntoChunks(text);
    int currentChunk = 0;
    
    // Process chunks sequentially
    Future<void> processNextChunk() async {
      if (currentChunk >= chunks.length || !_isStreaming) {
        _isStreaming = false;
        return;
      }
      
      final chunk = chunks[currentChunk];
      currentChunk++;
      
      try {
        final client = http.Client();
        final response = await client.post(
          Uri.parse('${_config.baseUrl}/run/predict'),
          headers: _config.headers,
          body: jsonEncode({
            'data': [
              chunk,                    // Input text
              voiceConfig['style_text'],// Style text
              style['speaking_rate'],   // Speed
              style['clarity'],         // Clarity
              voiceConfig['emotion'],   // Emotion
              style['expressiveness'],  // Expressiveness
              voiceConfig['language'],  // Language
              false,                    // Use reference audio
              null,                     // Reference audio path
              '',                       // Reference text
            ]
          }),
        ).timeout(Duration(seconds: _config.timeoutSeconds));
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final audioBase64 = responseData['data'][0];
          
          // Convert base64 to bytes and save to file
          final bytes = base64Decode(audioBase64.split(',')[1]);
          final audioFile = await _saveAudioFile(bytes, chunk, voiceConfig, style);
          
          // Play the audio and wait for completion before processing next chunk
          await _audioPlayer.setFilePath(audioFile.path);
          await _audioPlayer.play();
          
          // Wait for audio to complete before processing next chunk
          _audioStreamSubscription = _audioPlayer.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed) {
              _audioStreamSubscription?.cancel();
              _audioStreamSubscription = null;
              processNextChunk();
            }
          });
        } else {
          debugPrint('TTS streaming request failed: ${response.statusCode}');
          await _fallbackSpeak(chunk, context: null);
          processNextChunk();
        }
        client.close();
      } catch (e) {
        debugPrint('TTS streaming error: $e');
        await _fallbackSpeak(chunk, context: null);
        processNextChunk();
      }
    }
    
    // Start processing chunks
    await processNextChunk();
  }
  
  // Helper method to split text into manageable chunks
  List<String> _splitTextIntoChunks(String text, {int maxChunkLength = 200}) {
    List<String> chunks = [];
    
    // Split by sentences first (periods, question marks, exclamation points)
    final sentenceRegex = RegExp(r'[.!?]+');
    final sentences = text.split(sentenceRegex);
    
    String currentChunk = '';
    
    for (var sentence in sentences) {
      sentence = sentence.trim();
      if (sentence.isEmpty) continue;
      
      // Add punctuation back
      sentence += '.';
      
      // If adding this sentence would make the chunk too long, save current chunk and start a new one
      if (currentChunk.length + sentence.length > maxChunkLength && currentChunk.isNotEmpty) {
        chunks.add(currentChunk);
        currentChunk = sentence;
      } else {
        // Otherwise, add to current chunk
        currentChunk += ' ' + sentence;
      }
    }
    
    // Add the last chunk if it's not empty
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks;
  }

  // New methods for voice profile management
  Future<void> updateVoiceProfile(String voiceId, {
    String? name,
    String? styleText,
    String? emotion,
    String? language,
    double? pitch,
    double? speed,
  }) async {
    if (!_voices.containsKey(voiceId)) {
      debugPrint('Voice profile $voiceId not found');
      return;
    }
    
    final voice = _voices[voiceId]!;
    
    if (name != null) voice['name'] = name;
    if (styleText != null) voice['style_text'] = styleText;
    if (emotion != null) voice['emotion'] = emotion;
    if (language != null) voice['language'] = language;
    if (pitch != null) voice['pitch'] = pitch;
    if (speed != null) voice['speed'] = speed;
    
    await _saveVoiceProfiles();
  }
  
  Future<void> _saveVoiceProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_profiles', jsonEncode(_voices));
  }
  
  Future<void> _loadVoiceProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString('tts_voice_profiles');
    
    if (profilesJson != null) {
      try {
        final Map<String, dynamic> profiles = jsonDecode(profilesJson);
        
        // Merge with default profiles, keeping custom settings
        profiles.forEach((key, value) {
          if (_voices.containsKey(key) && value is Map<String, dynamic>) {
            // Update existing voice with saved settings
            final defaultVoice = _voices[key]!;
            value.forEach((setting, val) {
              defaultVoice[setting] = val;
            });
          }
        });
      } catch (e) {
        debugPrint('Error loading voice profiles: $e');
      }
    }
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }
} 