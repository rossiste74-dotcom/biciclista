import 'package:flutter/material.dart';
import '../../models/planned_ride.dart';
import 'package:intl/intl.dart';

class CommunityFeedWidget extends StatelessWidget {
  final List<PlannedRide> upcomingRides;
  final Function(PlannedRide) onJoin;

  const CommunityFeedWidget({
    super.key,
    required this.upcomingRides,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'La Comunità',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (upcomingRides.isEmpty)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('Nessuna uscita programmata nella community.')),
            ),
          )
        else
          ...upcomingRides.map((ride) => _buildFeedItem(context, ride)),
      ],
    );
  }

  Widget _buildFeedItem(BuildContext context, PlannedRide ride) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.group, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(ride.rideName ?? 'Uscita', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${DateFormat('EEEE d MMM, HH:mm').format(ride.rideDate)}\n${ride.distance.toStringAsFixed(1)} km',
        ),
        isThreeLine: true,
        trailing: FilledButton.tonal(
          onPressed: () => onJoin(ride),
          child: const Text('Partecipa'),
        ),
      ),
    );
  }
}
