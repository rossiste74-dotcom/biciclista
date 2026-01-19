import '../models/clothing_item.dart';
import '../models/weather_conditions.dart';
import '../models/outfit_suggestion.dart';

/// Service for generating cycling outfit suggestions based on weather and user preferences
class OutfitService {
  /// Suggest an outfit based on weather conditions, user thermal sensitivity, and route elevation
  ///
  /// [weather] - Current weather conditions (temperature, wind, etc.)
  /// [thermalSensitivity] - User's thermal sensitivity (1-5 scale)
  ///   - 1 = Very cold-resistant (can handle colder temps)
  ///   - 3 = Average
  ///   - 5 = Very cold-sensitive (needs warmer clothing)
  /// [elevationGain] - Total elevation gain in meters (optional)
  ///
  /// Returns an [OutfitSuggestion] with recommended clothing items and reasoning
  OutfitSuggestion suggestOutfit({
    required WeatherConditions weather,
    required int thermalSensitivity,
    double? elevationGain,
    // Default thresholds for backward compatibility if not provided
    double hotThreshold = 20.0,
    double warmThreshold = 15.0,
    double coolThreshold = 10.0,
    double coldThreshold = 5.0,
    double sensitivityAdjustment = 3.0,
    List<ClothingItem>? hotKit,
    List<ClothingItem>? warmKit,
    List<ClothingItem>? coolKit,
    List<ClothingItem>? coldKit,
    List<ClothingItem>? veryColdKit,
  }) {
    // Validate thermal sensitivity
    if (thermalSensitivity < 1 || thermalSensitivity > 5) {
      throw ArgumentError('Thermal sensitivity must be between 1 and 5');
    }

    // Step 1: Adjust temperature based on thermal sensitivity
    final adjustedTemp = _adjustForThermalSensitivity(
      weather.temperature,
      thermalSensitivity,
      sensitivityAdjustment,
    );

    // Step 2: Get base outfit for the adjusted temperature
    final outfit = _getBaseOutfit(
      adjustedTemp,
      hotThreshold: hotThreshold,
      warmThreshold: warmThreshold,
      coolThreshold: coolThreshold,
      coldThreshold: coldThreshold,
      customHotKit: hotKit,
      customWarmKit: warmKit,
      customCoolKit: coolKit,
      customColdKit: coldKit,
      customVeryColdKit: veryColdKit,
    );

    // Step 3: Add wind protection if needed
    _addWindProtection(outfit, weather);

    // Step 4: Add elevation-specific gear (windbreaker for descents)
    if (elevationGain != null) {
      _addElevationGear(outfit, elevationGain);
    }

    // Step 5: Generate reasoning
    final reasoning = _generateReasoning(
      weather,
      thermalSensitivity,
      adjustedTemp,
      elevationGain,
      hotThreshold: hotThreshold,
      warmThreshold: warmThreshold,
      coolThreshold: coolThreshold,
      coldThreshold: coldThreshold,
    );

    return OutfitSuggestion(
      recommendedItems: outfit,
      reasoning: reasoning,
      temperature: weather.temperature,
      adjustedTemperature: adjustedTemp,
      windSpeed: weather.windSpeed,
      elevationGain: elevationGain,
    );
  }

  /// Adjust temperature based on user's thermal sensitivity
  ///
  /// Sensitivity > 3: Lower thresholds by 3°C (user feels colder)
  /// Sensitivity < 3: Raise thresholds by 3°C (user feels warmer)
  /// Sensitivity = 3: No adjustment (average)
  double _adjustForThermalSensitivity(double temperature, int sensitivity, double adjustmentFactor) {
    if (sensitivity > 3) {
      // Cold-sensitive: subtract adjustmentFactor (makes it feel colder, so warmer clothes)
      return temperature - adjustmentFactor;
    } else if (sensitivity < 3) {
      // Cold-resistant: add adjustmentFactor (makes it feel warmer, so lighter clothes)
      return temperature + adjustmentFactor;
    }
    return temperature; // Average sensitivity, no adjustment
  }

  /// Get base outfit based on adjusted temperature
  List<ClothingItem> _getBaseOutfit(
    double adjustedTemp, {
    required double hotThreshold,
    required double warmThreshold,
    required double coolThreshold,
    required double coldThreshold,
    List<ClothingItem>? customHotKit,
    List<ClothingItem>? customWarmKit,
    List<ClothingItem>? customCoolKit,
    List<ClothingItem>? customColdKit,
    List<ClothingItem>? customVeryColdKit,
  }) {
    final outfit = <ClothingItem>[];

    if (adjustedTemp > hotThreshold) {
      // Hot weather
      outfit.addAll(customHotKit ?? [ClothingItem.summerKit]);
    } else if (adjustedTemp >= warmThreshold) {
      // Warm weather
      outfit.addAll(customWarmKit ?? [ClothingItem.summerKit]);
    } else if (adjustedTemp >= coolThreshold) {
      // Cool weather
      outfit.addAll(customCoolKit ?? [ClothingItem.summerKit, ClothingItem.longSleeveJersey, ClothingItem.armWarmers]);
    } else if (adjustedTemp >= coldThreshold) {
      // Cold weather
      outfit.addAll(customColdKit ?? [ClothingItem.baseLayer, ClothingItem.lightJacket, ClothingItem.legWarmers]);
    } else {
      // Very cold weather
      outfit.addAll(customVeryColdKit ?? [ClothingItem.baseLayer, ClothingItem.winterJacket, ClothingItem.legWarmers, ClothingItem.thermalGloves, ClothingItem.shoeCovers, ClothingItem.neckWarmer]);
    }

    return outfit;
  }

