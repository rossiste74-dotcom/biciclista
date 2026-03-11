import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PersonalStatsCard extends StatelessWidget {
  final double monthlyKm;
  final double elevation;
  final String eleganceGrade; // Grado di Eleganza in sella

  const PersonalStatsCard({
    super.key,
    required this.monthlyKm,
    required this.elevation,
    required this.eleganceGrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, Icons.directions_bike, '${monthlyKm.toStringAsFixed(1)} Km', 'Mese Corrente'),
            _buildStatItem(context, Icons.landscape, '${elevation.toStringAsFixed(0)} m', 'Dislivello'),
            _buildStatItem(context, Icons.auto_awesome, eleganceGrade, 'Eleganza'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
