import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';

abstract class BaseRepository {
  final String storageKey;
  
  BaseRepository(this.storageKey);
  
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  // Save data to local storage
  Future<bool> saveData(String key, dynamic data) async {
    final storage = await prefs;
    if (data is String) {
      return storage.setString('${storageKey}_$key', data);
    } else if (data is int) {
      return storage.setInt('${storageKey}_$key', data);
    } else if (data is double) {
      return storage.setDouble('${storageKey}_$key', data);
    } else if (data is bool) {
      return storage.setBool('${storageKey}_$key', data);
    } else if (data is List<String>) {
      return storage.setStringList('${storageKey}_$key', data);
    }
    throw Exception('Unsupported data type');
  }
  
  // Load data from local storage
  Future<T?> loadData<T>(String key) async {
    final storage = await prefs;
    final fullKey = '${storageKey}_$key';
    
    if (T == String) {
      return storage.getString(fullKey) as T?;
    } else if (T == int) {
      return storage.getInt(fullKey) as T?;
    } else if (T == double) {
      return storage.getDouble(fullKey) as T?;
    } else if (T == bool) {
      return storage.getBool(fullKey) as T?;
    } else if (T == List<String>) {
      return storage.getStringList(fullKey) as T?;
    }
    throw Exception('Unsupported data type');
  }
  
  // Remove data from local storage
  Future<bool> removeData(String key) async {
    final storage = await prefs;
    return storage.remove('${storageKey}_$key');
  }
  
  // Clear all data for this repository
  Future<void> clearAll() async {
    final storage = await prefs;
    final keys = storage.getKeys();
    for (final key in keys) {
      if (key.startsWith('${storageKey}_')) {
        await storage.remove(key);
      }
    }
  }
  
  // Handle API errors
  String handleError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return AppConstants.errorNetwork;
    } else if (error.toString().contains('Unauthorized')) {
      return AppConstants.errorAuth;
    } else if (error.toString().contains('Permission')) {
      return AppConstants.errorPermission;
    }
    return AppConstants.errorGeneric;
  }
  
  // Retry mechanism for API calls
  Future<T> retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < AppConstants.maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= AppConstants.maxRetries) {
          throw Exception(handleError(e));
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    throw Exception(AppConstants.errorGeneric);
  }
} 