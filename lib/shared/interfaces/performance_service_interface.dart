import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

abstract class IPerformanceService {
  /// Initialize the performance service
  Future<void> initialize();
  
  /// Run a computation in an isolate
  Future<dynamic> runComputation(String functionName, dynamic args);
  
  /// Get a cached asset
  Future<Uint8List?> getCachedAsset(String assetPath);
  
  /// Get a lazy loaded screen
  Widget getLazyLoadedScreen(String screenKey, Widget Function() builder);
  
  /// Clear a lazy loaded screen from cache
  void clearLazyLoadedScreen(String screenKey);
  
  /// Add an audio file to the cache
  Future<void> addAudioToCache(String key, File file);
  
  /// Get an audio file from the cache
  File? getAudioFromCache(String key);
  
  /// Start the frame budget system for animations
  void startAnimationFrameBudget();
  
  /// Stop the frame budget system
  void stopAnimationFrameBudget();
  
  /// Add a callback to be executed within the frame budget
  void addAnimationCallback(VoidCallback callback);
  
  /// Remove a callback from the animation frame budget
  void removeAnimationCallback(VoidCallback callback);
} 