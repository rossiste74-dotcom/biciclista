import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';

import '../models/climb.dart';
import '../models/clothing_item.dart';
import '../models/planned_ride.dart';
import '../models/route_coordinates.dart';
import '../models/weather_conditions.dart';
import '../models/outfit_suggestion.dart';
import '../models/user_profile.dart';
import '../services/gpx_service.dart';
import '../services/weather_service.dart';
import '../services/outfit_service.dart';
import '../services/database_service.dart';
import '../services/qr_service.dart';
import '../services/notification_service.dart';
import '../services/ai_service.dart'; // Added
import '../widgets/route_map_widget.dart';
import '../widgets/elevation_profile_widget.dart';
import '../widgets/terrain_breakdown_widget.dart';
import '../widgets/difficulty_badge.dart';
import '../models/terrain_analysis.dart';
import 'active_navigation_screen.dart';

/// Screen for viewing route details with map visualization
class RouteDetailScreen extends StatefulWidget {
  final PlannedRide plannedRide;

  const RouteDetailScreen({super.key, required this.plannedRide});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final _gpxService = GpxService();
  final _weatherService = WeatherService();
  final _outfitService = OutfitService();
  final _aiService = AIService(); // Added
  final _db = DatabaseService();

  final _notesController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _routeData;
  UserProfile? _profile;
  OutfitSuggestion? _outfit;

  final Map<String, WeatherConditions> _weatherPoints = {};
  bool _isMapExpanded = false;

  bool _showWeatherLayer = false;
  List<Marker> _weatherMapMarkers = [];
  bool _isLoadingWeatherLayer = false;

