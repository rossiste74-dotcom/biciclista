import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:gpx/gpx.dart';

import '../models/planned_ride.dart';
import '../models/bicycle.dart';
import '../models/track.dart';
import '../models/route_coordinates.dart';
import '../models/climb.dart';
import '../services/database_service.dart';
import '../services/track_service.dart';
import '../services/notification_service.dart';
import '../services/gpx_service.dart';
import '../utils/gpx_optimizer.dart';
import '../widgets/route_map_widget.dart';
import '../widgets/elevation_profile_widget.dart';

/// Detail screen showing all available information for a Health Connect activity
class HealthActivityDetailScreen extends StatefulWidget {
  final PlannedRide plannedRide;

  const HealthActivityDetailScreen({
    super.key,
    required this.plannedRide,
  });

  @override
  State<HealthActivityDetailScreen> createState() => _HealthActivityDetailScreenState();
}

class _HealthActivityDetailScreenState extends State<HealthActivityDetailScreen> {
  Health? get _health => kIsWeb ? null : Health();
  bool _isLoading = true;
  
  // Workout details
  Duration? _duration;
  double? _avgHeartRate;
  double? _maxHeartRate;
  double? _avgSpeed;
  int? _calories;
  int? _steps;
  
  // Assigned entities
  Bicycle? _assignedBicycle;
  Track? _assignedTrack;
  
  bool _isMapExpanded = false;
  Map<String, dynamic>? _routeData;
  
  @override
  void initState() {
    super.initState();
    _loadActivityDetails();
  }

