import 'clothing_item.dart';

/// Model representing an outfit suggestion with reasoning
class OutfitSuggestion {
  /// List of recommended clothing items
  final List<ClothingItem> recommendedItems;

  /// Explanation of why these items were suggested
  final String reasoning;

  /// Original temperature from weather data
  final double temperature;

  /// Temperature adjusted for user's thermal sensitivity
  final double adjustedTemperature;

  /// Wind speed considered
  final double windSpeed;

  /// Elevation gain considered (if applicable)
  final double? elevationGain;

  const OutfitSuggestion({
    required this.recommendedItems,
    required this.reasoning,
    required this.temperature,
    required this.adjustedTemperature,
    required this.windSpeed,
    this.elevationGain,
  });

  /// Get a summary of recommended items as a comma-separated string
  String get itemsSummary {
    return recommendedItems.map((item) => item.displayName).join(', ');
  }

  @override
  String toString() {
    return 'OutfitSuggestion(${recommendedItems.length} items, temp: $temperature°C → $adjustedTemperature°C)';
  }
}
