import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/group_ride.dart';
import '../models/planned_ride.dart';
import '../services/crew_service.dart';
import '../services/database_service.dart';
import '../widgets/activity_card.dart';
import 'group_ride_detail_screen.dart';

/// Discovery screen showing all public activities on map or list
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  final _crewService = CrewService();
  final _dbService = DatabaseService();

  late TabController _tabController;

  List<GroupRide> _groupActivities = [];
  List<PlannedRide> _communityRides = [];

  bool _isLoading = true;
  bool _showCommunityRides = false; // Toggle state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _crewService.getPublicActivitiesForDiscovery(
          afterDate: DateTime.now(),
          limit: 100,
        ),
        _dbService.getCommunityCompletedRides(),
      ]);

      if (mounted) {
        setState(() {
          _groupActivities = futures[0] as List<GroupRide>;
          _communityRides = futures[1] as List<PlannedRide>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore caricamento: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esplora Attività'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Mappa'),
            Tab(icon: Icon(Icons.list), text: 'Lista'),
          ],
        ),
        actions: [
          // Toggle tra Eventi in programma e Corse completate
          Row(
            children: [
              const Icon(Icons.group, size: 16),
              Switch(
                value: _showCommunityRides,
                activeThumbColor: Theme.of(context).colorScheme.secondary,
                onChanged: (val) {
                  setState(() {
                    _showCommunityRides = val;
                  });
                },
              ),
              const Icon(Icons.history, size: 16),
              const SizedBox(width: 8),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildMapView(), _buildListView()],
            ),
    );
  }

  Widget _buildMapView() {
    // 1. Dati da visualizzare
    final markersToDisplay = <Marker>[];
    double avgLat = 45.4642; // Default Milano
    double avgLng = 9.1900;

    if (!_showCommunityRides && _groupActivities.isNotEmpty) {
      final validGroups = _groupActivities
          .where((a) => a.meetingLatitude != null && a.meetingLongitude != null)
          .toList();
      if (validGroups.isNotEmpty) {
        avgLat =
            validGroups.map((a) => a.meetingLatitude!).reduce((a, b) => a + b) /
            validGroups.length;
        avgLng =
            validGroups
                .map((a) => a.meetingLongitude!)
                .reduce((a, b) => a + b) /
            validGroups.length;

        markersToDisplay.addAll(
          validGroups.map(
            (activity) => Marker(
              point: LatLng(
                activity.meetingLatitude!,
                activity.meetingLongitude!,
              ),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showGroupActivityBottomSheet(activity),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${activity.currentParticipants}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return _buildEmptyState('Nessuna uscita di gruppo con coordinate');
      }
    } else if (_showCommunityRides && _communityRides.isNotEmpty) {
      avgLat =
          _communityRides.map((a) => a.latitude!).reduce((a, b) => a + b) /
          _communityRides.length;
      avgLng =
          _communityRides.map((a) => a.longitude!).reduce((a, b) => a + b) /
          _communityRides.length;

      markersToDisplay.addAll(
        _communityRides.map(
          (ride) => Marker(
            point: LatLng(ride.latitude!, ride.longitude!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showCompletedRideBottomSheet(ride),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_bike,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return _buildEmptyState(
        _showCommunityRides
            ? 'Nessuna attività completata recente dalla community'
            : 'Nessuna uscita di gruppo imminente',
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(avgLat, avgLng),
        initialZoom: _showCommunityRides ? 6 : 10,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.ridecrew.ride_crew',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            maxZoom: 15,
            markers: markersToDisplay,
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _showCommunityRides
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (!_showCommunityRides) {
      if (_groupActivities.isEmpty)
        return _buildEmptyState('Nessuna uscita di gruppo');
      return RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _groupActivities.length,
          itemBuilder: (context, index) {
            final activity = _groupActivities[index];
            return ActivityCard(
              activity: activity,
              showJoinButton: true,
              onTap: () => _navigateToDetail(activity),
            );
          },
        ),
      );
    } else {
      if (_communityRides.isEmpty)
        return _buildEmptyState('Nessuna attività completata');
      return RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _communityRides.length,
          itemBuilder: (context, index) {
            final ride = _communityRides[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.directions_bike)),
              title: Text(ride.displayName),
              subtitle: Text(
                '${ride.distance.toStringAsFixed(1)} km • ${DateFormat('dd MMM').format(ride.rideDate)}\nDi: ${ride.notes ?? "Utente Rider"}',
              ),
              isThreeLine: true,
            );
          },
        ),
      );
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupActivityBottomSheet(GroupRide activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ActivityCard(
                  activity: activity,
                  showJoinButton: true,
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToDetail(activity);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletedRideBottomSheet(PlannedRide ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attività Completata',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text((ride.notes ?? "U")[0].toUpperCase()),
              ),
              title: Text(
                ride.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Di ${ride.notes ?? "Utente"} • ${DateFormat('dd MMM yyyy, HH:mm').format(ride.rideDate)}',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatIcon(
                  Icons.straighten,
                  '${ride.distance.toStringAsFixed(1)} km',
                ),
                _buildStatIcon(
                  Icons.trending_up,
                  '${ride.elevation.toStringAsFixed(0)} m',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _navigateToDetail(GroupRide activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupRideDetailScreen(groupRide: activity),
      ),
    );
    if (result == true) _loadAllData();
  }
}
