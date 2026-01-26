import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class ConfigurationService {
  static final ConfigurationService _instance = ConfigurationService._internal();
  factory ConfigurationService() => _instance;
  ConfigurationService._internal();

  final Map<String, String> _configCache = {};
  bool _isLoaded = false;

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      final response = await SupabaseConfig.client
          .from('app_config')
          .select('key, value');
      
      for (var item in response) {
        _configCache[item['key'] as String] = item['value'] as String;
      }
      _isLoaded = true;
      debugPrint('ConfigurationService: Loaded ${_configCache.length} keys');
    } catch (e) {
      debugPrint('ConfigurationService: Error loading config: $e');
      // Fallback strategies could go here, but strictly relying on local defaults if empty
    }
  }

  /// Get a string value. Returns [defaultValue] if not found in remote config.
  String getString(String key, {String? defaultValue}) {
    return _configCache[key] ?? defaultValue ?? key;
  }

  /// Get all loaded configuration
  Map<String, String> getAll() => _configCache;
}
