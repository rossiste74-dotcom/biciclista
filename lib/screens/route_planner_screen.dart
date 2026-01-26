import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpx/gpx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/route_planning_service.dart';
import '../services/database_service.dart';
import '../services/track_service.dart';
import '../models/planned_ride.dart';
import '../services/ai_service.dart';
import '../widgets/elevation_profile_widget.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _planningService = RoutePlanningService();
  final _mapController = MapController();
  
  // State
  final List<RouteSegment> _segments = [];
  final List<LatLng> _allPoints = []; // Unified geometry for display
  final List<Marker> _markers = [];
  
  // Selection
  RouteProfile _selectedProfile = RouteProfile.asphalt;
  
  // Stats
  double _totalDistanceKm = 0.0;
  double _totalElevationM = 0.0;
  
  // API Key (in memory for now)
  String? _graphHopperKey;
  
  bool _isLoading = false;
  
  // Schedule toggle
  bool _scheduleNow = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  
  // Adventure mode
  bool _isAdventureMode = false;
  LatLng? _adventureStart;
  ElevationPreference _adventureElevation = ElevationPreference.balanced;
  double? _adventureMaxDistance = 50.0;
  
  // Custom Adventure Settings
  double _adventureRoughness = 1.0; // 0.0-5.0
  bool _adventureAvoidTraffic = true;
  int _adventureTechnicalDifficulty = 1; // 0=Easy, 1=Medium, 2=Hard
  
  // Standard Routing Options
  int _selectedAlternative = 0; // 0=Original, 1-3=Alternatives

  @override
  void initState() {
    super.initState();
    // Locate user on startup
    _locateUser();
  }

  Future<void> _locateUser() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        _mapController.move(LatLng(position.latitude, position.longitude), 13);
      }
    } catch (e) {
      debugPrint('Locate error: $e');
    }
  }

  void _handleTap(TapPosition tapPos, LatLng point) async {
    if (_isLoading) return;

    // Adventure mode: handle start -> destination
    if (_isAdventureMode) {
      if (_adventureStart == null) {
        // First tap: set start
        setState(() {
          _adventureStart = point;
          _markers.add(_buildAdventureMarker(point, isStart: true));
        });
        return;
      } else {
        // Second tap: set destination and generate route
        _generateAdventureRoute(point);
        return;
      }
    }

    // Normal mode: manual waypoint routing
    // 1. If first point
    if (_markers.isEmpty) {
      setState(() {
        _markers.add(_buildMarker(point, isStart: true));
        _allPoints.add(point); // Start point
      });
      return;
    }

    // 2. Routing from last point
    final lastPoint = _allPoints.isNotEmpty ? _allPoints.last : _segments.last.geometry.last; // Fallback
    // Actually _allPoints should track the very end.
    
    setState(() => _isLoading = true);

    try {
      final segment = await _planningService.getRouteSegment(
        start: lastPoint,
        end: point,
        profile: _selectedProfile,
        graphHopperKey: _graphHopperKey,
        alternativeIndex: _selectedAlternative,
      );

      if (segment != null) {
        setState(() {
          _segments.add(segment);
          _allPoints.addAll(segment.geometry.skip(1)); // Avoid duplicating start point of segment
          _markers.add(_buildMarker(point)); // Intermediate marker
          
          _totalDistanceKm += segment.distanceKm;
          _totalElevationM += segment.elevationGainM;
        });
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Impossibile tracciare il percorso. Riprova o controlla la connessione.')),
         );
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Marker _buildMarker(LatLng point, {bool isStart = false}) {
    return Marker(
      point: point,
      width: 20,
      height: 20,
      child: Icon(
        Icons.circle,
        size: 12,
        color: isStart ? Colors.green : Colors.blue,
      ),
    );
  }
  
  void _undoLast() {
    if (_segments.isEmpty && _markers.isNotEmpty) {
      // Only start point exists
      setState(() {
        _markers.clear();
        _allPoints.clear();
      });
      return;
    }
    
    if (_segments.isEmpty) return;

    setState(() {
      final removed = _segments.removeLast();
      _totalDistanceKm -= removed.distanceKm;
      _totalElevationM -= removed.elevationGainM;
      _markers.removeLast();
      
      // Rebuild _allPoints from remaining segments
      // Or just remove the tail matching removed geometry
      // Easier to rebuild to be safe
      _allPoints.clear();
      if (_markers.isNotEmpty) {
        _allPoints.add(_markers.first.point); // Start
        for (final seg in _segments) {
             _allPoints.addAll(seg.geometry.skip(1));
        }
      }
    });
  }
  
  Future<void> _recalculateRoute() async {
    if (_segments.isEmpty) return;
    
    // Confirm dialog removed as per user request
    // proceeding directly to recalculation
    
    // final bool confirm = await showDialog(...)

    setState(() => _isLoading = true);
    
    // We need the original waypoints (markers).
    // Logic: clear segments, iterate markers pairwise, fetch new route.
    
    final waypoints = _markers.map((m) => m.point).toList();
    // Do NOT call _clearRouteState(keepStart: true) because it removes markers!
    // We want to keep the same markers (waypoints) and just find new paths between them.
    
    // Hard reset of generated data only
    _segments.clear();
    _allPoints.clear();
    _totalDistanceKm = 0;
    _totalElevationM = 0;
    _allPoints.add(waypoints.first); // Re-add start
    
    try {
      for (int i = 0; i < waypoints.length - 1; i++) {
        final start = waypoints[i];
        final end = waypoints[i+1];
        
        final segment = await _planningService.getRouteSegment(
          start: start, 
          end: end, 
          profile: _selectedProfile,
          graphHopperKey: _graphHopperKey,
          alternativeIndex: _selectedAlternative,
        );
        
        if (segment != null) {
          _segments.add(segment);
          _allPoints.addAll(segment.geometry.skip(1));
          _totalDistanceKm += segment.distanceKm;
          _totalElevationM += segment.elevationGainM;
        } else {
           throw Exception('Segment failure at index $i');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore ricalcolo: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _clearRouteState({bool keepStart = false}) {
     if (!keepStart) {
       _markers.clear();
       _allPoints.clear();
       _segments.clear();
       _totalDistanceKm = 0;
       _totalElevationM = 0;
     } else {
       // Keep only the first marker/point
       if (_markers.isNotEmpty) {
         final start = _markers.first;
         _markers.clear();
         _markers.add(start);
       }
       if (_allPoints.isNotEmpty) {
         final start = _allPoints.first;
         _allPoints.clear();
         _allPoints.add(start);
       }
       _segments.clear();
       _totalDistanceKm = 0;
       _totalElevationM = 0;
     }
  }
  
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => _SaveTrackDialog(
        distanceKm: _totalDistanceKm,
        elevationM: _totalElevationM,
        onSave: (name, scheduleNow, date) {
          _scheduleNow = scheduleNow;
          _selectedDate = date;
          _saveGpx(trackName: name);
        },
      ),
    );
  }
  
  Future<void> _saveGpx({String? trackName}) async {
    if (_allPoints.length < 2) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Create GPX content
      final gpx = Gpx();
      final trk = Trk(name: trackName ?? 'Percorso Disegnato ${DateTime.now().day}/${DateTime.now().month}');
      final seg = Trkseg();
      
      for (final segment in _segments) {
        // Map geometry points to GPX waypoints with elevation
        for (int i = 0; i < segment.geometry.length; i++) {
          // Skip first point of subsequent segments to avoid duplicates
          if (seg.trkpts.isNotEmpty && i == 0) continue;
          
          final point = segment.geometry[i];
          final ele = (segment.elevationProfile != null && i < segment.elevationProfile!.length)
              ? segment.elevationProfile![i]
              : 0.0;
              
          seg.trkpts.add(Wpt(lat: point.latitude, lon: point.longitude, ele: ele));
        }
      }
      
      trk.trksegs.add(seg);
      gpx.trks.add(trk);
      gpx.creator = 'Biciclista App - BRouter';
      
      final gpxString = GpxWriter().asString(gpx, pretty: true);
      
      // 2. Save to file
      final dir = await getApplicationDocumentsDirectory();
      final gpxDir = Directory('${dir.path}/gpx_files');
      if (!await gpxDir.exists()) {
        await gpxDir.create(recursive: true);
      }
      
      final fileName = 'route_${DateTime.now().millisecondsSinceEpoch}.gpx';
      final file = File('${gpxDir.path}/$fileName');
      await file.writeAsString(gpxString);
      
      // 3. Detect terrain from profile
      String terrainType = 'road';
      if (_selectedProfile == RouteProfile.gravel) terrainType = 'gravel';
      if (_selectedProfile == RouteProfile.mtb) terrainType = 'mtb';
      
      // 4. Calculate center for lat/lng
      double sumLat = 0;
      double sumLng = 0;
      for (var p in _allPoints) {
        sumLat += p.latitude;
        sumLng += p.longitude;
      }
      final centerLat = sumLat / _allPoints.length;
      final centerLng = sumLng / _allPoints.length;
      
      // Aggregate terrain breakdown from all segments
      double totalAsphalt = 0, totalGravel = 0, totalPath = 0;
      double difficultySum = 0;
      int segmentsWithTerrain = 0;
      int segmentsWithDifficulty = 0;
      
      for (var segment in _segments) {
        if (segment.terrainBreakdown != null) {
          totalAsphalt += segment.terrainBreakdown!.asphaltPercent;
          totalGravel += segment.terrainBreakdown!.gravelPercent;
          totalPath += segment.terrainBreakdown!.pathPercent;
          segmentsWithTerrain++;
        }
        if (segment.difficulty != null) {
          // Convert enum to int manually
          final level = segment.difficulty!.index + 1; // beginner=0 -> 1, etc.
          difficultySum += level;
          segmentsWithDifficulty++;
        }
      }
      
      // Calculate averages
      final asphaltPercent = segmentsWithTerrain > 0 ? totalAsphalt / segmentsWithTerrain : null;
      final gravelPercent = segmentsWithTerrain > 0 ? totalGravel / segmentsWithTerrain : null;
      final pathPercent = segmentsWithTerrain > 0 ? totalPath / segmentsWithTerrain : null;
      final difficultyLevel = segmentsWithDifficulty > 0 ? (difficultySum / segmentsWithDifficulty).round() : null;

      if (_scheduleNow) {
        
        // Create Track + PlannedRide
        final trackService = TrackService();
        final track = await trackService.createTrack(
          name: trackName ?? 'Percorso Disegnato',
          gpxFilePath: file.path,
          distance: _totalDistanceKm,
          elevation: _totalElevationM,
          terrainType: terrainType,
          source: 'manual',
          asphaltPercent: asphaltPercent,
          gravelPercent: gravelPercent,
          pathPercent: pathPercent,
          difficultyLevel: difficultyLevel,
        );
        
        final db = DatabaseService();
        final plannedRide = PlannedRide()
          ..trackId = track.id
          ..rideDate = _selectedDate
          ..rideName = trackName ?? 'Giro Disegnato'
          ..distance = _totalDistanceKm
          ..elevation = _totalElevationM
          ..latitude = centerLat
          ..longitude = centerLng
          ..gpxFilePath = file.path;
        
        plannedRide.track = track;
        
        // Generate AI Analysis
        final aiService = AIService();
        if (await aiService.isConfigured() && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Generazione analisi AI in corso...'),
               duration: Duration(seconds: 2),
             ),
           );
           
           try {
             final analysis = await aiService.analyzeRide(plannedRide);
             plannedRide.aiAnalysis = analysis;
           } catch (e) {
             debugPrint('AI Analysis failed: $e');
             // Continue saving
           }
        }
        
        await db.createPlannedRide(plannedRide);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uscita pianificata e salvata!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create Track only
        final trackService = TrackService();
        await trackService.createTrack(
          name: trackName ?? 'Percorso Disegnato',
          gpxFilePath: file.path,
          distance: _totalDistanceKm,
          elevation: _totalElevationM,
          terrainType: terrainType,
          source: 'manual',
          asphaltPercent: asphaltPercent,
          gravelPercent: gravelPercent,
          pathPercent: pathPercent,
          difficultyLevel: difficultyLevel,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Traccia salvata in "Le Mie Tracce"!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore salvataggio: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAdventureMode ? '🧭 Modalità Avventura' : 'Crea Percorso'),
        leading: _isAdventureMode 
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelAdventureMode,
              tooltip: 'Annulla Avventura',
            )
          : null,
        actions: [
          if (!_isAdventureMode) ...[
            IconButton(
              icon: const Icon(Icons.explore),
              tooltip: 'Percorso Avventura',
              onPressed: _showAdventureDialog,
              color: Colors.orange,
            ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Genera Percorso Automatico',
              onPressed: _showGeneratorDialog,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _segments.isEmpty ? null : () => _showSaveDialog(),
            ),
          ] else ...[
            // In adventure mode: show cancel and info
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_adventureStart == null 
                      ? 'Tocca la mappa per scegliere la partenza'
                      : 'Tocca la mappa per scegliere la destinazione'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(45.4642, 9.1900), // Milan default
                    initialZoom: 13,
                    onTap: _handleTap,
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
                     if (_allPoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _allPoints,
                            strokeWidth: 4,
                            color: _getProfileColor(_selectedProfile),
                          ),
                        ],
                      ),
                    MarkerLayer(markers: _markers),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'my_loc',
                      onPressed: _locateUser,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'undo',
                      onPressed: _undoLast,
                      child: const Icon(Icons.undo),
                    ),
                  ),
              ],
            ),
          ),
          _buildControlPanel(),
        ],
      ),
    );
  }
  
  Widget _buildControlPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Distanza', '${_totalDistanceKm.toStringAsFixed(1)} km'),
              _statItem('Dislivello', '${_totalElevationM.toStringAsFixed(0)} m'),
            ],
          ),
          const SizedBox(height: 12),
          // Elevation Profile
          if (_segments.isNotEmpty && _getAllElevations().isNotEmpty)
            ElevationProfileWidget(
              elevationProfile: _getAllElevations(),
              distanceKm: _totalDistanceKm,
            ),
          if (_segments.isNotEmpty) const SizedBox(height: 12),
          // Terrain Selector
          SegmentedButton<RouteProfile>(
            segments: const [
              ButtonSegment(value: RouteProfile.asphalt, label: Text('Asfalto')),
              ButtonSegment(value: RouteProfile.gravel, label: Text('Gravel')),
              ButtonSegment(value: RouteProfile.mtb, label: Text('MTB')),
            ],
            selected: {_selectedProfile},
            onSelectionChanged: (Set<RouteProfile> newSelection) {
              setState(() {
                _selectedProfile = newSelection.first;
              });
              // Optional: Show snackbar "Profile changed. Press Ricalcola to update existing path"
              // Or automatically show a Ricalcola button if segments exist.
              if (_segments.isNotEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Text('Profilo cambiato.'),
                     action: SnackBarAction(label: 'Ricalcola', onPressed: _recalculateRoute),
                     duration: const Duration(seconds: 4),
                   )
                 );
              }
            },
            showSelectedIcon: false,
          ),
          const SizedBox(height: 12),
          // Alternative Selector
          const Align(alignment: Alignment.centerLeft, child: Text('Variante:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Orig')),
                ButtonSegment(value: 1, label: Text('Alt 1')),
                ButtonSegment(value: 2, label: Text('Alt 2')),
                ButtonSegment(value: 3, label: Text('Alt 3')),
              ],
              selected: {_selectedAlternative},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedAlternative = newSelection.first;
                });
                if (_segments.isNotEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: const Text('Variante cambiata.'),
                       action: SnackBarAction(label: 'Ricalcola', onPressed: _recalculateRoute),
                       duration: const Duration(seconds: 4),
                     )
                   );
                }
              },
              showSelectedIcon: false,
              style: const ButtonStyle(
                 visualDensity: VisualDensity.compact,
                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Color _getProfileColor(RouteProfile p) {
    switch (p) {
      case RouteProfile.asphalt: return Colors.grey.shade700;
      case RouteProfile.gravel: return Colors.brown;
      case RouteProfile.mtb: return Colors.green.shade700;
    }
  }
  
  String _profileName(RouteProfile p) => p.toString().split('.').last.toUpperCase();
  
  /// Get all elevation points from all segments
  List<double> _getAllElevations() {
    final elevations = <double>[];
    for (final segment in _segments) {
      if (segment.elevationProfile != null) {
        if (elevations.isEmpty) {
          elevations.addAll(segment.elevationProfile!);
        } else {
          // Skip first point to avoid duplication
          elevations.addAll(segment.elevationProfile!.skip(1));
        }
      }
    }
    return elevations;
  }

  void _showSettingsDialog() {
     final controller = TextEditingController(text: _graphHopperKey ?? '');
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: const Text('Impostazioni Router'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Text('Inserisci API Key GraphHopper per supporto Gravel/MTB:'),
             TextField(controller: controller, decoration: const InputDecoration(hintText: 'API Key')),
             const SizedBox(height: 8),
             const Text('Start Point Lat/Lng (Opzionale, cliccando Mappa è meglio)', style: TextStyle(fontSize: 10)),
           ],
         ),
         actions: [
           TextButton(onPressed: () {
             setState(() => _graphHopperKey = controller.text.trim());
             Navigator.pop(ctx);
           }, child: const Text('Salva'))
         ],
       )
     );
  }

  void _showGeneratorDialog() {
    double distance = 30.0;
    RouteType type = RouteType.loop;
    RouteProfile profile = _selectedProfile;
    ElevationPreference elevation = ElevationPreference.balanced;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateUi) => AlertDialog(
          title: const Text('Magic Route Gen ✨'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Genera un percorso automaticamente partendo dal centro mappa attuale.'),
                const SizedBox(height: 16),
                const Text('Distanza desiderata:'),
                Row(
                  children: [
                     Expanded(
                       child: Slider(
                         value: distance,
                         min: 10,
                         max: 150,
                         divisions: 14,
                         label: '${distance.round()} km',
                         onChanged: (v) => setStateUi(() => distance = v),
                       ),
                     ),
                     Text('${distance.round()} km'),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Tipo Percorso:'),
                const SizedBox(height: 8),
                SegmentedButton<RouteType>(
                  segments: const [
                    ButtonSegment(value: RouteType.loop, label: Text('Anello'), icon: Icon(Icons.loop)),
                    ButtonSegment(value: RouteType.outAndBack, label: Text('A/R'), icon: Icon(Icons.swap_calls)),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setStateUi(() => type = s.first),
                ),
                const SizedBox(height: 12),
                const Text('Preferenza Dislivello:'),
                const SizedBox(height: 8),
                SegmentedButton<ElevationPreference>(
                  segments: const [
                    ButtonSegment(value: ElevationPreference.flat, label: Text('Piatto'), icon: Icon(Icons.trending_flat)), // Flat
                    ButtonSegment(value: ElevationPreference.balanced, label: Text('Medio'), icon: Icon(Icons.terrain)),     // Balanced
                    ButtonSegment(value: ElevationPreference.hilly, label: Text('Alto'), icon: Icon(Icons.landscape)),       // Hills/Mountains
                  ],
                  selected: {elevation},
                  onSelectionChanged: (s) => setStateUi(() => elevation = s.first),
                ),
                 const SizedBox(height: 12),
                const Text('Terreno:'),
                 DropdownButton<RouteProfile>(
                   value: profile,
                   isExpanded: true,
                   items: RouteProfile.values.map((p) => DropdownMenuItem(
                     value: p,
                     child: Text(_profileName(p)),
                   )).toList(),
                   onChanged: (p) => setStateUi(() => profile = p!),
                 ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _generateAutoRoute(distance, type, profile, elevation);
              }, 
              child: const Text('Genera')
            ),
          ],
        ),
      )
    );
  }
  
  Future<void> _generateAutoRoute(double distanceKm, RouteType type, RouteProfile profile, ElevationPreference elevation) async {
    setState(() => _isLoading = true);
    
    // Clear previous
    _segments.clear();
    _allPoints.clear();
    _markers.clear();
    _totalDistanceKm = 0;
    _totalElevationM = 0;
    
    try {
      final center = _mapController.camera.center;
      
      final route = await _planningService.generateRoute(
        start: center,
        distanceKm: distanceKm,
        type: type,
        profile: profile,
        elevation: elevation,
        graphHopperKey: _graphHopperKey,
      );
      
      if (route != null) {
        _segments.add(route);
        _allPoints.addAll(route.geometry);
        _totalDistanceKm = route.distanceKm;
        _totalElevationM = route.elevationGainM;
        
        // Markers
        _markers.add(_buildMarker(route.geometry.first, isStart: true));
        _markers.add(_buildMarker(route.geometry.last)); // End
        
        // Turnaround marker
        if (type == RouteType.outAndBack) {
           final midIndex = route.geometry.length ~/ 2;
           if (midIndex < route.geometry.length) {
              _markers.add(
                Marker(
                  point: route.geometry[midIndex],
                  width: 30,
                  height: 30,
                  child: const Icon(Icons.u_turn_left, color: Colors.orange, size: 24),
                )
              );
           }
        }
        
        // Fit bounds
        if (_allPoints.isNotEmpty) {
           double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
           for (var p in _allPoints) {
             if (p.latitude < minLat) minLat = p.latitude;
             if (p.latitude > maxLat) maxLat = p.latitude;
             if (p.longitude < minLng) minLng = p.longitude;
             if (p.longitude > maxLng) maxLng = p.longitude;
           }
           _mapController.fitCamera(
             CameraFit.bounds(
               bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
               padding: const EdgeInsets.all(40),
             )
           );
        }
        
        setState(() {
          _selectedProfile = profile; 
        });
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Percorso generato!')));
        
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generazione fallita. Riprova.')));
      }
    } catch (e) {
      debugPrint('Gen error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Adventure mode methods
  
  Marker _buildAdventureMarker(LatLng point, {bool isStart = false}) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: Icon(
        isStart ? Icons.explore : Icons.flag_circle,
        color: isStart ? Colors.orange : Colors.deepOrange,
        size: 40,
      ),
    );
  }
  
  Future<void> _generateAdventureRoute(LatLng destination) async {
    if (_adventureStart == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final route = await _planningService.generateAdventureRoute(
        start: _adventureStart!,
        destination: destination,
        maxDistanceKm: _adventureMaxDistance,
        elevation: _adventureElevation,
        roughnessFactor: _adventureRoughness,
        avoidTraffic: _adventureAvoidTraffic,
        technicalDifficulty: _adventureTechnicalDifficulty,
      );
      
      if (route != null) {
        setState(() {
          _segments.clear();
          _allPoints.clear();
          _markers.clear();
          
          _segments.add(route);
          _allPoints.addAll(route.geometry);
          _totalDistanceKm = route.distanceKm;
          _totalElevationM = route.elevationGainM;
          
          _markers.add(_buildAdventureMarker(route.geometry.first, isStart: true));
          _markers.add(_buildAdventureMarker(route.geometry.last));
          
          _isAdventureMode = false;
          _adventureStart = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🏞️ Percorso Avventura generato: ${route.distanceKm.toStringAsFixed(1)} km'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _adventureMaxDistance != null 
                  ? 'Impossibile generare percorso entro ${_adventureMaxDistance!.toStringAsFixed(0)} km'
                  : 'Impossibile generare il percorso. Riprova con una destinazione diversa.',
              ),
            ),
          );
        }
        setState(() {
          _markers.clear();
          _adventureStart = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
      setState(() {
        _markers.clear();
        _adventureStart = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showAdventureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateUi) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.explore, color: Colors.orange),
              SizedBox(width: 8),
              Text('Percorso Avventura 🏞️'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Genera un percorso che massimizza sentieri e punti panoramici evitando strade trafficate.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                const Text('Preferenza Dislivello:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<ElevationPreference>(
                  segments: const [
                    ButtonSegment(
                      value: ElevationPreference.flat, 
                      label: Text('Piatto'),
                      icon: Icon(Icons.trending_flat, size: 18),
                    ),
                    ButtonSegment(
                      value: ElevationPreference.balanced, 
                      label: Text('Medio'),
                      icon: Icon(Icons.terrain, size: 18),
                    ),
                    ButtonSegment(
                      value: ElevationPreference.hilly, 
                      label: Text('Alto'),
                      icon: Icon(Icons.landscape, size: 18),
                    ),
                  ],
                  selected: {_adventureElevation},
                  onSelectionChanged: (s) => setStateUi(() => _adventureElevation = s.first),
                  showSelectedIcon: false,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Flexible(
                      child: Text('Distanza Max (opzionale):', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _adventureMaxDistance != null 
                        ? '${_adventureMaxDistance!.round()} km'
                        : 'Illimitata',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Slider(
                  value: _adventureMaxDistance ?? 100,
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: _adventureMaxDistance != null 
                    ? '${_adventureMaxDistance!.round()} km' 
                    : 'Illimitata',
                  onChanged: (v) => setStateUi(() => _adventureMaxDistance = v),
                ),
                TextButton(
                  onPressed: () => setStateUi(() => _adventureMaxDistance = null),
                  child: const Text('Rimuovi limite'),
                ),
                
                const Divider(),
                const SizedBox(height: 8),

                // Roughness Slider
                Row(
                  children: [
                    const Text('Fattore Sterrato:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(_adventureRoughness.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _adventureRoughness,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  label: _adventureRoughness.toStringAsFixed(1),
                  onChanged: (v) => setStateUi(() => _adventureRoughness = v),
                ),
                const Center(
                   child: Text(
                     '0 = Liscio/Asfalto  <-->  5 = Tecnico/Sconnesso',
                     style: TextStyle(fontSize: 10, color: Colors.grey),
                   ),
                ),
                const SizedBox(height: 16),

                // Traffic Switch
                SwitchListTile(
                  title: const Text('Evita Traffico', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Evita strade principali e secondarie'),
                  value: _adventureAvoidTraffic,
                  onChanged: (v) => setStateUi(() => _adventureAvoidTraffic = v),
                  contentPadding: EdgeInsets.zero,
                ),
                
                const SizedBox(height: 8),
                
                // Technical Difficulty
                const Text('Difficoltà Tecnica:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                     ButtonSegment(value: 0, label: Text('Facile'), icon: Icon(Icons.emoji_nature)),
                     ButtonSegment(value: 1, label: Text('Medio'), icon: Icon(Icons.directions_bike)),
                     ButtonSegment(value: 2, label: Text('Difficile'), icon: Icon(Icons.terrain)),
                  ],
                  selected: {_adventureTechnicalDifficulty},
                  onSelectionChanged: (s) => setStateUi(() => _adventureTechnicalDifficulty = s.first),
                ),

                
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  '📍 Tocca la mappa due volte:\n1° Partenza\n2° Destinazione',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _startAdventureMode();
              },
              icon: const Icon(Icons.explore),
              label: const Text('Seleziona sulla Mappa'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _startAdventureMode() {
    setState(() {
      _isAdventureMode = true;
      _adventureStart = null;
      _segments.clear();
      _allPoints.clear();
      _markers.clear();
      _totalDistanceKm = 0;
      _totalElevationM = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧭 Modalità Avventura attiva! Tocca la mappa per la partenza'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _cancelAdventureMode() {
    setState(() {
      _isAdventureMode = false;
      _adventureStart = null;
      _markers.clear();
    });
  }
}

class _SaveTrackDialog extends StatefulWidget {
  final double distanceKm;
  final double elevationM;
  final Function(String name, bool scheduleNow, DateTime date) onSave;

  const _SaveTrackDialog({
    required this.distanceKm,
    required this.elevationM,
    required this.onSave,
  });

  @override
  State<_SaveTrackDialog> createState() => _SaveTrackDialogState();
}

class _SaveTrackDialogState extends State<_SaveTrackDialog> {
  late final TextEditingController _nameController;
  bool _scheduleNow = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Salva Percorso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.distanceKm.toStringAsFixed(1)} km • ${widget.elevationM.toStringAsFixed(0)} m',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            
            // Track name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome della traccia',
                hintText: 'es. Giro del Lago',
                prefixIcon: const Icon(Icons.route),
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              onChanged: (value) {
                if (_errorText != null && value.trim().isNotEmpty) {
                  setState(() => _errorText = null);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Schedule toggle
            SwitchListTile(
              value: _scheduleNow,
              onChanged: (value) {
                setState(() => _scheduleNow = value);
              },
              title: const Text('Pianifica subito'),
              subtitle: const Text('Assegna una data a questa traccia'),
              contentPadding: EdgeInsets.zero,
            ),
            
            // Date picker (conditional)
            if (_scheduleNow) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Data Uscita'),
                subtitle: Text(
                  DateFormat('EEEE, d MMMM y', 'it_IT').format(_selectedDate),
                ),
                trailing: const Icon(Icons.edit),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            final trackName = _nameController.text.trim();
            if (trackName.isEmpty) {
              setState(() => _errorText = 'Inserisci un nome');
              return;
            }
            Navigator.pop(context);
            widget.onSave(trackName, _scheduleNow, _selectedDate);
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
