import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'configuration_service.dart';

/// Custom AssetLoader that loads translations from local assets
/// and overrides them with values from Supabase (ConfigurationService).
class SupabaseTranslationLoader extends AssetLoader {
  final String basePath;

  const SupabaseTranslationLoader({this.basePath = 'assets/translations'});

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    // 1. Load local asset file (e.g. assets/translations/it.json)
    // Reconstruct path logic similar to RootBundleAssetLoader
    final assetPath = '$basePath/${locale.languageCode}.json';
    
    Map<String, dynamic> localTranslations = {};
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      localTranslations = json.decode(jsonString);
    } catch (e) {
      // If local file missing, start empty
      localTranslations = {};
    }

    // 2. Load remote config
    // We assume ConfigurationService is already initialized in SplashScreen/Main
    final remoteConfig = ConfigurationService().getAll();
    
    // 3. Merge Remote Config into Local Translations
    // Remote keys are flattened "group.key" (e.g. "auth.login_title")
    // Local keys are nested maps (e.g. {"auth": {"login_title": "..."}})
    // We need to apply flattened keys to the nested map.
    
    final Map<String, dynamic> mergedTranslations = Map.from(localTranslations);

    remoteConfig.forEach((key, value) {
      _applyFlattenedKey(mergedTranslations, key, value);
    });

    return mergedTranslations;
  }

  void _applyFlattenedKey(Map<String, dynamic> map, String key, String value) {
    final parts = key.split('.');
    
    // Safety check: key must have at least one part
    if (parts.isEmpty) return;

    // Traverse the map
    Map<String, dynamic> current = map;
    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (current[part] is! Map) {
        // If path doesn't exist or isn't a map, create/overwrite it
        // BUT be careful not to overwrite a leaf node if the structure is mixed (unlikely in valid i18n)
        // For now, assume if it's not a map, we can overwrite it to be a map
        // unless it's the leaf, but we are in loop < length -1 so it's intermediate.
        current[part] = <String, dynamic>{};
      }
      current = current[part] as Map<String, dynamic>;
    }
    
    // Set the value at leaf
    current[parts.last] = value;
  }
}