  Future<void> _toggleWeatherLayer() async {
    if (_showWeatherLayer) {
      setState(() => _showWeatherLayer = false);
      return;
    }

    if (_weatherMapMarkers.isNotEmpty) {
      setState(() => _showWeatherLayer = true);
      return;
    }

    setState(() {
      _isLoadingWeatherLayer = true;
      _showWeatherLayer = true;
    });

    try {
      if (_routeData != null && _routeData!['coordinates'] != null) {
        final coords = _routeData!['coordinates'] as RouteCoordinates;
        final baseDate = widget.plannedRide.rideDate;
        const double avgSpeed = 20.0; // km/h

        // Define key points matching the Weather Timeline
        final pointsOfInterest = <_WeatherPoint>[
          _WeatherPoint(coords.start, baseDate),
          _WeatherPoint(
            coords.middle,
            baseDate.add(
              Duration(
                minutes:
                    ((coords.middleDistance ??
                                (widget.plannedRide.distance / 2)) /
                            avgSpeed *
                            60)
                        .toInt(),
              ),
            ),
          ),
          _WeatherPoint(
            coords.end,
            baseDate.add(
              Duration(
                minutes: (widget.plannedRide.distance / avgSpeed * 60).toInt(),
              ),
            ),
          ),
        ];

        if (coords.high != null) {
          pointsOfInterest.add(
            _WeatherPoint(
              coords.high!,
              baseDate.add(
                Duration(
                  minutes:
                      ((coords.highDistance ??
                                  (widget.plannedRide.distance / 2)) /
                              avgSpeed *
                              60)
                          .toInt(),
                ),
              ),
            ),
          );
        }

        final List<Marker> markers = [];

        debugPrint(
          'DynamicWeather: Fetching for ${pointsOfInterest.length} key points (Start, Mid, End, Summit)',
        );

        for (var pt in pointsOfInterest) {
          try {
            final weather = await _weatherService.getForecast(
              lat: pt.pos.latitude,
              lng: pt.pos.longitude,
              date: pt.time,
            );

            markers.add(_buildWindMarker(pt.pos, weather));
          } catch (e) {
            debugPrint('Error fetch weather for point: $e');
          }
        }

        if (mounted) {
          setState(() {
            _weatherMapMarkers = markers;
            _isLoadingWeatherLayer = false;
          });

          if (markers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Impossibile caricare il meteo per i punti chiave.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggling weather layer: $e');
      if (mounted) setState(() => _isLoadingWeatherLayer = false);
    }
  }

  // Simple helper class if not already defined (it is defined later in file usually, but locally here needs checking)
  // RouteDetailScreen has `_WeatherPoint` class defined?
  // Let's check. Use `view_code_item` or just check file content from previous `view_file`.
  // `view_file` showed `_WeatherPoint` usage in `_fetchWeatherPoints` (Line 205).
  // It is likely defined at the bottom of the file or in existing imports.
  // Wait, `_fetchWeatherPoints` uses it: `final points = { 'Partenza': _WeatherPoint(...) }`.
  // So the class `_WeatherPoint` MUST exist in this file or imported.
  // I'll check if it's at the bottom of the file.

  Marker _buildWindMarker(LatLng pos, WeatherConditions w) {
    Color color;
    if (w.windSpeed < 10) {
      color = Colors.lightBlueAccent;
    } else if (w.windSpeed < 30) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    // Wind Direction: arrow pointing towards FLOW.
    // windDirection (0=North wind) means blowing South.
    // Arrow Up (0 deg) points North.
    // To point South, rotate 180.
    // Formula: (WindDir + 180) degrees.
    final rotationRadians = ((w.windDirection ?? 0) + 180) * (math.pi / 180);

    return Marker(
      point: pos,
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            width: 32,
            height: 32,
          ),
          Transform.rotate(
            angle: rotationRadians,
            child: Icon(Icons.navigation, color: color, size: 24),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${w.temperature.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.plannedRide.notes ?? '';
    _loadAllData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      // 1. Load Route Data
      if (widget.plannedRide.gpxFilePath != null) {
        final gpxFile = File(widget.plannedRide.gpxFilePath!);
        _routeData = await _gpxService.parseGpxFile(gpxFile);
      } else {
        // Manual ride fallback
        _routeData = {
          'distance': widget.plannedRide.distance,
          'elevation': widget.plannedRide.elevation,
          'coordinates': RouteCoordinates(
            startLat: widget.plannedRide.latitude ?? 45.4642,
            startLng: widget.plannedRide.longitude ?? 9.1900,
            middleLat: widget.plannedRide.latitude ?? 45.4642,
            middleLng: widget.plannedRide.longitude ?? 9.1900,
            endLat: widget.plannedRide.latitude ?? 45.4642,
            endLng: widget.plannedRide.longitude ?? 9.1900,
          ),
          'allPoints': <Map<String, double>>[],
          'elevationProfile': null,
          'climbs': <dynamic>[],
        };
      }
      final coords = _routeData!['coordinates'] as RouteCoordinates;

      // 2. Load Profile
      _profile = await _db.getUserProfile();

      // EXTRA: Ensure Track details (Terrain/Difficulty) are loaded if linked
      if (widget.plannedRide.track == null &&
          widget.plannedRide.trackId != null) {
        // Load track manually if needed?
        // For now, assume it's loaded with plannedRide or unnecessary if we rely on effective getters
      }

      // 3. Fetch Weather points
      await _fetchWeatherPoints(coords);

      // 4. Generate Outfit Suggestion (based on midpoint weather)
      final midPointKey = _weatherPoints.keys.firstWhere(
        (k) => k.startsWith('Metà'),
        orElse: () => '',
      );
      if (_profile != null && midPointKey.isNotEmpty) {
        _outfit = _outfitService.suggestOutfit(
          weather: _weatherPoints[midPointKey]!,
          thermalSensitivity: _profile!.thermalSensitivity,
          elevationGain: widget.plannedRide.elevation,
          hotThreshold: _profile!.hotThreshold,
          warmThreshold: _profile!.warmThreshold,
          coolThreshold: _profile!.coolThreshold,
          coldThreshold: _profile!.coldThreshold,
          sensitivityAdjustment: _profile!.sensitivityAdjustment,
          hotKit: ClothingItem.fromIndexes(_profile!.hotKit),
          warmKit: ClothingItem.fromIndexes(_profile!.warmKit),
          coolKit: ClothingItem.fromIndexes(_profile!.coolKit),
          coldKit: ClothingItem.fromIndexes(_profile!.coldKit),
          veryColdKit: ClothingItem.fromIndexes(_profile!.veryColdKit),
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showQrShare() {
    final qrData = QrService.encodeRide(
      widget.plannedRide,
      _routeData?['allPoints'] as List<Map<String, double>>?,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inquadra per importare',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width * 0.75,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        "Dati troppo grandi per il QR Code. Riduci la traccia.",
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.plannedRide.rideName ?? 'Percorso condiviso',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchWeatherPoints(RouteCoordinates coords) async {
    const double avgSpeed = 20.0; // km/h
    final baseDate = widget.plannedRide.rideDate;

    final points = {
      'Partenza': _WeatherPoint(coords.start, baseDate),
      'Metà': _WeatherPoint(
        coords.middle,
        baseDate.add(
          Duration(
            minutes:
                ((coords.middleDistance ?? (widget.plannedRide.distance / 2)) /
                        avgSpeed *
                        60)
                    .toInt(),
          ),
        ),
      ),
      'Arrivo': _WeatherPoint(
        coords.end,
        baseDate.add(
          Duration(
            minutes: (widget.plannedRide.distance / avgSpeed * 60).toInt(),
          ),
        ),
      ),
    };

    if (coords.high != null) {
      points['Vetta'] = _WeatherPoint(
        coords.high!,
        baseDate.add(
          Duration(
            minutes:
                ((coords.highDistance ?? (widget.plannedRide.distance / 2)) /
                        avgSpeed *
                        60)
                    .toInt(),
          ),
        ),
      );
    }

    for (var entry in points.entries) {
      try {
        final weather = await _weatherService.getForecast(
          lat: entry.value.pos.latitude,
          lng: entry.value.pos.longitude,
          date: entry.value.time,
        );
        _weatherPoints['${entry.key}\n${DateFormat('HH:mm').format(entry.value.time)}'] =
            weather;
      } catch (e) {
        debugPrint('Failed to fetch weather for ${entry.key}: $e');
      }
    }
  }

  Future<void> _saveNotes() async {
    widget.plannedRide.notes = _notesController.text;
    await _db.updatePlannedRide(widget.plannedRide);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note salvate')));
    }
  }

  Future<void> _generateAnalysis() async {
    setState(() => _isLoading = true);
    try {
      final analysis = await _aiService.analyzeRide(widget.plannedRide);

      setState(() {
        widget.plannedRide.aiAnalysis = analysis;
        _isLoading = false;
      });

      await _db.updatePlannedRide(widget.plannedRide);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Analisi completata! 🤖')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _startActiveNavigation() {
    if (_routeData == null || _profile == null) return;

    final List<dynamic>? pointsRaw = _routeData!['allPoints'] as List<dynamic>?;
    if (pointsRaw == null || pointsRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nessuna traccia disponibile per la navigazione'),
        ),
      );
      return;
    }

    final List<LatLng> points = pointsRaw.map((e) {
      final Map<String, dynamic> pt = e as Map<String, dynamic>;
      return LatLng(pt['lat'] as double, pt['lng'] as double);
    }).toList();

    final double totalKm = (_routeData!['distance'] as num?)?.toDouble() ?? 0.0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveNavigationScreen(
          routePoints: points,
          profile: _profile!,
          rideName: widget.plannedRide.rideName,
          totalDistanceKm: totalKm,
        ),
      ),
    );
  }

  Future<void> _showCompletionDialog() async {
    final bikes = await _db.getAllBicycles();

    if (!mounted) return;

    if (bikes.isEmpty) {
      // Just mark as done if no bikes (fallback)
      _completeRide(null);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Con quale bici hai pedalato?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...bikes.map(
              (bike) => ListTile(
                leading: const Icon(Icons.pedal_bike),
                title: Text(bike.name),
                subtitle: Text(bike.type),
                onTap: () {
                  Navigator.pop(context);
                  _completeRide(bike);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeRide(dynamic bike) async {
    // Note: bike is dynamic because DatabaseService returns Isar objects which might need casting if imported
    // But here we use standard methods.

    // Update Ride
    setState(() {
      widget.plannedRide.isCompleted = true;
    });
    await _db.updatePlannedRide(widget.plannedRide);

    // Update Bike stats if selected
    if (bike != null) {
      final double rideDist = widget.plannedRide.distance.isNaN
          ? 0.0
          : widget.plannedRide.distance;

      // Update stats safely
      bike.totalKilometers =
          (bike.totalKilometers.isNaN ? 0.0 : bike.totalKilometers) + rideDist;

      // Update legacy fields for compatibility
      bike.chainKms = (bike.chainKms.isNaN ? 0.0 : bike.chainKms) + rideDist;
      bike.tyreKms = (bike.tyreKms.isNaN ? 0.0 : bike.tyreKms) + rideDist;

      // Update dynamic components
      final notify = NotificationService();

      for (var component in bike.components) {
        component.currentKm =
            (component.currentKm.isNaN ? 0.0 : component.currentKm) + rideDist;

        // Check alerts
        if (component.limitKm > 0 &&
            component.currentKm >= component.limitKm * 0.9) {
          await notify.showMaintenanceAlert(
            id: (bike.id * 1000) + bike.components.indexOf(component),
            title: '⚠️ Manutenzione necessaria su ${bike.name}',
            body:
                'Il componente "${component.name}" ha raggiunto ${component.currentKm.toInt()} km. Verifica lo stato!',
          );
        }
      }

      await _db.updateBicycle(bike);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Corsa completata! Km aggiunti a ${bike?.name ?? "nessuna bici"}.',
          ),
        ),
      );
    }
  }

  Future<void> _shareRide() async {
    if (_routeData == null || _routeData!['allPoints'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati percorso non disponibili')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Prepare GPX
      final gpx = Gpx();
      gpx.metadata = Metadata(
        name: widget.plannedRide.rideName,
        desc:
            widget.plannedRide.aiAnalysis ??
            'Percorso pianificato con Biciclista',
        time: widget.plannedRide.rideDate,
      );
      gpx.creator = 'Ride Butler'; // Brand legacy name or Biciclista

      final trk = Trk(name: widget.plannedRide.rideName ?? 'Giro');
      final trkSeg = Trkseg();

      for (var p in _routeData!['allPoints']) {
        trkSeg.trkpts.add(
          Wpt(lat: p['lat'], lon: p['lng'], ele: p['ele']?.toDouble()),
        );
      }
      trk.trksegs.add(trkSeg);
      gpx.trks.add(trk);

      final gpxString = GpxWriter().asString(gpx, pretty: true);
      final dir = await getTemporaryDirectory();
      final filename = 'percorso_${widget.plannedRide.id}.gpx';
      final gpxPath = '${dir.path}/$filename';

      final File file = File(gpxPath);
      await file.writeAsString(gpxString);

      // 2. Share
      await Share.shareXFiles(
        [XFile(gpxPath, mimeType: 'application/gpx+xml')],
        text:
            'Che ne pensi di questa traccia per veri Biciclisti!!! 🚴‍♂️💨 \n\n'
            '📊 ${widget.plannedRide.distance.toStringAsFixed(3)} km | ⛰️ ${widget.plannedRide.elevation.toInt()} m',
        subject: widget.plannedRide.rideName ?? 'Condivisione Percorso',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore condivisione: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina Attività'),
        content: const Text('Sei sicuro di voler eliminare questa attività?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.plannedRide.id != null) {
        await _db.deletePlannedRide(widget.plannedRide.id!);
      }
      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Close details screen with refresh signal
      }
    }
  }

  Future<void> _toggleCompletion() async {
    if (!widget.plannedRide.isCompleted) {
      // If marking as done, ask for bike
      await _showCompletionDialog();
    } else {
      // If unmarking, just toggle back
      setState(() {
        widget.plannedRide.isCompleted = false;
      });
      await _db.updatePlannedRide(widget.plannedRide);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attività spostata in pianificate')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plannedRide.rideName ?? 'Dettagli Percorso'),
        actions: [
          // Naviga (Prominent)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FilledButton.icon(
              onPressed: _startActiveNavigation,
              icon: const Icon(Icons.navigation, size: 16),
              label: const Text('Naviga'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // Condividi
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Condividi',
            onPressed: _shareRide,
          ),

          // Termina / Status
          IconButton(
            icon: Icon(
              widget.plannedRide.isCompleted
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: widget.plannedRide.isCompleted ? Colors.green : null,
            ),
            tooltip: widget.plannedRide.isCompleted
                ? 'Completata'
                : 'Segna come completata',
            onPressed: _toggleCompletion,
          ),

          // Menu Altro (QR, Delete)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'qr') _showQrShare();
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'qr',
                child: ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text('Codice QR'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Elimina', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Errore caricamento percorso',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_errorMessage!),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map
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
                          startPoint:
                              (_routeData!['coordinates'] as RouteCoordinates)
                                  .start,
                          middlePoint:
                              (_routeData!['coordinates'] as RouteCoordinates)
                                  .middle,
                          endPoint:
                              (_routeData!['coordinates'] as RouteCoordinates)
                                  .end,
                          distance: widget.plannedRide.distance,
                          elevation: widget.plannedRide.elevation,
                          additionalMarkers: _showWeatherLayer
                              ? _weatherMapMarkers
                              : null,
                        ),
                        // Weather Layer Loading Indicator
                        if (_isLoadingWeatherLayer)
                          const Positioned.fill(
                            child: Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        // Expand/Collapse overlay button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Column(
                            children: [
                              FloatingActionButton.small(
                                heroTag: 'map_expand_btn',
                                onPressed: () => setState(
                                  () => _isMapExpanded = !_isMapExpanded,
                                ),
                                child: Icon(
                                  _isMapExpanded
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.small(
                                heroTag: 'weather_layer_btn',
                                backgroundColor: _showWeatherLayer
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                foregroundColor: _showWeatherLayer
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                                onPressed: _toggleWeatherLayer,
                                tooltip: 'Meteo sul percorso',
                                child: const Icon(Icons.air),
                              ),
                            ],
                          ),
                        ),
                        // Tap area for expansion if collapsed
                        if (!_isMapExpanded)
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _isMapExpanded = true),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Route info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informazioni Percorso',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(),
                        const SizedBox(height: 24),

                        // Elevation Profile Chart
                        if (_routeData != null &&
                            _routeData!['elevationProfile'] != null) ...[
                          Text(
                            'Profilo Altimetrico',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildElevationChart(),
                          const SizedBox(height: 24),
                        ],

                        // Tough Climbs
                        if (_routeData != null &&
                            (_routeData!['climbs'] as List).isNotEmpty) ...[
                          Text(
                            'Salite Impegnative',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildClimbsList(),
                          const SizedBox(height: 24),

                          Text(
                            'Insight Avanzati',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2229), // Dark card bg
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildInsightRow(
                                  'Indice Difficoltà',
                                  '1.0 / 10',
                                  Colors.lightGreen,
                                ), // Placeholder calculation could be added
                                if (widget.plannedRide.movingTime ==
                                    null) // Show estimated if no real time
                                  _buildInsightRow(
                                    'Tempo Stimato',
                                    '~${(widget.plannedRide.distance / 20).toStringAsFixed(1)}h',
                                    Colors.white,
                                  ),
                                _buildInsightRow(
                                  'Calorie Stimate',
                                  '${(widget.plannedRide.distance * 30).toInt()} kcal',
                                  Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // AI Analysis
                        // Stats Grid
                        if (widget.plannedRide.avgSpeed != null ||
                            widget.plannedRide.avgHeartRate != null ||
                            widget.plannedRide.avgPower != null)
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.6,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              if (widget.plannedRide.avgSpeed != null)
                                _buildDetailCard(
                                  icon: Icons.speed,
                                  label: 'Velocità Media',
                                  value:
                                      '${widget.plannedRide.avgSpeed!.toStringAsFixed(1)} km/h',
                                ),
                              if (widget.plannedRide.calories != null)
                                _buildDetailCard(
                                  icon: Icons.local_fire_department,
                                  label: 'Calorie',
                                  value: '${widget.plannedRide.calories} kcal',
                                ),
                              if (widget.plannedRide.avgHeartRate != null)
                                _buildDetailCard(
                                  icon: Icons.favorite,
                                  label: 'Freq. Cardiaca',
                                  value:
                                      '${widget.plannedRide.avgHeartRate!.round()} bpm',
                                  subValue:
                                      widget.plannedRide.maxHeartRate != null
                                      ? 'Max ${widget.plannedRide.maxHeartRate!.round()}'
                                      : null,
                                ),
                              if (widget.plannedRide.avgPower != null)
                                _buildDetailCard(
                                  icon: Icons.bolt,
                                  label: 'Potenza',
                                  value:
                                      '${widget.plannedRide.avgPower!.round()} W',
                                  subValue: widget.plannedRide.maxPower != null
                                      ? 'Max ${widget.plannedRide.maxPower!.round()}'
                                      : null,
                                ),
                              if (widget.plannedRide.avgCadence != null)
                                _buildDetailCard(
                                  icon: Icons.autorenew,
                                  label: 'Cadenza',
                                  value:
                                      '${widget.plannedRide.avgCadence!.round()} rpm',
                                ),
                              if (widget.plannedRide.movingTime != null)
                                _buildDetailCard(
                                  icon: Icons.timer,
                                  label: 'Tempo',
                                  value:
                                      '${widget.plannedRide.movingTime! ~/ 60} min',
                                ),
                            ],
                          ),
                        if (widget.plannedRide.aiAnalysis != null &&
                            widget.plannedRide.aiAnalysis!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Card(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.4),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.psychology,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Analisi Biometrica & Percorso',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Text(
                                    widget.plannedRide.aiAnalysis!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          const SizedBox(height: 24),
                          Center(
                            child: FilledButton.icon(
                              onPressed: _generateAnalysis,
                              icon: const Icon(Icons.psychology),
                              label: const Text('Genera Analisi con Butler AI'),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Weather Timeline
                        if (_weatherPoints.isNotEmpty) ...[
                          Text(
                            'Timeline Meteo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildWeatherTimeline(),
                          const SizedBox(height: 24),
                        ],

                        // Clothing Advice
                        if (_outfit != null) ...[
                          Text(
                            'Consiglio Abbigliamento',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildClothingCard(),
                          const SizedBox(height: 24),
                        ],

                        // Notes
                        Text(
                          'Note Personali',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Aggiungi appunti su questa uscita...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: _saveNotes,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    final track = widget.plannedRide.track;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              'Data',
              DateFormat(
                'EEEE, d MMMM y',
                'it_IT',
              ).format(widget.plannedRide.rideDate),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.straighten,
              'Distanza',
              '${widget.plannedRide.distance.toStringAsFixed(1)} km',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.terrain,
              'Dislivello',
              '${widget.plannedRide.elevation.toStringAsFixed(0)} m',
            ),
            if (widget.plannedRide.latitude != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.location_on,
                'Coordinate',
                '${widget.plannedRide.latitude!.toStringAsFixed(4)}, ${widget.plannedRide.longitude!.toStringAsFixed(4)}',
              ),
            ],

            // Terrain & Difficulty from Linked Track
            if (track != null) ...[
              if (track.asphaltPercent != null) ...[
                const Divider(height: 24),
                TerrainBreakdownWidget(
                  terrain: TerrainBreakdown(
                    asphaltPercent: track.asphaltPercent!,
                    gravelPercent: track.gravelPercent!,
                    pathPercent: track.pathPercent!,
                  ),
                  compact: false,
                ),
              ],

              if (track.difficultyLevel != null) ...[
                const Divider(height: 24),
                Center(
                  child: DifficultyBadge(
                    difficulty: difficultyFromLevel(track.difficultyLevel!),
                    showLabel: true,
                    showLevel: true,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTimeline() {
    return SizedBox(
      height: 170, // Increased from 140 to 170 to fix overflow
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _weatherPoints.entries.map((entry) {
          final weather = entry.value;
          return Container(
            width: 110, // Slightly wider
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(weather.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(indent: 16, endIndent: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (weather.windDirection != null)
                      Transform.rotate(
                        angle: (weather.windDirection! + 180) * (math.pi / 180),
                        child: const Icon(Icons.arrow_upward, size: 14),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.windSpeed.toInt()} km/h',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildElevationChart() {
    if (_routeData == null || _routeData!['elevationProfile'] == null) {
      return const SizedBox.shrink();
    }

    final profile =
        _routeData!['elevationProfile'] as List<Map<String, double>>;
    if (profile.isEmpty) return const SizedBox.shrink();

    // Extract elevation values
    final elevations = profile.map((p) => p['elevation']!).toList();

    return ElevationProfileWidget(
      elevationProfile: elevations,
      distanceKm: widget.plannedRide.distance,
    );
  }

  Widget _buildClimbsList() {
    final climbs = _routeData!['climbs'] as List<Climb>;
    return Column(
      children: climbs
          .map(
            (climb) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                title: Text(
                  'Km ${climb.startKm.toStringAsFixed(1)} ➔ ${climb.endKm.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${climb.lengthKm.toStringAsFixed(1)} km • Media ${climb.averageGradient.toStringAsFixed(1)}% (Max ${climb.maxGradient.toStringAsFixed(1)}%)',
                ),
                trailing: Text(
                  '+${climb.elevationGain.toInt()}m',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAdvancedInsights() {
    // Basic heuristics for metrics
    final distance = widget.plannedRide.distance;
    final elevation = widget.plannedRide.elevation;

    // Difficulty index (0-10) using dynamic weights from profile
    final distWeight = _profile?.difficultyDistanceWeight ?? 0.05;
    final elevWeight = _profile?.difficultyElevationWeight ?? 0.008;
    final difficulty = (distance * distWeight + elevation * elevWeight).clamp(
      1.0,
      10.0,
    );
    final durationHours = distance / 20.0; // Assume 20km/h avg
    final calories = (600 * durationHours).toInt(); // Assume 600 kcal/h

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow(
              Icons.bolt,
              'Indice Difficoltà',
              '${difficulty.toStringAsFixed(1)} / 10',
              _getDifficultyColor(difficulty),
            ),
            const Divider(height: 24),
            _buildMetricRow(
              Icons.timer_outlined,
              'Tempo Stimato',
              '~${durationHours.toInt()}h ${((durationHours % 1) * 60).toInt()}min',
            ),
            const Divider(height: 24),
            _buildMetricRow(
              Icons.local_fire_department_outlined,
              'Calorie Stimate',
              '$calories kcal',
            ),
            const Divider(height: 24),
            _buildMetricRow(
              Icons.landscape_outlined,
              'Terreno Prevalente',
              'Asfalto / Strada',
              Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    IconData icon,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(double difficulty) {
    if (difficulty < 3) return Colors.green;
    if (difficulty < 6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildClothingCard() {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checkroom,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kit Suggerito',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _outfit!.itemsSummary,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _outfit!.reasoning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null)
            Text(
              subValue,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeatherPoint {
  final LatLng pos;
  final DateTime time;
  _WeatherPoint(this.pos, this.time);
}
