import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/route_map_widget.dart';
import 'active_navigation_screen.dart';

/// Screen for viewing route details with map visualization
class RouteDetailScreen extends StatefulWidget {
  final PlannedRide plannedRide;

  const RouteDetailScreen({
    super.key,
    required this.plannedRide,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final _gpxService = GpxService();
  final _weatherService = WeatherService();
  final _outfitService = OutfitService();
  final _db = DatabaseService();
  
  final _notesController = TextEditingController();
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _routeData;
  UserProfile? _profile;
  OutfitSuggestion? _outfit;
  
  final Map<String, WeatherConditions> _weatherPoints = {};
  bool _isMapExpanded = false;

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

      // 3. Fetch Weather points
      await _fetchWeatherPoints(coords);

      // 4. Generate Outfit Suggestion (based on midpoint weather)
      final midPointKey = _weatherPoints.keys.firstWhere((k) => k.startsWith('Metà'), orElse: () => '');
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
    final qrData = QrService.encodeRide(widget.plannedRide, _routeData?['allPoints'] as List<Map<String, double>>?);
    
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
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
        baseDate.add(Duration(minutes: ((coords.middleDistance ?? (widget.plannedRide.distance / 2)) / avgSpeed * 60).toInt())),
      ),
      'Arrivo': _WeatherPoint(
        coords.end, 
        baseDate.add(Duration(minutes: (widget.plannedRide.distance / avgSpeed * 60).toInt())),
      ),
    };
    
    if (coords.high != null) {
      points['Vetta'] = _WeatherPoint(
        coords.high!,
        baseDate.add(Duration(minutes: ((coords.highDistance ?? (widget.plannedRide.distance / 2)) / avgSpeed * 60).toInt())),
      );
    }

    for (var entry in points.entries) {
      try {
        final weather = await _weatherService.getForecast(
          lat: entry.value.pos.latitude,
          lng: entry.value.pos.longitude,
          date: entry.value.time,
        );
        _weatherPoints['${entry.key}\n${DateFormat('HH:mm').format(entry.value.time)}'] = weather;
      } catch (e) {
        debugPrint('Failed to fetch weather for ${entry.key}: $e');
      }
    }
  }

  Future<void> _saveNotes() async {
    widget.plannedRide.notes = _notesController.text;
    await _db.updatePlannedRide(widget.plannedRide);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note salvate')),
      );
    }
  }

  void _startActiveNavigation() {
    if (_routeData == null || _profile == null) return;
    
    final List<dynamic>? pointsRaw = _routeData!['allPoints'] as List<dynamic>?;
    if (pointsRaw == null || pointsRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna traccia disponibile per la navigazione')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plannedRide.rideName ?? 'Dettagli Percorso'),
        actions: [
          IconButton(
            icon: Icon(
              widget.plannedRide.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: widget.plannedRide.isCompleted ? Colors.green : null,
            ),
            tooltip: widget.plannedRide.isCompleted ? 'Segna come da fare' : 'Segna come completato',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              setState(() {
                widget.plannedRide.isCompleted = !widget.plannedRide.isCompleted;
              });
              await _db.updatePlannedRide(widget.plannedRide);
              
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    widget.plannedRide.isCompleted 
                      ? 'Attività segnata come completata!' 
                      : 'Attività spostata in pianificate'
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Condividi via QR',
            onPressed: _showQrShare,
          ),
          IconButton(
            icon: const Icon(Icons.navigation_outlined),
            tooltip: 'Avvia Navigazione',
            onPressed: _startActiveNavigation,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
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
                              startPoint: (_routeData!['coordinates']
                                      as RouteCoordinates)
                                  .start,
                              middlePoint: (_routeData!['coordinates']
                                      as RouteCoordinates)
                                  .middle,
                              endPoint:
                                  (_routeData!['coordinates'] as RouteCoordinates)
                                      .end,
                              distance: widget.plannedRide.distance,
                              elevation: widget.plannedRide.elevation,
                            ),
                            // Expand/Collapse overlay button
                            Positioned(
                              top: 12,
                              right: 12,
                              child: FloatingActionButton.small(
                                heroTag: 'map_expand_btn',
                                onPressed: () => setState(() => _isMapExpanded = !_isMapExpanded),
                                child: Icon(_isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
                              ),
                            ),
                            // Tap area for expansion if collapsed
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

                            // Advanced Insights
                            Text(
                              'Insight Avanzati',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildAdvancedInsights(),
                            const SizedBox(height: 24),
                            
                            // AI Analysis
                            if (widget.plannedRide.aiAnalysis != null) ...[
                              Text(
                                'Analisi Coach AI',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              Card(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.psychology,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Analisi Biometrica & Percorso',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Text(
                                        widget.plannedRide.aiAnalysis!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              'Data',
              DateFormat('EEEE, d MMMM y', 'it_IT').format(widget.plannedRide.rideDate),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.icon,
                  style: const TextStyle(fontSize: 20),
                ),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
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
    final profile = _routeData!['elevationProfile'] as List<Map<String, double>>;
    if (profile.isEmpty) return const SizedBox.shrink();

    // Downsample for performance if too many points
    final List<FlSpot> spots = [];
    final step = (profile.length / 50).ceil().clamp(1, profile.length);
    for (int i = 0; i < profile.length; i += step) {
      spots.add(FlSpot(profile[i]['distance']!, profile[i]['elevation']!));
    }
    // Ensure last point is added
    if (spots.last.x != profile.last['distance']) {
      spots.add(FlSpot(profile.last['distance']!, profile.last['elevation']!));
    }

    final minEle = profile.map((p) => p['elevation']!).reduce(math.min);
    final maxEle = profile.map((p) => p['elevation']!).reduce(math.max);
    final padding = (maxEle - minEle) * 0.2;

    return Container(
      height: 180,
      padding: const EdgeInsets.only(right: 16, top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: (widget.plannedRide.distance / 5).clamp(1.0, 100.0),
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}km',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}m',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: widget.plannedRide.distance,
          minY: minEle - padding,
          maxY: maxEle + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimbsList() {
    final climbs = _routeData!['climbs'] as List<Climb>;
    return Column(
      children: climbs.map((climb) => Card(
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
      )).toList(),
    );
  }

  Widget _buildAdvancedInsights() {
    // Basic heuristics for metrics
    final distance = widget.plannedRide.distance;
    final elevation = widget.plannedRide.elevation;
    
    // Difficulty index (0-10) using dynamic weights from profile
    final distWeight = _profile?.difficultyDistanceWeight ?? 0.05;
    final elevWeight = _profile?.difficultyElevationWeight ?? 0.008;
    final difficulty = (distance * distWeight + elevation * elevWeight).clamp(1.0, 10.0);
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
              '~${durationHours.toInt()}h ${( (durationHours % 1) * 60).toInt()}min',
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

  Widget _buildMetricRow(IconData icon, String label, String value, [Color? valueColor]) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Percorso'),
        content: const Text(
          'Sei sicuro di voler eliminare questa pedalata? L\'azione è irreversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final db = DatabaseService();
      await db.deletePlannedRide(widget.plannedRide.id);
      
      // Optionally delete the physical file too
      try {
        if (widget.plannedRide.gpxFilePath != null) {
          final file = File(widget.plannedRide.gpxFilePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      } catch (e) {
        debugPrint('Failed to delete GPX file: $e');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}

class _WeatherPoint {
  final LatLng pos;
  final DateTime time;
  _WeatherPoint(this.pos, this.time);
}
