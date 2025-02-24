import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class F5TTSConfig {
  String serverUrl;
  String? apiKey;
  bool useSSL;
  int timeoutSeconds;
  Map<String, String>? customHeaders;
  bool enableCache;
  int maxCacheSize; // in MB

  F5TTSConfig({
    this.serverUrl = 'http://localhost:7860',
    this.apiKey,
    this.useSSL = false,
    this.timeoutSeconds = 10,
    this.customHeaders,
    this.enableCache = true,
    this.maxCacheSize = 100,
  });

  String get baseUrl => '$serverUrl/api/v1';

  Map<String, String> get headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (apiKey != null) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders!);
    }

    return headers;
  }

  // Save configuration to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('f5tts_server_url', serverUrl);
    await prefs.setString('f5tts_api_key', apiKey ?? '');
    await prefs.setBool('f5tts_use_ssl', useSSL);
    await prefs.setInt('f5tts_timeout', timeoutSeconds);
    await prefs.setBool('f5tts_enable_cache', enableCache);
    await prefs.setInt('f5tts_max_cache_size', maxCacheSize);
    if (customHeaders != null) {
      await prefs.setString('f5tts_custom_headers', _encodeMap(customHeaders!));
    }
  }

  // Load configuration from SharedPreferences
  static Future<F5TTSConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return F5TTSConfig(
      serverUrl: prefs.getString('f5tts_server_url') ?? 'http://localhost:7860',
      apiKey: prefs.getString('f5tts_api_key')?.isNotEmpty == true
          ? prefs.getString('f5tts_api_key')
          : null,
      useSSL: prefs.getBool('f5tts_use_ssl') ?? false,
      timeoutSeconds: prefs.getInt('f5tts_timeout') ?? 10,
      customHeaders: _decodeMap(prefs.getString('f5tts_custom_headers')),
      enableCache: prefs.getBool('f5tts_enable_cache') ?? true,
      maxCacheSize: prefs.getInt('f5tts_max_cache_size') ?? 100,
    );
  }

  // Helper methods for encoding/decoding Map to/from String
  static String _encodeMap(Map<String, String> map) => json.encode(map);
  static Map<String, String>? _decodeMap(String? jsonString) {
    if (jsonString == null) return null;
    final Map<String, dynamic> decoded = json.decode(jsonString);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  // Create a copy of the configuration with updated values
  F5TTSConfig copyWith({
    String? serverUrl,
    String? apiKey,
    bool? useSSL,
    int? timeoutSeconds,
    Map<String, String>? customHeaders,
    bool? enableCache,
    int? maxCacheSize,
  }) {
    return F5TTSConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      apiKey: apiKey ?? this.apiKey,
      useSSL: useSSL ?? this.useSSL,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      customHeaders: customHeaders ?? this.customHeaders,
      enableCache: enableCache ?? this.enableCache,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
    );
  }
} 