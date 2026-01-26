import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/group_ride.dart';
import '../services/crew_service.dart';
import '../widgets/activity_card.dart';
import 'group_ride_detail_screen.dart';
import 'create_group_ride_screen.dart';
import '../services/configuration_service.dart';
import '../services/database_service.dart';

/// Unified agenda screen showing all user activities (created + joined)
class UnifiedAgendaScreen extends StatefulWidget {
  const UnifiedAgendaScreen({super.key});

  @override
  State<UnifiedAgendaScreen> createState() => _UnifiedAgendaScreenState();
}

class _UnifiedAgendaScreenState extends State<UnifiedAgendaScreen> with TickerProviderStateMixin {
  final _crewService = CrewService();
  List<GroupRide> _upcomingActivities = [];
  List<GroupRide> _completedActivities = [];
  bool _isLoading = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _db = DatabaseService(); // Added DB instance

  Future<void> _loadActivities() async {
      setState(() => _isLoading = true);
    try {
      final activities = await _crewService.getUnifiedActivityAgenda();
      final myCompletedIds = await _db.getCompletedGroupRideIds();
      
      if (mounted) {
        setState(() {
          // Upcoming: Not personally completed AND Date is in future (or very recent past e.g. today)
          // User request: "se non superata la data programmata" -> strictly > now?
          // Let's use > now - 2 hours buffer or strict? 
          // "se non superata la data" implies future.
          final now = DateTime.now();
          
          _upcomingActivities = activities.where((a) {
             final isMyCompleted = myCompletedIds.contains(a.id);
             final isFuture = a.meetingTime.isAfter(now);
             return !isMyCompleted && isFuture;
          }).toList();

          // Completed: I have personally completed it OR status is completed and I participated?
          // User: "Nelle completate devo vedere solo le mie completate".
          // So ONLY what I marked as finished in my diary.
          _completedActivities = activities.where((a) {
             return myCompletedIds.contains(a.id);
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('agenda.load_error'.tr(args: [e.toString()]))),
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
          tabs: [
            Tab(icon: const Icon(Icons.list), text: 'agenda.tab_list'.tr()),
            Tab(icon: const Icon(Icons.map), text: 'agenda.tab_map'.tr()),
            Tab(icon: const Icon(Icons.check_circle_outline), text: 'agenda.tab_completed'.tr()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
            tooltip: 'common.refresh'.tr(),
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
                _buildCompletedTab(),
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
    if (_upcomingActivities.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _upcomingActivities.length,
        itemBuilder: (context, index) {
          final activity = _upcomingActivities[index];
          return ActivityCard(
            activity: activity,
            showJoinButton: false,
            onTap: () => _openActivityDetail(activity),
          );
        },
      ),
    );
  }

  Widget _buildCompletedTab() {
    if (_completedActivities.isEmpty) return _buildEmptyCompletedState();

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _completedActivities.length,
        itemBuilder: (context, index) {
          final activity = _completedActivities[index];
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
    final mapActivities = _upcomingActivities.where((a) => 
      a.meetingLatitude != null && a.meetingLongitude != null
    ).toList();

    if (mapActivities.isEmpty) {
      return Center(
        child: Text(
          'agenda.no_map_activities'.tr(),
          style: const TextStyle(color: Colors.grey),
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
          urlTemplate: 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
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
            const SizedBox(height: 24),
            Text(
              'agenda.empty_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'agenda.empty_subtitle'.tr(),
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

  Widget _buildEmptyCompletedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            Text(
              'agenda.empty_completed_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'agenda.empty_completed_subtitle'.tr(),
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
