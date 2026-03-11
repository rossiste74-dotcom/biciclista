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
import '../models/planned_ride.dart';
import 'health_activity_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import '../services/link_parser_service.dart';
import 'manual_ride_screen.dart';
/// Unified agenda screen showing all user activities (created + joined)
class UnifiedAgendaScreen extends StatefulWidget {
  final int initialTabIndex;

  const UnifiedAgendaScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<UnifiedAgendaScreen> createState() => _UnifiedAgendaScreenState();
}

class _UnifiedAgendaScreenState extends State<UnifiedAgendaScreen> with TickerProviderStateMixin {
  final _crewService = CrewService();
  List<GroupRide> _upcomingActivities = [];
  List<GroupRide> _completedActivities = [];
  List<PlannedRide> _personalCompletedRides = [];
  bool _isLoading = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this, 
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      setState(() {});
    });
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
      final personalActivities = await _db.getCompletedRides();
      
      if (mounted) {
        setState(() {
          // Upcoming: Not personally completed AND Date is in future (or very recent past e.g. today)
          // User request: "se non superata la data programmata" -> strictly > now?
          // Let's use > now - 2 hours buffer or strict? 
          // "se non superata la data" implies future.
          final now = DateTime.now().toUtc();
          debugPrint('UnifiedAgendaScreen: User Time (UTC): \$now');

          _upcomingActivities = activities.where((a) {
             final isMyCompleted = myCompletedIds.contains(a.id);
             
             // Convert to UTC to be safe
             final meetingTime = a.meetingTime.toUtc(); 
             final isFuture = meetingTime.isAfter(now);
             
             debugPrint('Activity: \${a.rideName} - Time: \$meetingTime vs Now: \$now -> IsFuture? \$isFuture');

             return !isMyCompleted && isFuture;
          }).toList();

          // Completed: I have personally completed it OR status is completed and I participated?
          // User: "Nelle completate devo vedere solo le mie completate".
          // So ONLY what I marked as finished in my diary.
          _completedActivities = activities.where((a) {
             return myCompletedIds.contains(a.id);
          }).toList();
          
          _personalCompletedRides = personalActivities;
          
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
        title: const Text('La Mia Agenda'),
        leading: const BackButton(),
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
      // Show Add FAB on tabs 0 & 1, Import FAB on tab 2
      floatingActionButton: _tabController.index == 2 
        ? FloatingActionButton.extended(
            heroTag: 'agenda_import_btn',
            onPressed: _showImportOptions,
            icon: const Icon(Icons.download),
            label: const Text('Importa'),
          )
        : FloatingActionButton(
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

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Incolla Link (Strava/Komoot)'),
              subtitle: const Text('Importa dati da un link'),
              onTap: () {
                Navigator.pop(context);
                _showLinkImportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Scegli Immagine'),
              subtitle: const Text('Estrai dati dal riepilogo attività'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  _processImportedImage(image.path);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _processImportedImage(String path) async {
    setState(() => _isLoading = true);
    final ocrService = OCRService();
    try {
      final data = await ocrService.extractRideDataFromImage(path);
      if (mounted) {
        setState(() => _isLoading = false);
        _navigateToManualRide(data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore importazione: $e')));
      }
    }
  }

  void _showLinkImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importa da Link'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                _processImportedLink(controller.text);
              }
            },
            child: const Text('Importa'),
          ),
        ],
      ),
    );
  }

  Future<void> _processImportedLink(String url) async {
    setState(() => _isLoading = true);
    final linkParser = LinkParserService();
    try {
      final data = await linkParser.parseUrl(url);
      if (mounted) {
        setState(() => _isLoading = false);
        if (data != null) {
           _navigateToManualRide(data);
        } else {
           _navigateToManualRide({'notes': url});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore analisi link: $e')));
      }
    }
  }

  void _navigateToManualRide(Map<String, dynamic> data) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManualRideScreen(
          initialName: data['name']?.toString(),
          initialDistance: data['distance']?.toString(),
          initialElevation: data['elevation']?.toString(),
          initialDate: data['date'] as DateTime?,
          initialHeartRate: data['heartRate'] as int?,
          initialPower: data['power'] as int?,
          initialNotes: data['notes']?.toString(),
        ),
      ),
    );
    if (result == true) _loadActivities();
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
    final List<dynamic> allCompleted = [
      ..._completedActivities,
      ..._personalCompletedRides,
    ];

    if (allCompleted.isEmpty) return _buildEmptyCompletedState();

    // Sort descending by date (most recent first)
    allCompleted.sort((a, b) {
      final dateA = (a is GroupRide) ? a.meetingTime : (a as PlannedRide).rideDate;
      final dateB = (b is GroupRide) ? b.meetingTime : (b as PlannedRide).rideDate;
      return dateB.compareTo(dateA); 
    });

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: allCompleted.length,
        itemBuilder: (context, index) {
          final item = allCompleted[index];
          if (item is GroupRide) {
            return ActivityCard(
              activity: item,
              showJoinButton: false,
              onTap: () => _openActivityDetail(item),
            );
          } else if (item is PlannedRide) {
            return _buildPersonalActivityCard(item);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPersonalActivityCard(PlannedRide ride) {
    final dateFormat = DateFormat('dd MMM yyyy - HH:mm');
    final dateStr = dateFormat.format(ride.rideDate);
    
    IconData icon = Icons.directions_run; 
    Color iconColor = Colors.orange;
    
    final nameInput = (ride.rideName ?? "").toUpperCase();
    if (nameInput.contains("CYCLING") || nameInput.contains("BIKING") || nameInput.contains("CICLISMO") || nameInput.contains("BICI")) {
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthActivityDetailScreen(
                plannedRide: ride,
              ),
            ),
          ).then((_) => _loadActivities());
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          ride.rideName ?? "Attività",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
              if (ride.notes != null) ...[
                const SizedBox(height: 4),
                Text(
                  ride.notes!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${ride.distance.toStringAsFixed(1)} km",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (ride.elevation > 0)
              Text(
                "${ride.elevation.toStringAsFixed(0)} m",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
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
