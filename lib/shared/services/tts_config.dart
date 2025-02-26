import 'package:shared_preferences/shared_preferences.dart';

class F5TTSConfig {
  String language;
  double pitch;
  double rate;
  double volume;
  bool useCustomVoice;
  String baseUrl;
  Map<String, String> headers;
  int timeoutSeconds;
  bool enableCache;
  int maxCacheSize;

  F5TTSConfig({
    this.language = 'en-US',
    this.pitch = 1.0,
    this.rate = 0.5,
    this.volume = 1.0,
    this.useCustomVoice = false,
    this.baseUrl = 'https://api.f5tts.com',
    this.headers = const {'Content-Type': 'application/json'},
    this.timeoutSeconds = 30,
    this.enableCache = true,
    this.maxCacheSize = 100, // in MB
  });

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_language', language);
    await prefs.setDouble('tts_pitch', pitch);
    await prefs.setDouble('tts_rate', rate);
    await prefs.setDouble('tts_volume', volume);
    await prefs.setBool('tts_use_custom_voice', useCustomVoice);
    await prefs.setString('tts_base_url', baseUrl);
    await prefs.setBool('tts_enable_cache', enableCache);
    await prefs.setInt('tts_max_cache_size', maxCacheSize);
    await prefs.setInt('tts_timeout_seconds', timeoutSeconds);
  }

  static Future<F5TTSConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return F5TTSConfig(
      language: prefs.getString('tts_language') ?? 'en-US',
      pitch: prefs.getDouble('tts_pitch') ?? 1.0,
      rate: prefs.getDouble('tts_rate') ?? 0.5,
      volume: prefs.getDouble('tts_volume') ?? 1.0,
      useCustomVoice: prefs.getBool('tts_use_custom_voice') ?? false,
      baseUrl: prefs.getString('tts_base_url') ?? 'https://api.f5tts.com',
      enableCache: prefs.getBool('tts_enable_cache') ?? true,
      maxCacheSize: prefs.getInt('tts_max_cache_size') ?? 100,
      timeoutSeconds: prefs.getInt('tts_timeout_seconds') ?? 30,
    );
  }
} 