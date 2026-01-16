import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_conditions.dart';

/// Service for fetching weather forecast data using Open-Meteo API
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetch weather forecast for a specific location and date
  /// 
  /// [lat] - Latitude
  /// [lng] - Longitude
  /// [date] - Date of the ride
  /// 
  /// Returns [WeatherConditions] or throws if request fails
  Future<WeatherConditions> getForecast({
    required double lat,
    required double lng,
    required DateTime date,
  }) async {
    // Open-Meteo forecast provides data for up to 16 days.
    // We check if the date is within range (Open-Meteo works best for short term forecasts)
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference > 14) {
      throw Exception('Weather forecast only available for up to 14 days in advance');
    }

    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lng&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,precipitation,weather_code&start_date=$dateStr&end_date=$dateStr&timezone=auto',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hourly = data['hourly'];
        
        // Use the hour of the requested date to pick the forecast index
        final hourIndex = date.hour.clamp(0, 23);
        
        final temp = (hourly['temperature_2m'][hourIndex] as num).toDouble();
        final wind = (hourly['wind_speed_10m'][hourIndex] as num).toDouble();
        final windDir = (hourly['wind_direction_10m'][hourIndex] as num).toDouble();
        final precipitation = (hourly['precipitation'][hourIndex] as num).toDouble();
        final weatherCode = (hourly['weather_code'][hourIndex] as num).toInt();

        return WeatherConditions(
          temperature: temp,
          windSpeed: wind,
          windDirection: windDir,
          precipitation: precipitation,
          weatherCode: weatherCode,
        );
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }
}
