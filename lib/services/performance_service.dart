import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that handles various performance optimizations for the app
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;

  PerformanceService._internal();

  // Cached assets
  final Map<String, Uint8List> _cachedAssets = {};
  
  // Lazy loaded screens
  final Map<String, Widget> _lazyLoadedScreens = {};
  
  // Audio cache management
  final Map<String, File> _audioCacheFiles = {};
  int _audioCacheSize = 0;
  final int _maxAudioCacheSize = 50 * 1024 * 1024; // 50 MB
  
  // Isolate for heavy computations
  Isolate? _computeIsolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  final Map<int, Completer<dynamic>> _pendingComputations = {};
  int _nextComputationId = 0;
  
  // Frame budget system
  final Stopwatch _frameStopwatch = Stopwatch();
  final double _targetFrameTime = 1000 / 60; // 16.67ms for 60fps
  bool _isAnimating = false;
  final List<VoidCallback> _animationCallbacks = [];
  
  // Commonly used assets to pre-cache
  final List<String> _commonAssets = [
    'assets/images/logo.png',
    'assets/images/avatar.png',
    'assets/animations/success.json',
    'assets/animations/loading.json',
    'assets/icons/math.svg',
    'assets/icons/language.svg',
    'assets/icons/memory.svg',
    'assets/icons/life_skills.svg',
  ];

  /// Initialize the performance service
  Future<void> initialize() async {
    await _loadAudioCacheInfo();
    await _preCacheCommonAssets();
    
    // Start frame stopwatch for animation budgeting
    _frameStopwatch.start();
  }

  /// Pre-caches commonly used assets for faster loading
  Future<void> _preCacheCommonAssets() async {
    for (final assetPath in _commonAssets) {
      try {
        if (assetPath.endsWith('.png') || assetPath.endsWith('.jpg') || assetPath.endsWith('.jpeg')) {
          // Pre-cache images
          final data = await rootBundle.load(assetPath);
          _cachedAssets[assetPath] = data.buffer.asUint8List();
          debugPrint('Pre-cached asset: $assetPath');
        }
      } catch (e) {
        debugPrint('Failed to pre-cache asset: $assetPath - $e');
      }
    }
  }

  /// Gets a pre-cached asset as bytes
  Future<Uint8List?> getCachedAsset(String assetPath) async {
    if (_cachedAssets.containsKey(assetPath)) {
      return _cachedAssets[assetPath];
    }
    
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      _cachedAssets[assetPath] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Failed to load asset: $assetPath - $e');
      return null;
    }
  }

  /// Lazy loads a screen and caches it for future use
  Widget getLazyLoadedScreen(String screenKey, Widget Function() builder) {
    if (_lazyLoadedScreens.containsKey(screenKey)) {
      return _lazyLoadedScreens[screenKey]!;
    }
    
    final screen = builder();
    _lazyLoadedScreens[screenKey] = screen;
    return screen;
  }

  /// Clears a lazy loaded screen from cache
  void clearLazyLoadedScreen(String screenKey) {
    _lazyLoadedScreens.remove(screenKey);
  }

  /// Adds an audio file to the cache
  Future<void> addAudioToCache(String key, File file) async {
    final fileSize = await file.length();
    
    // Check if adding this file would exceed the cache limit
    if (_audioCacheSize + fileSize > _maxAudioCacheSize) {
      await _cleanAudioCache(fileSize);
    }
    
    _audioCacheFiles[key] = file;
    _audioCacheSize += fileSize;
    await _saveAudioCacheInfo();
  }

  /// Gets an audio file from the cache
  File? getAudioFromCache(String key) {
    return _audioCacheFiles[key];
  }

  /// Cleans the audio cache to make room for new files
  Future<void> _cleanAudioCache(int requiredSpace) async {
    // Sort files by last modified time (oldest first)
    final entries = _audioCacheFiles.entries.toList()
      ..sort((a, b) => a.value.lastModifiedSync().compareTo(b.value.lastModifiedSync()));
    
    int freedSpace = 0;
    final keysToRemove = <String>[];
    
    for (final entry in entries) {
      if (_audioCacheSize - freedSpace <= _maxAudioCacheSize - requiredSpace) {
        break;
      }
      
      final fileSize = await entry.value.length();
      freedSpace += fileSize;
      keysToRemove.add(entry.key);
      
      try {
        await entry.value.delete();
      } catch (e) {
        debugPrint('Failed to delete audio cache file: ${entry.value.path} - $e');
      }
    }
    
    for (final key in keysToRemove) {
      _audioCacheFiles.remove(key);
    }
    
    _audioCacheSize -= freedSpace;
    await _saveAudioCacheInfo();
  }

  /// Saves audio cache information to SharedPreferences
  Future<void> _saveAudioCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audio_cache_size', _audioCacheSize);
    
    final cacheInfo = <String, String>{};
    for (final entry in _audioCacheFiles.entries) {
      cacheInfo[entry.key] = entry.value.path;
    }
    
    await prefs.setString('audio_cache_files', cacheInfo.toString());
  }

  /// Loads audio cache information from SharedPreferences
  Future<void> _loadAudioCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _audioCacheSize = prefs.getInt('audio_cache_size') ?? 0;
    
    final cacheInfoStr = prefs.getString('audio_cache_files');
    if (cacheInfoStr != null) {
      try {
        // Simple parsing of the string representation of the map
        final cacheInfo = <String, String>{};
        final entriesStr = cacheInfoStr.substring(1, cacheInfoStr.length - 1).split(', ');
        
        for (final entryStr in entriesStr) {
          final parts = entryStr.split(': ');
          if (parts.length == 2) {
            cacheInfo[parts[0].trim()] = parts[1].trim();
          }
        }
        
        for (final entry in cacheInfo.entries) {
          final file = File(entry.value);
          if (await file.exists()) {
            _audioCacheFiles[entry.key] = file;
          } else {
            // File doesn't exist, reduce cache size
            final fileSize = prefs.getInt('audio_cache_file_size_${entry.key}') ?? 0;
            _audioCacheSize -= fileSize;
          }
        }
      } catch (e) {
        debugPrint('Failed to parse audio cache info: $e');
      }
    }
  }

  /// Initializes the compute isolate for heavy computations
  Future<void> _initializeComputeIsolate() async {
    _receivePort = ReceivePort();
    
    _computeIsolate = await Isolate.spawn(
      _isolateEntryPoint,
      _receivePort!.sendPort,
    );
    
    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else if (message is Map<String, dynamic>) {
        final id = message['id'] as int;
        final result = message['result'];
        final error = message['error'];
        
        final completer = _pendingComputations[id];
        if (completer != null) {
          if (error != null) {
            completer.completeError(error);
          } else {
            completer.complete(result);
          }
          _pendingComputations.remove(id);
        }
      }
    });
  }

  /// Entry point for the compute isolate
  static void _isolateEntryPoint(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is Map<String, dynamic>) {
        final id = message['id'] as int;
        final functionName = message['function'] as String;
        final args = message['args'];
        
        try {
          dynamic result;
          
          switch (functionName) {
            case 'generateWordProblem':
              result = _generateWordProblem(args);
              break;
            case 'processImageData':
              result = _processImageData(args);
              break;
            // Add more functions as needed
            default:
              throw Exception('Unknown function: $functionName');
          }
          
          sendPort.send({
            'id': id,
            'result': result,
          });
        } catch (e) {
          sendPort.send({
            'id': id,
            'error': e.toString(),
          });
        }
      }
    });
  }

  /// Example of a heavy computation: generating a word problem
  static Map<String, dynamic> _generateWordProblem(Map<String, dynamic> args) {
    final difficulty = args['difficulty'] as String;
    final operationType = args['operationType'] as String;
    
    // This would be a more complex algorithm in a real app
    final problem = _generateProblemText(difficulty, operationType);
    final solution = _generateSolutionSteps(problem, operationType);
    
    return {
      'problem': problem,
      'solution': solution,
    };
  }

  /// Example of a heavy computation: processing image data
  static Uint8List _processImageData(Map<String, dynamic> args) {
    final imageData = args['imageData'] as Uint8List;
    final width = args['width'] as int;
    final height = args['height'] as int;
    
    // This would be a more complex image processing algorithm in a real app
    // For now, we'll just return the original data
    return imageData;
  }

  /// Helper method to generate problem text
  static String _generateProblemText(String difficulty, String operationType) {
    // In a real app, this would generate more varied and appropriate problems
    switch (operationType) {
      case 'addition':
        return 'John has 5 apples. Sarah gives him 3 more apples. How many apples does John have now?';
      case 'subtraction':
        return 'Mary has 8 candies. She gives 3 candies to her friend. How many candies does Mary have left?';
      case 'multiplication':
        return 'There are 4 baskets with 3 oranges in each basket. How many oranges are there in total?';
      case 'division':
        return 'Tom has 12 stickers. He wants to give them equally to 3 friends. How many stickers will each friend get?';
      default:
        return 'Solve the following problem.';
    }
  }

  /// Helper method to generate solution steps
  static List<String> _generateSolutionSteps(String problem, String operationType) {
    // In a real app, this would generate actual solution steps based on the problem
    switch (operationType) {
      case 'addition':
        return [
          'First, identify what we know: John has 5 apples initially.',
          'Then, Sarah gives him 3 more apples.',
          'To find the total, we add: 5 + 3 = 8',
          'Therefore, John has 8 apples in total.'
        ];
      case 'subtraction':
        return [
          'First, identify what we know: Mary has 8 candies initially.',
          'Then, she gives away 3 candies.',
          'To find how many are left, we subtract: 8 - 3 = 5',
          'Therefore, Mary has 5 candies left.'
        ];
      case 'multiplication':
        return [
          'First, identify what we know: There are 4 baskets with 3 oranges in each.',
          'To find the total number of oranges, we multiply: 4 × 3 = 12',
          'Therefore, there are 12 oranges in total.'
        ];
      case 'division':
        return [
          'First, identify what we know: Tom has 12 stickers to distribute equally among 3 friends.',
          'To find how many each friend gets, we divide: 12 ÷ 3 = 4',
          'Therefore, each friend will get 4 stickers.'
        ];
      default:
        return ['Solve step by step.'];
    }
  }

  /// Runs a heavy computation in the isolate
  Future<dynamic> runComputation(String functionName, dynamic args) async {
    if (_sendPort == null) {
      await _initializeComputeIsolate();
    }
    
    final id = _nextComputationId++;
    final completer = Completer<dynamic>();
    _pendingComputations[id] = completer;
    
    _sendPort!.send({
      'id': id,
      'function': functionName,
      'args': args,
    });
    
    return completer.future;
  }

  /// Starts the frame budget system for animations
  void startAnimationFrameBudget() {
    if (_isAnimating) return;
    
    _isAnimating = true;
    _frameStopwatch.start();
    _processAnimationFrame();
  }

  /// Stops the frame budget system
  void stopAnimationFrameBudget() {
    _isAnimating = false;
    _frameStopwatch.stop();
    _frameStopwatch.reset();
  }

  /// Adds a callback to be executed within the frame budget
  void addAnimationCallback(VoidCallback callback) {
    _animationCallbacks.add(callback);
    
    if (!_isAnimating) {
      startAnimationFrameBudget();
    }
  }

  /// Removes a callback from the animation frame budget
  void removeAnimationCallback(VoidCallback callback) {
    _animationCallbacks.remove(callback);
    
    if (_animationCallbacks.isEmpty) {
      stopAnimationFrameBudget();
    }
  }

  /// Processes animation frames within the budget
  void _processAnimationFrame() {
    if (!_isAnimating) return;
    
    _frameStopwatch.reset();
    _frameStopwatch.start();
    
    // Execute callbacks within the frame budget
    for (final callback in List.of(_animationCallbacks)) {
      callback();
      
      // Check if we're exceeding the frame budget
      if (_frameStopwatch.elapsedMilliseconds > _targetFrameTime) {
        // Schedule remaining callbacks for the next frame
        break;
      }
    }
    
    _frameStopwatch.stop();
    
    // Schedule the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isAnimating) {
        _processAnimationFrame();
      }
    });
  }

  /// Disposes the performance service
  void dispose() {
    stopAnimationFrameBudget();
    _receivePort?.close();
    _computeIsolate?.kill();
    _computeIsolate = null;
    _receivePort = null;
    _sendPort = null;
    _pendingComputations.clear();
    _cachedAssets.clear();
    _lazyLoadedScreens.clear();
  }
} 