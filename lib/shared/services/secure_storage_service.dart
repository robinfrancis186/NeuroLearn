import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../interfaces/secure_storage_interface.dart';

@LazySingleton(as: ISecureStorage)
class SecureStorageService implements ISecureStorage {
  final FlutterSecureStorage _storage;
  
  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
  
  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
  
  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
} 