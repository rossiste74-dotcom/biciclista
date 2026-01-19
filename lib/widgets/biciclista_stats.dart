import 'package:flutter/material.dart';

/// Widget showing weekly statistics with sarcastic Il Biciclista comments
class BiciclistaStats extends StatelessWidget {
  final double weeklyKm;
  final int weeklyRides;

  const BiciclistaStats({
    super.key,
    required this.weeklyKm,
    required this.weeklyRides,
  });

  String _getSarcasticComment() {
    if (weeklyKm < 50) {
      return "50km in una settimana? I miei nonni facevano di più per andare a prendere il pane!";
    } else if (weeklyKm < 100) {
      return "Niente male, ma non è che stai preparando il Giro d'Italia...";
    } else if (weeklyKm < 150) {
      return "Adesso sì che si ragiona! Continua così e tra un anno ti sponsorizza la pasta.";
    } else if (weeklyKm < 200) {
      return "Bravo! Anche se probabilmente hai trascurato famiglia e lavoro per questi km.";
    } else {
      return "Ma tu vivi in bici o cosa? Rispetta anche il divano ogni tanto!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = _getSarcasticComment();

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
              Colors.purple.shade400,
              Colors.blue.shade600,
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
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Statistiche Settimanali',
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
                        '${weeklyKm.toStringAsFixed(0)} km',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Questa settimana',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$weeklyRides',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'uscite',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
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
