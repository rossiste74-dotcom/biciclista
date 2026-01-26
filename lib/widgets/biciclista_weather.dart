import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget showing weather forecast with Il Biciclista's sarcastic motivation
class BiciclistaWeather extends StatelessWidget {
  final double temperature;
  final bool isRaining;
  final double windSpeed;
  final Map<String, String>? weatherMessages;

  const BiciclistaWeather({
    super.key,
    required this.temperature,
    this.isRaining = false,
    this.windSpeed = 0,
    this.weatherMessages,
  });

  String _getWeatherComment() {
    if (isRaining) {
      return weatherMessages?['rain'] ?? "weather.rain".tr();
    }
    
    if (windSpeed > 30) {
      return weatherMessages?['wind_high'] ?? "weather.wind_high".tr();
    }
    
    if (temperature > 28) {
      return weatherMessages?['hot'] ?? "weather.hot".tr();
    } else if (temperature >= 20 && temperature <= 25) {
      return weatherMessages?['perfect'] ?? "weather.perfect".tr();
    } else if (temperature >= 15) {
      return weatherMessages?['good'] ?? "weather.good".tr();
    } else if (temperature >= 5) {
      return weatherMessages?['cool'] ?? "weather.cool".tr();
    } else {
      return weatherMessages?['cold'] ?? "weather.cold".tr();
    }
  }

  IconData _getWeatherIcon() {
    if (isRaining) return Icons.water_drop;
    if (windSpeed > 25) return Icons.air;
    if (temperature > 25) return Icons.wb_sunny;
    if (temperature < 10) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }

  String _getWeatherCondition() {
    if (isRaining) return "weather.condition_rain".tr();
    if (windSpeed > 25) return "weather.condition_windy".tr();
    if (temperature > 25) return "weather.condition_hot".tr();
    if (temperature < 10) return "weather.condition_cold".tr();
    return "weather.condition_cloudy".tr();
  }

  @override
  Widget build(BuildContext context) {
    final comment = _getWeatherComment();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue.shade400,
              Colors.cyan.shade600,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getWeatherIcon(),
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'weather.title_today'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${temperature.toStringAsFixed(0)}°C',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getWeatherCondition(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (windSpeed > 10)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.air,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${windSpeed.toStringAsFixed(0)} km/h',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"$comment"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
