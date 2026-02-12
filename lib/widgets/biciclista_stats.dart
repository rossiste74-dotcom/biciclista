import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget showing weekly statistics with sarcastic Il Biciclista comments
class BiciclistaStats extends StatelessWidget {
  final double weeklyKm;
  final int weeklyRides;
  final Map<String, String>? statsMessages;

  const BiciclistaStats({
    super.key,
    required this.weeklyKm,
    required this.weeklyRides,
    this.statsMessages,
  });

  String _getSarcasticComment() {
    if (weeklyKm < 50) {
      return statsMessages?['km_0_50'] ?? "stats.km_0_50".tr();
    } else if (weeklyKm < 100) {
      return statsMessages?['km_50_100'] ?? "stats.km_50_100".tr();
    } else if (weeklyKm < 150) {
      return statsMessages?['km_100_150'] ?? "stats.km_100_150".tr();
    } else if (weeklyKm < 200) {
      return statsMessages?['km_150_200'] ?? "stats.km_150_200".tr();
    } else {
      return statsMessages?['km_200_plus'] ?? "stats.km_200_plus".tr();
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
                    'stats.title'.tr(),
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
                        '${weeklyKm.toStringAsFixed(3)} km',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'stats.this_week'.tr(),
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
                        'stats.rides'.tr(),
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
