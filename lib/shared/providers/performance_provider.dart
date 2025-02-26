import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/performance_service.dart';

class PerformanceProvider extends ChangeNotifier {
  final PerformanceService _performanceService = PerformanceService();
  
  PerformanceProvider();
  
  /// Get the performance service instance
  PerformanceService get service => _performanceService;
  
  /// Run a computation in an isolate
  Future<dynamic> runComputation(String functionName, dynamic args) {
    return _performanceService.runComputation(functionName, args);
  }
  
  /// Get a cached asset
  Future<Uint8List?> getCachedAsset(String assetPath) {
    return _performanceService.getCachedAsset(assetPath);
  }
  
  /// Get a lazy loaded screen
  Widget getLazyLoadedScreen(String screenKey, Widget Function() builder) {
    return _performanceService.getLazyLoadedScreen(screenKey, builder);
  }
  
  /// Clear a lazy loaded screen from cache
  void clearLazyLoadedScreen(String screenKey) {
    _performanceService.clearLazyLoadedScreen(screenKey);
  }
  
  /// Add an audio file to the cache
  Future<void> addAudioToCache(String key, File file) {
    return _performanceService.addAudioToCache(key, file);
  }
  
  /// Get an audio file from the cache
  File? getAudioFromCache(String key) {
    return _performanceService.getAudioFromCache(key);
  }
  
  /// Start the frame budget system for animations
  void startAnimationFrameBudget() {
    _performanceService.startAnimationFrameBudget();
  }
  
  /// Stop the frame budget system
  void stopAnimationFrameBudget() {
    _performanceService.stopAnimationFrameBudget();
  }
  
  /// Add a callback to be executed within the frame budget
  void addAnimationCallback(VoidCallback callback) {
    _performanceService.addAnimationCallback(callback);
  }
  
  /// Remove a callback from the animation frame budget
  void removeAnimationCallback(VoidCallback callback) {
    _performanceService.removeAnimationCallback(callback);
  }
} 