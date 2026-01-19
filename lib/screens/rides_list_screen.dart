import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/planned_ride.dart';
import '../services/database_service.dart';
import 'route_detail_screen.dart';
import 'gpx_import_screen.dart';
import 'tracks_library_screen.dart';
import 'package:isar/isar.dart';

class RidesListScreen extends StatefulWidget {
  const RidesListScreen({super.key});

  @override
  State<RidesListScreen> createState() => _RidesListScreenState();
}

class _RidesListScreenState extends State<RidesListScreen> {
  final _db = DatabaseService();
  List<PlannedRide> _rides = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadRides();
    _subscription = _db.watchPlannedRides().listen((_) {
      _loadRides(silent: true);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRides({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final rides = await _db.isar.plannedRides
        .where()
        .sortByRideDateDesc()
        .findAll();
    
    if (mounted) {
      setState(() {
        _rides = rides;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final plannedRides = _rides.where((r) => !r.isCompleted).toList();
    final completedRides = _rides.where((r) => r.isCompleted).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attività'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Le Mie Tracce', icon: Icon(Icons.folder_open)),
              Tab(text: 'Pianificati', icon: Icon(Icons.calendar_today_outlined)),
              Tab(text: 'Effettuati', icon: Icon(Icons.history_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const TracksLibraryScreen(),
            _buildRideList(plannedRides, 'Nessun giro pianificato'),
            _buildRideList(completedRides, 'Nessuna attività completata'),
          ],
        ),
      ),
    );
  }

  Widget _buildRideList(List<PlannedRide> rides, String emptyMessage) {
    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bike_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRides,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RouteDetailScreen(plannedRide: ride),
                  ),
                );
                _loadRides(); // Refresh list in case of deletion or status change
              },
              leading: CircleAvatar(
                backgroundColor: ride.isCompleted 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  ride.isCompleted ? Icons.check_circle : Icons.map_outlined,
                  color: ride.isCompleted 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              title: Text(
                ride.rideName ?? DateFormat('EEEE, d MMMM y', 'it_IT').format(ride.rideDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${ride.distance.toStringAsFixed(1)} km • ${ride.elevation.toStringAsFixed(0)} m D+',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
