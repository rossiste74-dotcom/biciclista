import 'package:flutter_test/flutter_test.dart';
import 'package:biciclistico/models/clothing_item.dart';
import 'package:biciclistico/models/weather_conditions.dart';
import 'package:biciclistico/services/outfit_service.dart';

void main() {
  late OutfitService outfitService;

  setUp(() {
    outfitService = OutfitService();
  });

  group('OutfitService - Temperature Ranges', () {
    test('Hot weather (>20°C) suggests summer kit', () {
      final weather = WeatherConditions(temperature: 25, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.summerKit));
      expect(suggestion.adjustedTemperature, 25);
    });

    test('Warm weather (15-20°C) suggests summer kit', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.summerKit));
    });

    test('Cool weather (10-15°C) suggests long sleeves', () {
      final weather = WeatherConditions(temperature: 12, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.longSleeveJersey));
      expect(suggestion.recommendedItems, contains(ClothingItem.armWarmers));
    });

    test('Cold weather (5-10°C) suggests light jacket and leg warmers', () {
      final weather = WeatherConditions(temperature: 7, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.lightJacket));
      expect(suggestion.recommendedItems, contains(ClothingItem.legWarmers));
      expect(suggestion.recommendedItems, contains(ClothingItem.baseLayer));
    });

    test('Very cold weather (<5°C) suggests full winter gear', () {
      final weather = WeatherConditions(temperature: 2, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.winterJacket));
      expect(suggestion.recommendedItems, contains(ClothingItem.thermalGloves));
      expect(suggestion.recommendedItems, contains(ClothingItem.shoeCovers));
      expect(suggestion.recommendedItems, contains(ClothingItem.neckWarmer));
    });
  });

  group('OutfitService - Thermal Sensitivity', () {
    test('Cold-sensitive rider (sensitivity=5) gets warmer clothes at 12°C', () {
      final weather = WeatherConditions(temperature: 12, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 5,
      );

      // 12°C - 3°C = 9°C adjusted, should get jacket
      expect(suggestion.adjustedTemperature, 9);
      expect(suggestion.recommendedItems, contains(ClothingItem.lightJacket));
    });

    test('Cold-resistant rider (sensitivity=1) gets lighter clothes at 12°C', () {
      final weather = WeatherConditions(temperature: 12, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 1,
      );

      // 12°C + 3°C = 15°C adjusted, should get summer kit
      expect(suggestion.adjustedTemperature, 15);
      expect(suggestion.recommendedItems, contains(ClothingItem.summerKit));
    });

    test('Average rider (sensitivity=3) gets no adjustment', () {
      final weather = WeatherConditions(temperature: 12, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.adjustedTemperature, 12);
    });

    test('Throws error for invalid thermal sensitivity', () {
      final weather = WeatherConditions(temperature: 12, windSpeed: 5);

      expect(
        () => outfitService.suggestOutfit(
          weather: weather,
          thermalSensitivity: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => outfitService.suggestOutfit(
          weather: weather,
          thermalSensitivity: 6,
        ),
        throwsArgumentError,
      );
    });
  });

  group('OutfitService - Wind Protection', () {
    test('Moderate wind (>20 km/h) adds vest', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 25);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.vest));
    });

    test('Strong wind (>30 km/h) adds windbreaker', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 35);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.windbreaker));
    });

    test('Rainy conditions add windbreaker', () {
      final weather = WeatherConditions(
        temperature: 18,
        windSpeed: 10,
        precipitation: 0.8,
      );
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.windbreaker));
    });
  });

  group('OutfitService - Elevation', () {
    test('High elevation (>500m) adds windbreaker', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
        elevationGain: 650,
      );

      expect(suggestion.recommendedItems, contains(ClothingItem.windbreaker));
      expect(suggestion.reasoning, contains('climbing'));
    });

    test('Low elevation (<500m) does not force windbreaker', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
        elevationGain: 300,
      );

      expect(suggestion.recommendedItems, isNot(contains(ClothingItem.windbreaker)));
    });

    test('Exactly 500m elevation does not add windbreaker', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
        elevationGain: 500,
      );

      expect(suggestion.recommendedItems, isNot(contains(ClothingItem.windbreaker)));
    });
  });

  group('OutfitService - Reasoning', () {
    test('Reasoning includes thermal sensitivity adjustment', () {
      final weather = WeatherConditions(temperature: 12, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 5,
      );

      expect(suggestion.reasoning, contains('feel colder'));
    });

    test('Reasoning includes wind information', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 25);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
      );

      expect(suggestion.reasoning, contains('wind'));
    });

    test('Reasoning includes elevation information', () {
      final weather = WeatherConditions(temperature: 18, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 3,
        elevationGain: 700,
      );

      expect(suggestion.reasoning, contains('climbing'));
      expect(suggestion.reasoning, contains('700m'));
    });
  });

  group('OutfitService - Edge Cases', () {
    test('Extreme cold (-10°C) with high sensitivity', () {
      final weather = WeatherConditions(temperature: -10, windSpeed: 15);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 5,
      );

      // -10°C - 3°C = -13°C adjusted
      expect(suggestion.adjustedTemperature, -13);
      expect(suggestion.recommendedItems, contains(ClothingItem.winterJacket));
      expect(suggestion.recommendedItems, contains(ClothingItem.thermalGloves));
    });

    test('Extreme heat (35°C) with low sensitivity', () {
      final weather = WeatherConditions(temperature: 35, windSpeed: 5);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 1,
      );

      // 35°C + 3°C = 38°C adjusted
      expect(suggestion.adjustedTemperature, 38);
      expect(suggestion.recommendedItems, contains(ClothingItem.summerKit));
    });

    test('Combined factors: cold, windy, high elevation', () {
      final weather = WeatherConditions(temperature: 8, windSpeed: 35);
      final suggestion = outfitService.suggestOutfit(
        weather: weather,
        thermalSensitivity: 4,
        elevationGain: 800,
      );

      // Should have jacket, windbreaker, and leg warmers
      expect(suggestion.recommendedItems, contains(ClothingItem.lightJacket));
      expect(suggestion.recommendedItems, contains(ClothingItem.windbreaker));
      expect(suggestion.recommendedItems, contains(ClothingItem.legWarmers));
    });
  });
}
