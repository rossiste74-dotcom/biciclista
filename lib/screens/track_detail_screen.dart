import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/track.dart';
import '../models/planned_ride.dart';
import '../models/climb.dart';
import '../models/route_coordinates.dart';
import '../services/database_service.dart';
import '../services/gpx_service.dart';
import '../widgets/route_map_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Track Detail Screen - Shows full track information (library view)
class TrackDetailScreen extends StatefulWidget {
  final Track track;

  const TrackDetailScreen({
    super.key,
    required this.track,
  });

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  final _db = DatabaseService();
  final _gpxService = GpxService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _routeData;
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    try {
      if (widget.track.gpxFilePath == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final gpxFile = File(widget.track.gpxFilePath!);
      _routeData = await _gpxService.parseGpxFile(gpxFile);
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.track.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifica',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modifica traccia in arrivo...')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map
                  if (_routeData != null && _routeData!['allPoints'] != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isMapExpanded ? 500 : 200,
                      child: Stack(
                        children: [
                          RouteMapWidget(
                            routePoints: List<Map<String, double>>.from(
                              _routeData!['allPoints'] as List,
                            ),
                            startPoint: (_routeData!['coordinates'] as RouteCoordinates).start,
                            middlePoint: (_routeData!['coordinates'] as RouteCoordinates).middle,
                            endPoint: (_routeData!['coordinates'] as RouteCoordinates).end,
                            distance: widget.track.distance,
                            elevation: widget.track.elevation,
                          ),
                          // Expand/Collapse button
                          Positioned(
                            top: 12,
                            right: 12,
                            child: FloatingActionButton.small(
                              heroTag: 'map_expand',
                              onPressed: () => setState(() => _isMapExpanded = !_isMapExpanded),
                              child: Icon(_isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
                            ),
                          ),
                          // Tap to expand when collapsed
                          if (!_isMapExpanded)
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() => _isMapExpanded = true),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Informazioni Percorso',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        
                        // Elevation Profile
                        if (_routeData != null && _routeData!['elevationProfile'] != null) ...[
                          Text(
                            'Profilo Altimetrico',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildElevationChart(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Tough Climbs
                        if (_routeData != null && (_routeData!['climbs'] as List).isNotEmpty) ...[
                          Text(
                            'Salite Impegnative',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildClimbsList(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Track Metadata
                        Text(
                          'Informazioni',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildMetadataCard(),
                        
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showScheduleDialog,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Pianifica'),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.route, '${widget.track.distance.toStringAsFixed(1)} km', 'Distanza'),
                _buildStat(Icons.terrain, '${widget.track.elevation.toStringAsFixed(0)} m', 'Dislivello'),
                if (widget.track.duration != null)
                  _buildStat(Icons.timer, '${widget.track.duration} min', 'Durata'),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoRow(Icons.landscape, widget.track.terrainLabel),
                _buildInfoRow(Icons.location_on, widget.track.region ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildElevationChart() {
    final profile = _routeData!['elevationProfile'] as List<Map<String, double>>;
    if (profile.isEmpty) return const SizedBox();

    final spots = profile.asMap().entries.map((entry) {
      return FlSpot(
        entry.value['distance']!,
        entry.value['elevation']!,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClimbsList() {
    final climbs = _routeData!['climbs'] as List<Climb>;
    
    return Column(
      children: climbs.map((climb) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              child: Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            title: Text('${climb.lengthKm.toStringAsFixed(1)} km'),
            subtitle: Text(
              'Pendenza media: ${climb.averageGradient.toStringAsFixed(1)}% • Max: ${climb.maxGradient.toStringAsFixed(1)}%',
            ),
            trailing: Text(
              '+${climb.elevationGain.toStringAsFixed(0)}m',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetadataRow(Icons.add_circle_outline, 'Creata', DateFormat('dd MMM yyyy', 'it_IT').format(widget.track.createdAt)),
            const Divider(),
            _buildMetadataRow(Icons.update, 'Aggiornata', DateFormat('dd MMM yyyy', 'it_IT').format(widget.track.updatedAt)),
            const Divider(),
            _buildMetadataRow(Icons.source, 'Origine', widget.track.source == 'manual' ? 'Importato manualmente' : 'Community'),
            if (widget.track.communityTrackId != null) ...[
              const Divider(),
              _buildMetadataRow(Icons.cloud, 'ID Community', widget.track.communityTrackId!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool isGroupRide = false;
    String? customName;
    
    // Group ride fields
    String difficulty = 'medium';
    String meetingPoint = '';
    bool isPublic = true;
    final meetingPointController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pianifica Uscita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Track info
                Text(
                  widget.track.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.track.distance.toStringAsFixed(1)} km • ${widget.track.elevation.toStringAsFixed(0)} m'),
                const Divider(height: 24),

                // Date picker
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Data'),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'it_IT').format(selectedDate)),
                  trailing: const Icon(Icons.edit),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),

                // Group ride toggle
                SwitchListTile(
                  title: const Text('Uscita di Gruppo'),
                  subtitle: const Text('Condividi con la community'),
                  value: isGroupRide,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setDialogState(() => isGroupRide = value);
                  },
                ),

                // Conditional group ride fields
                if (isGroupRide) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Difficulty selector
                  DropdownButtonFormField<String>(
                    value: difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficoltà',
                      prefixIcon: Icon(Icons.trending_up),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('🟢 Facile')),
                      DropdownMenuItem(value: 'medium', child: Text('🟡 Media')),
                      DropdownMenuItem(value: 'hard', child: Text('🔴 Difficile')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => difficulty = value);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Meeting point
                  TextField(
                    controller: meetingPointController,
                    decoration: const InputDecoration(
                      labelText: 'Punto di Ritrovo',
                      hintText: 'es. Piazza Duomo, Milano',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    onChanged: (value) => meetingPoint = value,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Visibility toggle
                  SwitchListTile(
                    title: const Text('Pubblico'),
                    subtitle: Text(isPublic ? 'Visibile a tutti' : 'Solo amici'),
                    value: isPublic,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setDialogState(() => isPublic = value);
                    },
                  ),
                  
                  const SizedBox(height: 8),
                ],

                // Custom name (optional)
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nome personalizzato (opzionale)',
                    hintText: 'Lascia vuoto per usare il nome della traccia',
                  ),
                  onChanged: (value) {
                    customName = value.isEmpty ? null : value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () async {
                // Validation
                if (isGroupRide && meetingPoint.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inserisci un punto di ritrovo per le uscite di gruppo')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                await _scheduleRide(
                  selectedDate,
                  isGroupRide,
                  customName,
                  difficulty,
                  meetingPoint,
                  isPublic,
                );
              },
              child: const Text('Pianifica'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleRide(
    DateTime date,
    bool isGroupRide,
    String? customName,
    String difficulty,
    String meetingPoint,
    bool isPublic,
  ) async {
    try {
      // Get center coordinates from route data if available
      double centerLat = 45.4642; // Default Milano
      double centerLng = 9.1900;
      
      if (_routeData != null && _routeData!['coordinates'] != null) {
        final coords = _routeData!['coordinates'] as RouteCoordinates;
        centerLat = coords.middle.latitude;
        centerLng = coords.middle.longitude;
      }
      
      final ride = PlannedRide()
        ..rideDate = date
        ..rideName = customName ?? widget.track.name
        ..trackId = widget.track.id
        ..isGroupRide = isGroupRide
        ..distance = widget.track.distance
        ..elevation = widget.track.elevation
        ..latitude = centerLat
        ..longitude = centerLng
        ..gpxFilePath = widget.track.gpxFilePath;

      ride.track.value = widget.track;
      await _db.createPlannedRide(ride);

      // Sync to Supabase if group ride
      if (isGroupRide) {
        await _syncGroupRideToSupabase(
          ride: ride,
          difficulty: difficulty,
          meetingPoint: meetingPoint,
          isPublic: isPublic,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGroupRide
                  ? 'Uscita di gruppo pianificata e condivisa!'
                  : 'Uscita personale pianificata!',
            ),
          ),
        );
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  Future<void> _syncGroupRideToSupabase({
    required PlannedRide ride,
    required String difficulty,
    required String meetingPoint,
    required bool isPublic,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        debugPrint('User not authenticated, skipping Supabase sync');
        return;
      }

      // Prepare GPX data for storage
      Map<String, dynamic>? gpxDataForDb;
      if (_routeData != null) {
        gpxDataForDb = {
          'allPoints': _routeData!['allPoints'],
          // We can add other processed data if needed, but points are key for valid map reconstruction
          // Elevation profile can be recalculated or stored if desired
          'elevationProfile': _routeData!['elevationProfile'], 
        };
      }

      // Map fields to match crew_schema.sql
      await supabase.from('group_rides').insert({
        'creator_id': user.id,
        'ride_name': ride.rideName ?? widget.track.name,
        'description': ride.track.value?.description,
        'gpx_data': gpxDataForDb, 
        'distance': ride.distance,
        'elevation': ride.elevation,
        'meeting_point': meetingPoint,
        'meeting_latitude': ride.latitude,
        'meeting_longitude': ride.longitude,
        'meeting_time': ride.rideDate.toIso8601String(),
        'difficulty_level': difficulty,
        'max_participants': 20,
        'is_public': isPublic,
        'status': 'planned',
      });
      
      // Mark as synced
      ride.supabaseEventId = 'synced_${DateTime.now().millisecondsSinceEpoch}';
      await _db.updatePlannedRide(ride);
      
      debugPrint('Group ride synced to Supabase successfully');
    } catch (e) {
      debugPrint('Error syncing group ride to Supabase: $e');
      // Non bloccare l'utente se sync fallisce
    }
  }
}
