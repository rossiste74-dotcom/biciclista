/// Model representing weather conditions for outfit suggestions
class WeatherConditions {
  /// Temperature in degrees Celsius
  final double temperature;

  /// Wind speed in km/h
  final double windSpeed;

  /// Precipitation probability (0.0 to 1.0), optional
  final double? precipitation;

  /// Humidity percentage (0-100), optional
  final int? humidity;

  /// Wind direction in degrees (0-360)
  final double? windDirection;

  /// WMO Weather interpretation code
  final int? weatherCode;

  const WeatherConditions({
    required this.temperature,
    required this.windSpeed,
    this.precipitation,
    this.humidity,
    this.weatherCode,
    this.windDirection,
  });

  /// Check if conditions are windy (> 20 km/h)
  bool get isWindy => windSpeed > 20;

  /// Check if conditions are very windy (> 30 km/h)
  bool get isVeryWindy => windSpeed > 30;

  /// Check if rain is likely (> 50% probability)
  bool get isRainy => (precipitation != null && precipitation! > 0.5) || (weatherCode != null && weatherCode! >= 51);

  /// Get appropriate weather icon based on WMO weather code
  String get icon {
    if (weatherCode == null) return '☀️';
    if (weatherCode! <= 3) return '☀️'; // Clear/Partly Cloudy
    if (weatherCode! <= 48) return '☁️'; // Fog/Cloudy
    if (weatherCode! <= 67) return '🌧️'; // Rain/Drizzle
    if (weatherCode! <= 77) return '❄️'; // Snow
    if (weatherCode! <= 82) return '🌧️'; // Rain Showers
    if (weatherCode! <= 86) return '❄️'; // Snow Showers
    if (weatherCode! <= 99) return '⛈️'; // Thunderstorm
    return '☀️';
  }

  @override
  String toString() {
    return 'WeatherConditions(temp: $temperature°C, wind: ${windSpeed}km/h)';
  }
}
