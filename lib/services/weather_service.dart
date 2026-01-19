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

  /// Fetch hourly forecast for the next few days
  /// 
  /// Returns a list of hourly data points
  Future<List<Map<String, dynamic>>> getHourlyForecast(double lat, double lng) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lng&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,precipitation,weather_code&timezone=auto&forecast_days=7',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hourly = data['hourly'];
        final times = hourly['time'] as List;
        
        final List<Map<String, dynamic>> result = [];
        
        for (int i = 0; i < times.length; i++) {
          result.add({
            'dt': DateTime.parse(times[i]).millisecondsSinceEpoch ~/ 1000,
            'main': {
              'temp': (hourly['temperature_2m'][i] as num).toDouble(),
            },
            'wind': {
              'speed': (hourly['wind_speed_10m'][i] as num).toDouble(),
              'deg': (hourly['wind_direction_10m'][i] as num).toDouble(),
            },
            'weather': [
              {
                'id': (hourly['weather_code'][i] as num).toInt(),
                'main': _getWeatherMain((hourly['weather_code'][i] as num).toInt()),
                'icon': _getWeatherIcon((hourly['weather_code'][i] as num).toInt()),
              }
            ],
            'precipitation': (hourly['precipitation'][i] as num).toDouble(),
          });
        }
        
        return result;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      return [];
    }
  }

  String _getWeatherMain(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Clouds';
    if (code >= 45 && code <= 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain';
    if (code >= 85 && code <= 86) return 'Snow';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String _getWeatherIcon(int code) {
    // Mapping WMO codes to OpenWeatherMap icons for compatibility
    if (code == 0) return '01d';
    if (code == 1) return '02d'; // Mainly clear
    if (code == 2) return '03d'; // Partly cloudy
    if (code == 3) return '04d'; // Overcast
    if (code >= 45 && code <= 48) return '50d'; // Fog
    if (code >= 51 && code <= 55) return '09d'; // Drizzle
    if (code >= 56 && code <= 57) return '09d'; // Freezing Drizzle
    if (code >= 61 && code <= 65) return '10d'; // Rain
    if (code >= 66 && code <= 67) return '13d'; // Freezing Rain
    if (code >= 71 && code <= 77) return '13d'; // Snow
    if (code >= 80 && code <= 82) return '09d'; // Showers
    if (code >= 85 && code <= 86) return '13d'; // Snow showers
    if (code >= 95 && code <= 99) return '11d'; // Thunderstorm
    return '01d';
  }
}
