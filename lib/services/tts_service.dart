import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_config.dart';
import 'package:crypto/crypto.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  
  late final AudioPlayer _audioPlayer;
  late final FlutterTts _flutterTts;
  bool _isF5TTSAvailable = true;
  F5TTSConfig _config = F5TTSConfig();  // Initialize with default values
  final Map<String, File> _audioCache = {};
  final Map<String, String> _customVoicePaths = {};

  TTSService._internal() {
    _audioPlayer = AudioPlayer();
    _flutterTts = FlutterTts();
    _setupFlutterTts();
    _initTTS(); // Start async initialization
    _loadCustomVoices();
  }

  String? _currentVoice;
  Map<String, Map<String, dynamic>> _voices = {
    'default': {
      'name': 'cheerful',
      'style_text': 'cheerful and friendly, speaking clearly and naturally',
      'emotion': 'happy',
      'language': 'en',
    },
    'math': {
      'name': 'teacher',
      'style_text': 'patient and clear teaching style, explaining concepts step by step',
      'emotion': 'confident',
      'language': 'en',
    },
    'language': {
      'name': 'friendly',
      'style_text': 'encouraging and supportive, speaking slowly and clearly for language learning',
      'emotion': 'happy',
      'language': 'en',
    },
    'memory': {
      'name': 'encouraging',
      'style_text': 'enthusiastic and motivating, speaking with clear emphasis on important words',
      'emotion': 'excited',
      'language': 'en',
    },
    'life_skills': {
      'name': 'supportive',
      'style_text': 'gentle and patient guidance, speaking in a calm and reassuring manner',
      'emotion': 'calm',
      'language': 'en',
    },
  };

  Future<void> _setupFlutterTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _initTTS() async {
    // Load configuration
    await updateConfig(_config);
    
    final prefs = await SharedPreferences.getInstance();
    _currentVoice = prefs.getString('tts_voice') ?? 'default';
    
    // Test F5-TTS availability
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('${_config.baseUrl}/health'),
        headers: _config.headers,
      ).timeout(Duration(seconds: _config.timeoutSeconds));
      
      _isF5TTSAvailable = response.statusCode == 200;
      client.close();
    } catch (e) {
      _isF5TTSAvailable = false;
      debugPrint('F5-TTS not available: $e');
    }

    // Clean old cache files if cache is enabled
    if (_config.enableCache) {
      await _cleanCache();
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

  Future<void> speak(String text, {String? context}) async {
    if (!_isF5TTSAvailable) {
      await _fallbackSpeak(text);
      return;
    }

    try {
      // Check if it's a custom voice
      if (context != null && _customVoicePaths.containsKey(context)) {
        await _playCustomVoice(context, text);
        return;
      }

      final voiceConfig = _voices[context ?? _currentVoice ?? 'default'] ?? _voices['default']!;
      final style = _getStyleForContext(context);

      // Check cache first if enabled
      if (_config.enableCache) {
        final cacheKey = _generateCacheKey(text, voiceConfig, style);
        final cachedFile = _audioCache[cacheKey];
        if (cachedFile != null && await cachedFile.exists()) {
          await _playAudioFile(cachedFile);
          return;
        }
      }
      
      final client = http.Client();
      try {
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
          final audioFile = await _saveAudioFile(bytes, text, voiceConfig, style);
          
          await _playAudioFile(audioFile);
        } else {
          debugPrint('TTS request failed: ${response.statusCode}');
          await _fallbackSpeak(text);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('TTS error: $e');
      await _fallbackSpeak(text);
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

  Future<void> _fallbackSpeak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _cleanCache();
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
} 