import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_config.dart';

/// Service to handle AI System Prompt fetching and interpolation
class PromptService {
  static final PromptService _instance = PromptService._internal();
  factory PromptService() => _instance;
  PromptService._internal();

  final Map<String, String> _cache = {};
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Get a prompt by key, either from cache, cloud, or local fallback
  Future<String> getPrompt(String key, [Map<String, dynamic>? params]) async {
    String template = _cache[key] ?? AIConfig.defaultPrompts[key] ?? '';

    // Lazily refresh cache if expired or missing
    if (_cache.isEmpty || _shouldRefresh()) {
      await _refreshPrompts();
      if (_cache.containsKey(key)) {
        template = _cache[key]!;
      }
    }

    // If still empty (fetch failed and no default), return empty string
    if (template.isEmpty) return '';

    return _interpolate(template, params);
  }

  bool _shouldRefresh() {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheDuration;
  }

  Future<void> _refreshPrompts() async {
    try {
      final response = await Supabase.instance.client
          .from(AIConfig.tableSystemPrompts)
          .select('key, template');
      
      for (var row in response) {
        _cache[row['key']] = row['template'];
      }
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('PromptService: Failed to fetch prompts from Supabase: $e');
      // Keep using existing cache or defaults
    }
  }

  /// Replace placeholders {{key}} with values from params
  String _interpolate(String template, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return template;

    String result = template;
    params.forEach((key, value) {
      final placeholder = '{{$key}}';
      result = result.replaceAll(placeholder, value.toString());
    });
    return result;
  }
  
  /// Force refresh (useful for debug or manual sync)
  Future<void> forceRefresh() => _refreshPrompts();
}
