import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/gpx_optimizer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
import '../widgets/elevation_profile_widget.dart';
import '../services/ai_service.dart';
import '../services/track_service.dart';
import '../services/crew_service.dart';
import '../services/crew_service.dart';
import '../services/community_tracks_service.dart';
import '../widgets/terrain_breakdown_widget.dart';
import '../widgets/difficulty_badge.dart';
import '../models/terrain_analysis.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gpx/gpx.dart';

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
  final _aiService = AIService();
  final _trackService = TrackService();
  final _communityService = CommunityTracksService();
  
  bool _isLoading = true;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _routeData;
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    try {
      File? gpxFile;

      // 1. Try local file path from object
      if (widget.track.gpxFilePath != null) {
        final f = File(widget.track.gpxFilePath!);
        if (await f.exists()) {
          gpxFile = f;
        }
      }

      // 2. If no local file, try to download from Cloud
      if (gpxFile == null && widget.track.gpxUrl != null) {
         try {
           final url = await _trackService.getGpxUrl(widget.track);
           if (url != null) {
             // Download
             final response = await http.get(Uri.parse(url));
             if (response.statusCode == 200) {
                // Save to temp
                final dir = await getTemporaryDirectory();
                // Simple sanitize filename
                final filename = widget.track.gpxUrl!.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '');
                final file = File('${dir.path}/$filename');
                await file.writeAsBytes(response.bodyBytes);
                gpxFile = file;
                widget.track.gpxFilePath = file.path; // Update local ref
             }
           }
         } catch(e) {
           debugPrint('Error downloading GPX: $e');
         }
      }

      // 3. Fallback: Check for embedded JSON data (community tracks)
      if (gpxFile == null && widget.track.communityGpxData != null) {
        try {
           debugPrint('Attempting to parse community GPX data...');
           final dynamic parsedJson = jsonDecode(widget.track.communityGpxData!);
           final gpx = GpxOptimizer.jsonToGpx(parsedJson);
           
           final dir = await getTemporaryDirectory();
           final filename = 'community_${widget.track.id ?? "temp"}.gpx';
           final file = File('${dir.path}/$filename');
           
           // Write XML string to file
           final xmlString = GpxWriter().asString(gpx, pretty: true);
           await file.writeAsString(xmlString);
           
           gpxFile = file;
           debugPrint('Community GPX converted to file: ${file.path}');
        } catch (e, stack) {
           debugPrint('Error parsing community GPX data: $e');
           debugPrint(stack.toString());
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Dati traccia non validi: $e')),
             );
           }
        }
      } else if (gpxFile == null && widget.track.gpxUrl == null) {
         debugPrint('No GPX file or URL found for track.');
      }

      if (gpxFile == null) {
        if (mounted) setState(() => _isLoading = false);
        if (_routeData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mappa non trovata. (Files: ${widget.track.gpxFilePath ?? "no"}, URL: ${widget.track.gpxUrl ?? "no"}, Data: ${widget.track.communityGpxData != null ? "yes" : "no"})')),
            // Debug info in snackbar to help user report issue
          );
        }
        return;
      }
      
      _routeData = await _gpxService.parseGpxFile(gpxFile);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (_routeData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossibile caricare la mappa della traccia.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore caricamento traccia: $e')),
        );
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
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'Pubblica in Community',
            onPressed: _showPublishDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Elimina traccia',
            onPressed: _showDeleteConfirmation,
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

                        // AI Analysis Card
                        Text(
                          'Analisi Butler AI',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildAIAnalysisCard(),
                        const SizedBox(height: 24),
                        
                        // Track Metadata
                        
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
                _buildStat(Icons.route, '${widget.track.distance.toStringAsFixed(3)} km', 'Distanza'),
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
            // Terrain Breakdown (if available from BRouter)
            if (widget.track.asphaltPercent != null) ...[
              const Divider(height: 32),
              TerrainBreakdownWidget(
                terrain: TerrainBreakdown(
                  asphaltPercent: widget.track.asphaltPercent!,
                  gravelPercent: widget.track.gravelPercent!,
                  pathPercent: widget.track.pathPercent!,
                ),
                compact: false,
              ),
            ],
            // Difficulty Rating (if available from BRouter)
            if (widget.track.difficultyLevel != null) ...[
              const Divider(height: 32),
              Center(
                child: DifficultyBadge(
                  difficulty: difficultyFromLevel(widget.track.difficultyLevel!),
                  showLabel: true,
                  showLevel: true,
                ),
              ),
            ],
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

    // Extract just elevation values for ElevationProfileWidget
    final elevations = profile.map((p) => p['elevation']!).toList();
    
    return ElevationProfileWidget(
      elevationProfile: elevations,
      distanceKm: widget.track.distance,
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
            const Divider(),
            _buildMetadataRow(Icons.fingerprint, 'ID Sistema', widget.track.id ?? 'N/A'),
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

  Widget _buildAIAnalysisCard() {
    final hasAnalysis = widget.track.description != null && widget.track.description!.isNotEmpty;
    
    return Card(
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
                Expanded(
                  child: Text(
                    hasAnalysis ? 'Strategia "Il Biciclista"' : 'Ottieni consigli strategici',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (hasAnalysis && !_isAnalyzing)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generateAnalysis,
                    tooltip: 'Rigenera analisi',
                  ),
              ],
            ),
            const Divider(),
            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analisi del percorso in corso...'),
                    Text('Sto studiando altimetria e terreno 🚵'),
                  ],
                ),
              ),
            )
            else if (hasAnalysis)
              Text(
                widget.track.description!,
                style: const TextStyle(fontSize: 15, height: 1.4),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Text(
                        'Vuoi consigli su ritmo, nutrizione e difficoltà?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _generateAnalysis,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('✨ Analizza con Butler'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAnalysis() async {
    setState(() => _isAnalyzing = true);
    
    try {
      final analysis = await _aiService.analyzeTrack(widget.track);
      
      setState(() {
        widget.track.description = analysis;
        _isAnalyzing = false;
      });
      
      await _trackService.updateTrack(widget.track);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analisi completata e salvata! 🚴')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore analisi: $e')),
        );
      }
    }
  }

  void _showScheduleDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    String? customName;
    
    // Always group ride (Social-First)
    String difficulty = 'medium';
    String meetingPoint = '';
    bool isPublic = true; // Default pubblico
    final meetingPointController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Proponi alla Crew'),
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
                Text('${widget.track.distance.toStringAsFixed(3)} km • ${widget.track.elevation.toStringAsFixed(0)} m'),
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

                // Time picker
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Ora'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.edit),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),

                const Divider(height: 24),
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
                if (meetingPoint.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inserisci un punto di ritrovo per le uscite di gruppo')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                await _scheduleRide(
                  selectedDate,
                  selectedTime,
                  customName,
                  difficulty,
                  meetingPoint,
                  isPublic,
                );
              },
              child: const Text('Proponi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleRide(
    DateTime date,
    TimeOfDay time,
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
      
      
      // Combine date and time
      final rideDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      
      final ride = PlannedRide()
        ..rideDate = rideDateTime
        ..rideName = customName ?? widget.track.name
        ..trackId = widget.track.id
        ..isGroupRide = true // Always group ride (Social-First)
        ..distance = widget.track.distance
        ..elevation = widget.track.elevation
        ..latitude = centerLat
        ..longitude = centerLng
        ..gpxFilePath = widget.track.gpxFilePath;

      ride.track = widget.track;
      await _db.createPlannedRide(ride);

      // Always sync to Supabase (Social-First)
      await _syncGroupRideToSupabase(
        ride: ride,
        difficulty: difficulty,
        meetingPoint: meetingPoint,
        isPublic: isPublic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uscita proposta alla Crew! 🚴‍♂️👥'),
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
          'elevationProfile': _routeData!['elevationProfile'], 
        };
      }

      // Use CrewService to create group ride (auto-joins creator as participant)
      final crewService = CrewService();
      await crewService.createGroupRide(
        rideName: ride.rideName ?? widget.track.name,
        description: ride.track?.description,
        gpxData: gpxDataForDb,
        distance: ride.distance,
        elevation: ride.elevation,
        meetingPoint: meetingPoint,
        meetingLatitude: ride.latitude,
        meetingLongitude: ride.longitude,
        meetingTime: ride.rideDate,
        difficultyLevel: difficulty,
        isPublic: isPublic,
      );
      
      // Mark as synced
      ride.supabaseEventId = 'synced_${DateTime.now().millisecondsSinceEpoch}';
      await _db.updatePlannedRide(ride);
      
      debugPrint('Group ride synced to Supabase successfully');
    } catch (e) {
      debugPrint('Error syncing group ride to Supabase: $e');
      // Non bloccare l'utente se sync fallisce
    }
  }


  void _showPublishDialog() {
    if (widget.track.gpxFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile pubblicare: nessun file GPX associato')),
      );
      return;
    }

    String difficulty = 'medium';
    String region = widget.track.region ?? '';
    String trackType = widget.track.terrainType;
    String description = widget.track.description ?? '';
    bool isPublic = true;
    final regionController = TextEditingController(text: region);
    final descController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pubblica in Community'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Condividi "${widget.track.name}" con gli altri ciclisti!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: difficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficoltà',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'easy', child: Text('🟢 Facile')),
                    DropdownMenuItem(value: 'medium', child: Text('🟡 Media')),
                    DropdownMenuItem(value: 'hard', child: Text('🔴 Difficile')),
                    DropdownMenuItem(value: 'expert', child: Text('🟣 Expert')),
                  ],
                  onChanged: (value) => setDialogState(() => difficulty = value!),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: trackType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo Terreno',
                    prefixIcon: Icon(Icons.terrain),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'road', child: Text('Strada')),
                    DropdownMenuItem(value: 'gravel', child: Text('Gravel')),
                    DropdownMenuItem(value: 'mtb', child: Text('MTB')),
                    DropdownMenuItem(value: 'mixed', child: Text('Misto')),
                  ],
                  onChanged: (value) => setDialogState(() => trackType = value!),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: regionController,
                  decoration: const InputDecoration(
                    labelText: 'Regione / Zona',
                    prefixIcon: Icon(Icons.map),
                    hintText: 'es. Toscana, Chianti',
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione (opzionale)',
                    hintText: 'Racconta qualcosa su questo percorso...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.public),
              label: const Text('Pubblica'),
              onPressed: () async {
                Navigator.pop(context);
                await _publishTrack(
                  difficulty,
                  trackType,
                  regionController.text,
                  descController.text,
                  isPublic,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishTrack(
    String difficulty,
    String trackType,
    String? region,
    String? description,
    bool isPublic,
  ) async {
    setState(() => _isLoading = true);
    
    try {
      // Parse local GPX
      final file = File(widget.track.gpxFilePath!);
      if (!await file.exists()) throw Exception('File GPX non trovato');
      
      final gpxString = await file.readAsString();
      final gpx = GpxReader().fromString(gpxString);
      
      await _communityService.publishTrack(
        trackName: widget.track.name,
        description: description,
        gpx: gpx,
        distance: widget.track.distance,
        elevation: widget.track.elevation,
        duration: widget.track.duration,
        difficultyLevel: difficulty,
        region: region,
        trackType: trackType,
        isPublic: isPublic,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Traccia pubblicata con successo! 🌍'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore pubblicazione: $e')),
        );
      }
    }
  }
  
  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina traccia'),
        content: Text(
          'Sei sicuro di voler eliminare "${widget.track.name}"?\n\n'
          'Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      if (widget.track.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore: ID traccia non valido. Riprova più tardi.')),
        );
        return;
      }

      try {
        await _trackService.deleteTrack(widget.track.id!);
        
        if (mounted) {
          Navigator.pop(context); // Torna alla Routes Library
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Traccia eliminata')),
          );
        }
      } catch (e) {
        if (mounted && e.toString().contains('Impossibile eliminare')) {
          // Show force delete dialog
          final forceConfirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Traccia in uso'),
              content: const Text(
                'Questa traccia è usata in alcune uscite pianificate.\n'
                'Vuoi eliminarla comunque? Le uscite verranno mantenute ma senza traccia associata.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Elimina Comunque'),
                ),
              ],
            ),
          );

          if (forceConfirm == true && mounted) {
            try {
              if (widget.track.id != null) await _trackService.deleteTrackAndUnlink(widget.track.id!);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Traccia eliminata')),
                );
              }
            } catch (e2) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Errore eliminazione forzata: $e2')),
                );
              }
            }
          }
        } else {
          if (mounted) {
            debugPrint('Delete error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore eliminazione: ${e.toString().replaceAll("Exception:", "")}')),
            );
          }
        }
      }
    }
  }
}
