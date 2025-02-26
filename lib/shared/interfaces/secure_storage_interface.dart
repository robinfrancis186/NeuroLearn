import 'package:injectable/injectable.dart';

abstract class ISecureStorage {
  /// Read a value from secure storage
  Future<String?> read(String key);
  
  /// Write a value to secure storage
  Future<void> write(String key, String value);
  
  /// Delete a value from secure storage
  Future<void> delete(String key);
  
  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key);
  
  /// Delete all values from secure storage
  Future<void> deleteAll();
} 