import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gpx/gpx.dart';
import 'package:geolocator/geolocator.dart';
import '../services/route_planning_service.dart';
import '../services/database_service.dart';
import '../models/planned_ride.dart';

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
    
    final bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('Ricalcola Percorso'),
        content: Text('Vuoi ricalcolare tutti i segmenti esistenti usando il profilo ${_profileName(_selectedProfile)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ricalcola')),
        ],
      )
    ) ?? false;
    
    if (!confirm) return;

    setState(() => _isLoading = true);
    
    // We need the original waypoints (markers).
    // Logic: clear segments, iterate markers pairwise, fetch new route.
    
    final waypoints = _markers.map((m) => m.point).toList();
    _clearRouteState(keepStart: true); // Keep start marker? No, keep logic separate.
    
    // Hard reset
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
          graphHopperKey: _graphHopperKey
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore ricalcolo: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _clearRouteState({bool keepStart = false}) {
     // Helper ...
  }
  
  Future<void> _saveGpx() async {
    if (_allPoints.length < 2) return;
    
    // 1. Create GPX content
    final gpx = Gpx();
    final trk = Trk(name: 'Percorso Disegnato ${DateTime.now().day}/${DateTime.now().month}');
    final seg = Trkseg();
    
    for (final p in _allPoints) {
      seg.trkpts.add(Wpt(lat: p.latitude, lon: p.longitude, ele: 0));
    }
    
    trk.trksegs.add(seg);
    gpx.trks.add(trk);
    gpx.creator = 'Biciclista App';
    
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
    
    // 3. Create PlannedRide in Database
    try {
      final db = DatabaseService(); // Can optimize by creating in initState
      // Calculate simple bbox center for lat/lng
      double sumLat = 0;
      double sumLng = 0;
      for (var p in _allPoints) {
        sumLat += p.latitude;
        sumLng += p.longitude;
      }
      
      final plannedRide = PlannedRide()
        ..rideDate = DateTime.now().add(const Duration(days: 1)) // Default tomorrow
        ..rideName = 'Giro Disegnato'
        ..gpxFilePath = file.path
        ..distance = _totalDistanceKm
        ..elevation = _totalElevationM
        ..latitude = sumLat / _allPoints.length
        ..longitude = sumLng / _allPoints.length;
        
      await db.createPlannedRide(plannedRide);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Percorso salvato e aggiunto ai Giri Pianificati!'))
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore salvataggio DB: $e'))
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Percorso'),
        actions: [
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
            onPressed: _segments.isEmpty ? null : _saveGpx,
          )
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
}