  /// Add wind protection based on wind speed
  ///
  /// Wind > 20 km/h: Add vest/windbreaker
  /// Wind > 30 km/h: Ensure full wind protection
  void _addWindProtection(List<ClothingItem> outfit, WeatherConditions weather) {
    if (weather.isVeryWindy) {
      // Very windy: ensure windbreaker is included
      if (!outfit.contains(ClothingItem.windbreaker)) {
        outfit.add(ClothingItem.windbreaker);
      }
    } else if (weather.isWindy) {
      // Moderately windy: add vest if not already wearing jacket
      final hasJacket = outfit.contains(ClothingItem.lightJacket) ||
          outfit.contains(ClothingItem.winterJacket) ||
          outfit.contains(ClothingItem.windbreaker);
      
      if (!hasJacket && !outfit.contains(ClothingItem.vest)) {
        outfit.add(ClothingItem.vest);
      }
    }

    // Add rain protection if rainy
    if (weather.isRainy && !outfit.contains(ClothingItem.windbreaker)) {
      outfit.add(ClothingItem.windbreaker);
    }
  }

  /// Add elevation-specific gear
  ///
  /// If elevation gain > 500m, always add windbreaker for descents
  void _addElevationGear(List<ClothingItem> outfit, double elevationGain) {
    if (elevationGain > 500 && !outfit.contains(ClothingItem.windbreaker)) {
      outfit.add(ClothingItem.windbreaker);
    }
  }

  /// Generate human-readable reasoning for the outfit suggestion
  String _generateReasoning(
    WeatherConditions weather,
    int thermalSensitivity,
    double adjustedTemp,
    double? elevationGain, {
    required double hotThreshold,
    required double warmThreshold,
    required double coolThreshold,
    required double coldThreshold,
  }) {
    final reasons = <String>[];

    // Temperature reasoning with sarcastic tone
    if (weather.temperature != adjustedTemp) {
      final diff = (weather.temperature - adjustedTemp).abs();
      if (thermalSensitivity > 3) {
        reasons.add(
          'Vedo che sei freddoloso, eh? Ho abbassato i gradi di ${diff.toStringAsFixed(1)}°C per non farti congelare',
        );
      } else if (thermalSensitivity < 3) {
        reasons.add(
          'Si vede che sei tosto col freddo! Ho alzato di ${diff.toStringAsFixed(1)}°C, tanto tu esci anche in canottiera',
        );
      }
    }

    // Base temperature reasoning with cycling jargon
    if (adjustedTemp > hotThreshold) {
      reasons.add('Fa caldo, mica poco! Kit estivo d\'obbligo, sennò ti sciogli come un gelato al sole');
    } else if (adjustedTemp >= warmThreshold) {
      reasons.add('Temperature da ciclista felice - kit estivo e via, che tanto dopo 10 minuti stai sudando');
    } else if (adjustedTemp >= coolThreshold) {
      reasons.add('Freschetto oggi - maniche lunghe e magari i manicotti, che poi in salita li togli');
    } else if (adjustedTemp >= coldThreshold) {
      reasons.add('Fa freddo sul serio - giacca termica e gambali, mica siamo dei kamikaze');
    } else {
      reasons.add('Fa un freddo cane! Abbigliamento invernale completo o te lo scordi di tornare con tutte le dita');
    }

    // Wind reasoning with personality
    if (weather.isVeryWindy) {
      reasons.add('Vento forte da ${weather.windSpeed.toStringAsFixed(0)}km/h - antivento obbligatorio, sennò ti ritrovi a pedalare all\'indietro');
    } else if (weather.isWindy) {
      reasons.add('C\'è venticello (${weather.windSpeed.toStringAsFixed(0)}km/h) - metti il gilet, che in discesa ti geli');
    }

    // Elevation reasoning
    if (elevationGain != null && elevationGain > 500) {
      reasons.add(
        'Con ${elevationGain.toStringAsFixed(0)}m di dislivello l\'antivento te lo metti nello zaino - in salita lo maledici, in discesa lo benedici',
      );
    }

    // Rain reasoning
    if (weather.isRainy) {
      reasons.add('Pioggia in arrivo - impermeabile essenziale, a meno che non ti piaccia sembrare un topo annegato');
    }

    return '${reasons.join('. ')}.';
  }
}
