import 'package:flutter/material.dart';
import '../models/planned_ride.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';
import 'health_activity_detail_screen.dart';

class HealthActivityListScreen extends StatefulWidget {
  const HealthActivityListScreen({super.key});

  @override
  State<HealthActivityListScreen> createState() => _HealthActivityListScreenState();
}

class _HealthActivityListScreenState extends State<HealthActivityListScreen> {
  final _db = DatabaseService();
  late Future<List<PlannedRide>> _futureRides;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureRides = _db.getImportedRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attività Sincronizzate"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<PlannedRide>>(
        future: _futureRides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          }
          
          final rides = snapshot.data ?? [];
          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                     "Nessuna attività importata.",
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     "Assicurati di aver abilitato la sincronizzazione\ne che ci siano dati in Health Connect.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey),
                   ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return _buildActivityCard(ride);
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(PlannedRide ride) {
    final dateFormat = DateFormat('dd MMM yyyy - HH:mm');
    final dateStr = dateFormat.format(ride.rideDate);
    
    // Determine icon based on name/description
    IconData icon = Icons.directions_run; // Default to run/generic
    Color iconColor = Colors.orange;
    
    final nameInput = (ride.rideName ?? "").toUpperCase();
    if (nameInput.contains("CYCLING") || nameInput.contains("BIKING") || nameInput.contains("CICLISMO")) {
      icon = Icons.directions_bike;
      iconColor = Colors.blue;
    } else if (nameInput.contains("WALKING") || nameInput.contains("CAMMINATA")) {
      icon = Icons.directions_walk;
      iconColor = Colors.green;
    } else if (nameInput.contains("SWIMMING") || nameInput.contains("NUOTO")) {
      icon = Icons.pool;
      iconColor = Colors.cyan;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthActivityDetailScreen(
                plannedRide: ride,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          ride.rideName ?? "Attività",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr),
            if (ride.notes != null)
              Text(
                ride.notes!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${ride.distance.toStringAsFixed(3)} km",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text("Distanza", style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
