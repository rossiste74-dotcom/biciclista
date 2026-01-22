import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/group_ride.dart';
import '../services/crew_service.dart';
import '../widgets/activity_card.dart';
import 'group_ride_detail_screen.dart';
import 'create_group_ride_screen.dart';

/// Unified agenda screen showing all user activities (created + joined)
class UnifiedAgendaScreen extends StatefulWidget {
  const UnifiedAgendaScreen({super.key});

  @override
  State<UnifiedAgendaScreen> createState() => _UnifiedAgendaScreenState();
}

class _UnifiedAgendaScreenState extends State<UnifiedAgendaScreen> with TickerProviderStateMixin {
  final _crewService = CrewService();
  List<GroupRide> _activities = [];
  bool _isLoading = true;
  late final TabController _tabController;

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
      final activities = await _crewService.getUnifiedActivityAgenda();
      debugPrint('UnifiedAgendaScreen: Loaded ${activities.length} activities');
      for (var a in activities) {
        debugPrint('Activity: ${a.rideName}, Lat: ${a.meetingLatitude}, Lon: ${a.meetingLongitude}');
      }
      
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
        // title: removed (handled by MainNavigationScreen)
        toolbarHeight: 0, // Collapse toolbar to just show TabBar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.map), text: 'Mappa'),
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
                _buildListTab(),
                _buildMapTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'agenda_add_btn',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGroupRideScreen(),
            ),
          );
          if (result == true) _loadActivities();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListTab() {
    if (_activities.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return ActivityCard(
            activity: activity,
            showJoinButton: false,
            onTap: () => _openActivityDetail(activity),
          );
        },
      ),
    );
  }

  Widget _buildMapTab() {
    // Filter activities with valid coordinates
    final mapActivities = _activities.where((a) => 
      a.meetingLatitude != null && a.meetingLongitude != null
    ).toList();

    if (mapActivities.isEmpty) {
      return const Center(
        child: Text(
          'Nessuna attività con posizione sulla mappa',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Centering logic (default Milan or average of points)
    final center = mapActivities.isNotEmpty
        ? LatLng(mapActivities.first.meetingLatitude!, mapActivities.first.meetingLongitude!)
        : const LatLng(45.4642, 9.1900);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 10,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.biciclistico.app',
        ),
        MarkerLayer(
          markers: mapActivities.map((activity) {
            return Marker(
              point: LatLng(activity.meetingLatitude!, activity.meetingLongitude!),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _openActivityDetail(activity),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.event, color: Colors.white, size: 20),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 12),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _openActivityDetail(GroupRide activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupRideDetailScreen(groupRide: activity),
      ),
    );
    if (result == true) _loadActivities();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Nessuna Attività',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea la tua prima attività o esplora quelle pubbliche!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
