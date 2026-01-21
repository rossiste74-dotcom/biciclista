import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/group_ride.dart';
import '../services/crew_service.dart';
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
  late TabController _tabController;
  List<GroupRide> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _crewService.getPublicActivitiesForDiscovery(
        afterDate: DateTime.now(),
        limit: 100,
      );
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore caricamento: $e')),
        );
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(),
                _buildListView(),
              ],
            ),
    );
  }

  Widget _buildMapView() {
    if (_activities.isEmpty) {
      return _buildEmptyState('Nessuna attività pubblica nelle vicinanze');
    }

    // Filter activities with valid coordinates
    final activitiesWithCoords = _activities
        .where((a) => a.meetingLatitude != null && a.meetingLongitude != null)
        .toList();

    if (activitiesWithCoords.isEmpty) {
      return _buildEmptyState('Nessuna attività con coordinate disponibili');
    }

    // Calculate center (average of all coordinates)
    final avgLat = activitiesWithCoords
            .map((a) => a.meetingLatitude!)
            .reduce((a, b) => a + b) /
        activitiesWithCoords.length;
    final avgLng = activitiesWithCoords
            .map((a) => a.meetingLongitude!)
            .reduce((a, b) => a + b) /
        activitiesWithCoords.length;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(avgLat, avgLng),
        initialZoom: 10,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ridecrew.ride_crew',
        ),
        MarkerLayer(
          markers: activitiesWithCoords.map((activity) {
            return Marker(
              point: LatLng(activity.meetingLatitude!, activity.meetingLongitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showActivityBottomSheet(activity),
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (_activities.isEmpty) {
      return _buildEmptyState('Nessuna attività pubblica disponibile');
    }

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return ActivityCard(
            activity: activity,
            showJoinButton: true,
            onTap: () => _navigateToDetail(activity),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityBottomSheet(GroupRide activity) {
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

  void _navigateToDetail(GroupRide activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupRideDetailScreen(groupRide: activity),
      ),
    );
    if (result == true) _loadActivities();
  }
}
