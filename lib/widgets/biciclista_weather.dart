import 'package:flutter/material.dart';

/// Widget showing weather forecast with Il Biciclista's sarcastic motivation
class BiciclistaWeather extends StatelessWidget {
  final double temperature;
  final bool isRaining;
  final double windSpeed;

  const BiciclistaWeather({
    super.key,
    required this.temperature,
    this.isRaining = false,
    this.windSpeed = 0,
  });

  String _getWeatherComment() {
    if (isRaining) {
      return "Piove? E allora? Non sei mica di zucchero! I veri ciclisti escono anche con l'acquazzone.";
    }
    
    if (windSpeed > 30) {
      return "Vento contrario in andata significa vento a favore al ritorno. Pensa positivo (o fai un giro ad anello).";
    }
    
    if (temperature > 28) {
      return "Fa caldo! Parti presto la mattina o la sera, che a mezzogiorno ti sciogli sull'asfalto.";
    } else if (temperature >= 20 && temperature <= 25) {
      return "Che aspetti? Il meteo è perfetto, le gambe si muovono da sole!";
    } else if (temperature >= 15) {
      return "Temperature ideali per pedalare. Né troppo caldo né troppo freddo, solo scuse non accettate.";
    } else if (temperature >= 5) {
      return "Fa freschetto, ma con l'abbigliamento giusto vai benissimo. Copri le estremità e parti!";
    } else {
      return "Fa freddo da lupi. Copriti bene o fai un giro corto, che poi ti chiamano ghiacciolo.";
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
    if (isRaining) return "Pioggia";
    if (windSpeed > 25) return "Ventoso";
    if (temperature > 25) return "Caldo";
    if (temperature < 10) return "Freddo";
    return "Nuvoloso";
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
                    'Meteo Oggi',
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
