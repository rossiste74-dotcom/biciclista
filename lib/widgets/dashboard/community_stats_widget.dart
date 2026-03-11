import 'package:flutter/material.dart';

class CommunityStatsWidget extends StatelessWidget {
  final double totalCrewKm;
  final String cimaDelMese;
  final String topCapitano;

  const CommunityStatsWidget({
    super.key,
    required this.totalCrewKm,
    required this.cimaDelMese,
    required this.topCapitano,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche della Comunità',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.groups)),
              title: const Text('Km Totali Crew'),
              trailing: Text(
                '${totalCrewKm.toStringAsFixed(0)} km',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.landscape)),
              title: const Text('Cima del Mese'),
              trailing: Text(
                cimaDelMese,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.workspace_premium)),
              title: const Text('Capitano più attivo'),
              trailing: Text(
                topCapitano,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