  Future<void> _loadActivityDetails() async {
    setState(() => _isLoading = true);
    
    try {
      // Query workout data for this specific time range (±5 minutes to catch the exact workout)
      final DateTime activityDate = widget.plannedRide.rideDate;
      final start = activityDate.subtract(const Duration(minutes: 5));
      final end = activityDate.add(const Duration(hours: 3)); // Most workouts < 3h
      
      // Only fetch health data on mobile devices
      if (!kIsWeb) {
        // Get workout data
        final workouts = await _health!.getHealthDataFromTypes(
          startTime: start,
          endTime: end,
          types: [HealthDataType.WORKOUT],
        );
        
        if (workouts.isNotEmpty) {
          final workout = workouts.first;
          
          // Calculate duration
          _duration = workout.dateTo.difference(workout.dateFrom);
          
          // Calculate avg speed (km/h)
          if (_duration != null && _duration!.inSeconds > 0) {
            _avgSpeed = (widget.plannedRide.distance / _duration!.inHours);
          }
        }
      }
      
      // Try to get heart rate data in the same time range
      if (!kIsWeb) {
        try {
          final DateTime activityDate = widget.plannedRide.rideDate;
          final hrData = await _health!.getHealthDataFromTypes(
            startTime: activityDate,
            endTime: activityDate.add(_duration ?? const Duration(hours: 1)),
            types: [HealthDataType.HEART_RATE],
          );
          
          if (hrData.isNotEmpty) {
            final hrValues = hrData.map((e) => (e.value as NumericHealthValue).numericValue.toDouble()).toList();
            _avgHeartRate = hrValues.reduce((a, b) => a + b) / hrValues.length;
            _maxHeartRate = hrValues.reduce((a, b) => a > b ? a : b).toDouble();
          }
        } catch (e) {
          debugPrint('Could not fetch heart rate: $e');
        }
      }
      
      // Try to get steps
      if (!kIsWeb) {
        try {
          final DateTime activityDate = widget.plannedRide.rideDate;
          final stepsData = await _health!.getHealthDataFromTypes(
            startTime: activityDate,
            endTime: activityDate.add(_duration ?? const Duration(hours: 1)),
            types: [HealthDataType.STEPS],
          );
          
          if (stepsData.isNotEmpty) {
            _steps = stepsData.map((e) => (e.value as NumericHealthValue).numericValue.toInt()).reduce((a, b) => a + b);
          }
        } catch (e) {
          debugPrint('Could not fetch steps: $e');
        }
      }
      
      // Load assigned entities if any
      if (widget.plannedRide.bicycleId != null) {
        final db = DatabaseService();
        _assignedBicycle = await db.getBicycleById(widget.plannedRide.bicycleId!);
      }
      if (widget.plannedRide.trackId != null) {
        final ts = TrackService();
        _assignedTrack = await ts.getTrackById(widget.plannedRide.trackId!);
        if (_assignedTrack != null) {
           await _loadTrackRouteData(_assignedTrack!);
        }
      }
      
    } catch (e) {
      debugPrint('Error loading activity details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTrackRouteData(Track track) async {
    try {
      String? gpxString;
      
      if (!kIsWeb && track.gpxFilePath != null) {
        final f = File(track.gpxFilePath!);
        if (await f.exists()) gpxString = await f.readAsString();
      }
      if (gpxString == null && track.gpxUrl != null) {
         try {
           final url = await TrackService().getGpxUrl(track);
           if (url != null) {
             final response = await http.get(Uri.parse(url));
             if (response.statusCode == 200) {
                gpxString = utf8.decode(response.bodyBytes);
                if (!kIsWeb) {
                  final dir = await getTemporaryDirectory();
                  final filename = track.gpxUrl!.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '');
                  final file = File('${dir.path}/$filename');
                  await file.writeAsString(gpxString);
                  track.gpxFilePath = file.path;
                }
             }
           }
         } catch(e) {
           debugPrint('Error downloading GPX: $e');
         }
      }
      if (gpxString == null && track.communityGpxData != null) {
        try {
           final dynamic parsedJson = jsonDecode(track.communityGpxData!);
           final gpx = GpxOptimizer.jsonToGpx(parsedJson);
           gpxString = GpxWriter().asString(gpx, pretty: true);
        } catch (e) {
           debugPrint('Error parsing community GPX data: $e');
        }
      }
      
      if (gpxString != null) {
        _routeData = await GpxService().parseGpxString(gpxString);
      }
    } catch (e) {
      debugPrint('Error loading track route data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final String activityType = widget.plannedRide.rideName ?? "Attività";
    final DateTime activityDate = widget.plannedRide.rideDate;
    final double distance = widget.plannedRide.distance;
    
    // Check if the generic sync tag is present to show completion ui
    final bool isHealthSync = activityType.contains('(Health)');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(activityType.replaceAll('(Health)', '').trim()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map
                  if (_routeData != null && _routeData!['allPoints'] != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isMapExpanded ? 400 : 200,
                      child: Stack(
                        children: [
                          RouteMapWidget(
                            routePoints: List<Map<String, double>>.from(_routeData!['allPoints'] as List),
                            startPoint: (_routeData!['coordinates'] as RouteCoordinates).start,
                            middlePoint: (_routeData!['coordinates'] as RouteCoordinates).middle,
                            endPoint: (_routeData!['coordinates'] as RouteCoordinates).end,
                            distance: _assignedTrack!.distance,
                            elevation: _assignedTrack!.elevation,
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: FloatingActionButton.small(
                              heroTag: 'map_expand_health',
                              onPressed: () => setState(() => _isMapExpanded = !_isMapExpanded),
                              child: Icon(_isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
                            ),
                          ),
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
                  
                  // Main Content Padding
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getActivityIcon(),
                                size: 48,
                                color: _getActivityColor(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activityType.replaceAll('(Health)', '').trim(),
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    Text(
                                      dateFormat.format(activityDate),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Main Metrics
                  Text(
                    'Metriche Principali',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.route,
                          label: 'Distanza',
                          value: '${distance.toStringAsFixed(3)} km',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.timer,
                          label: 'Durata',
                          value: _duration != null 
                              ? _formatDuration(_duration!)
                              : 'N/A',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (_avgSpeed != null)
                    _buildMetricCard(
                      icon: Icons.speed,
                      label: 'Velocità Media',
                      value: '${_avgSpeed!.toStringAsFixed(1)} km/h',
                      color: Colors.green,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Health Metrics
                  if (_avgHeartRate != null || _maxHeartRate != null || _steps != null) ...[
                    Text(
                      'Metriche Salute',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (_avgHeartRate != null || _maxHeartRate != null)
                    Row(
                      children: [
                        if (_avgHeartRate != null)
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.favorite,
                              label: 'FC Media',
                              value: '${_avgHeartRate!.toStringAsFixed(0)} bpm',
                              color: Colors.red,
                            ),
                          ),
                        if (_avgHeartRate != null && _maxHeartRate != null)
                          const SizedBox(width: 12),
                        if (_maxHeartRate != null)
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.favorite_border,
                              label: 'FC Max',
                              value: '${_maxHeartRate!.toStringAsFixed(0)} bpm',
                              color: Colors.red.shade700,
                            ),
                          ),
                      ],
                    ),
                  
                  if (_steps != null) ...[
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      icon: Icons.directions_walk,
                      label: 'Passi',
                      value: _steps.toString(),
                      color: Colors.purple,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dati sincronizzati da Health Connect.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Display Assigned Entities
                  if (_assignedBicycle != null || _assignedTrack != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Dettagli Assegnati',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_assignedBicycle != null)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(Icons.pedal_bike, color: Colors.blue),
                          ),
                          title: Text(_assignedBicycle!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Bicicletta utilizzata (${_assignedBicycle!.type})'),
                        ),
                      ),
                    if (_assignedTrack != null)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.map, color: Colors.green),
                          ),
                          title: Text(_assignedTrack!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Percorso seguito'),
                        ),
                      ),
                  ],
                  
                  // Track Details (Elevation Profile & AI Analysis) if available
                  if (_routeData != null && _assignedTrack != null) ...[
                     const SizedBox(height: 24),
                     Text(
                       'Dettagli Traccia Assegnata',
                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     const SizedBox(height: 16),
                     
                     if (_routeData!['elevationProfile'] != null) ...[
                       Text(
                         'Profilo Altimetrico',
                         style: Theme.of(context).textTheme.titleMedium,
                       ),
                       const SizedBox(height: 16),
                       _buildElevationChart(),
                       const SizedBox(height: 24),
                     ],
                     
                     if ((_routeData!['climbs'] as List?)?.isNotEmpty ?? false) ...[
                       Text(
                         'Salite Impegnative',
                         style: Theme.of(context).textTheme.titleMedium,
                       ),
                       const SizedBox(height: 16),
                       _buildClimbsList(),
                       const SizedBox(height: 24),
                     ],
                     
                     if (_assignedTrack!.description != null && _assignedTrack!.description!.isNotEmpty) ...[
                       Text(
                         'Analisi Butler AI',
                         style: Theme.of(context).textTheme.titleMedium,
                       ),
                       const SizedBox(height: 16),
                       Card(
                         elevation: 2,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         child: Padding(
                           padding: const EdgeInsets.all(16),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   Icon(Icons.rocket_launch, color: Theme.of(context).colorScheme.primary),
                                   const SizedBox(width: 8),
                                   const Expanded(
                                     child: Text(
                                       'Strategia "Il Biciclista"',
                                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                     ),
                                   ),
                                 ],
                               ),
                               const Divider(),
                               Text(
                                 _assignedTrack!.description!,
                                 style: const TextStyle(fontSize: 15, height: 1.4),
                               ),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(height: 24),
                     ],
                  ],

                  // Action to complete the ride if it hasn't customized yet
                  if (widget.plannedRide.bicycleId == null) ...[
                     const SizedBox(height: 32),
                     SizedBox(
                       width: double.infinity,
                       height: 50,
                       child: FilledButton.icon(
                         onPressed: () => _showCompletionDialog(context),
                         icon: const Icon(Icons.check_circle_outline),
                         label: const Text('Completa Informazioni'),
                       ),
                     ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCompletionDialog(BuildContext context) async {
    final db = DatabaseService();
    final trackService = TrackService();
    // Load bikes and tracks
    final bicycles = await db.getAllBicycles();
    final tracks = await trackService.getAllTracks();

    if (!context.mounted) return;

    if (bicycles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devi avere almeno una bicicletta nel garage per completare l\'attività.'))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
         String? selectedBikeId;
         String? selectedTrackId;
         
         return StatefulBuilder(
           builder: (context, setState) {
             return Padding(
               padding: EdgeInsets.only(
                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
                 left: 16, right: 16, top: 24,
               ),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     'Completa Dettagli Attività',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     'Assegna una bicicletta per registrarne i chilometri e (opzionale) un percorso dalla tua libreria.',
                     style: TextStyle(color: Colors.grey),
                   ),
                   const SizedBox(height: 24),
                   const Text('Seleziona Bicicletta *', style: TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   DropdownButtonFormField<String>(
                     value: selectedBikeId,
                     decoration: const InputDecoration(
                       border: OutlineInputBorder(),
                       hintText: 'Scegli dal garage...',
                     ),
                     items: bicycles.map((b) => DropdownMenuItem(
                       value: b.id,
                       child: Text('${b.name} (${b.type})'),
                     )).toList(),
                     onChanged: (val) {
                       setState(() {
                         selectedBikeId = val;
                       });
                     },
                   ),
                   const SizedBox(height: 16),
                   const Text('Seleziona Percorso (Opzionale)', style: TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   DropdownButtonFormField<String>(
                     value: selectedTrackId,
                     decoration: const InputDecoration(
                       border: OutlineInputBorder(),
                       hintText: 'Nessun percorso...',
                     ),
                     items: [
                       const DropdownMenuItem<String>(value: null, child: Text('Nessun percorso')),
                       ...tracks.map((t) => DropdownMenuItem(
                         value: t.id,
                         child: Text(t.displayName),
                       ))
                     ],
                     onChanged: (val) {
                       setState(() {
                         selectedTrackId = val;
                       });
                     },
                   ),
                   const SizedBox(height: 32),
                   SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: FilledButton(
                       onPressed: selectedBikeId == null ? null : () async {
                          Navigator.pop(ctx);
                          await _saveCompletedActivity(selectedBikeId!, selectedTrackId);
                       },
                       child: const Text('Salva e Completa'),
                     ),
                   ),
                   const SizedBox(height: 32),
                 ],
               ),
             );
           }
         );
      },
    );
  }
  
  Future<void> _saveCompletedActivity(String bikeId, String? trackId) async {
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final ride = widget.plannedRide;
    
    try {
      // Find selected bike
      final bike = await db.getBicycleById(bikeId);
      if (bike == null) throw Exception("Bicycle not found");

      // Update bike stats
      bike.totalKilometers = (bike.totalKilometers.isNaN ? 0.0 : bike.totalKilometers) + ride.distance;
      bike.chainKms = (bike.chainKms.isNaN ? 0.0 : bike.chainKms) + ride.distance;
      bike.tyreKms = (bike.tyreKms.isNaN ? 0.0 : bike.tyreKms) + ride.distance;

      // Update dynamic components
      final notify = NotificationService();
      for (var component in bike.components) {
        component.currentKm = (component.currentKm.isNaN ? 0.0 : component.currentKm) + ride.distance;
        
        // Check limits
        if (component.limitKm > 0 && component.currentKm >= component.limitKm * 0.9) {
            await notify.showMaintenanceAlert(
              id: ((bike.id?.hashCode ?? 0) % 100000) * 1000 + bike.components.indexOf(component), 
              title: '⚠️ Manutenzione necessaria su ${bike.name}',
              body: 'Il componente "${component.name}" ha raggiunto ${component.currentKm.toInt()} km. Verifica lo stato!',
            );
        }
      }
      
      await db.updateBicycle(bike);
      
      // Update the ride
      ride.bicycleId = bikeId;
      if (trackId != null) {
        ride.trackId = trackId;
      }
      
      // Remove (Health) tag from name to make it look native
      if (ride.rideName != null) {
         ride.rideName = ride.rideName!.replaceAll('(Health)', '').trim();
      }
      ride.isCompleted = true; // should be already true, but let's be sure
      await db.updatePlannedRide(ride);

       if (mounted) {
         setState(() {
           _assignedBicycle = bike;
         });
         
         if (trackId != null) {
           final ts = TrackService();
           final track = await ts.getTrackById(trackId);
           if (mounted) {
             setState(() {
               _assignedTrack = track;
             });
           }
         }
         
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attività completata e km aggiunti a ${bike.name}!')),
         );
       }
    } catch(e) {
       debugPrint('Error completing activity: $e');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore: non è stato possibile completare l\'attività.'))
         );
       }
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon() {
    final String activityType = widget.plannedRide.rideName ?? "Attività";
    final type = activityType.toUpperCase();
    if (type.contains('CYCLING') || type.contains('BIKING')) {
      return Icons.directions_bike;
    } else if (type.contains('RUNNING')) {
      return Icons.directions_run;
    } else if (type.contains('WALKING')) {
      return Icons.directions_walk;
    } else if (type.contains('SWIMMING')) {
      return Icons.pool;
    } else {
      return Icons.fitness_center;
    }
  }

  Color _getActivityColor() {
    final String activityType = widget.plannedRide.rideName ?? "Attività";
    final type = activityType.toUpperCase();
    if (type.contains('CYCLING') || type.contains('BIKING')) {
      return Colors.blue;
    } else if (type.contains('RUNNING')) {
      return Colors.orange;
    } else if (type.contains('WALKING')) {
      return Colors.green;
    } else if (type.contains('SWIMMING')) {
      return Colors.cyan;
    } else {
      return Colors.purple;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Widget _buildElevationChart() {
    final profile = _routeData!['elevationProfile'] as List<Map<String, double>>;
    if (profile.isEmpty) return const SizedBox();

    final elevations = profile.map((p) => p['elevation']!).toList();
    
    return ElevationProfileWidget(
      elevationProfile: elevations,
      distanceKm: _assignedTrack!.distance,
    );
  }

  Widget _buildClimbsList() {
    final climbs = _routeData!['climbs'] as List<Climb>;
    if (climbs.isEmpty) return const SizedBox();
    
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
            title: Text('${climb.lengthKm.toStringAsFixed(3)} km'),
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
}
