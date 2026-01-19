import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/group_ride.dart';
import '../models/climb.dart';
import '../models/route_coordinates.dart';
import '../models/clothing_item.dart';
import '../models/outfit_suggestion.dart';
import '../models/weather_conditions.dart';
import '../services/crew_service.dart';
import '../services/gpx_service.dart';
import '../services/weather_service.dart';
import '../services/ai_service.dart';
import '../services/outfit_service.dart';
import '../widgets/route_map_widget.dart';

class GroupRideDetailScreen extends StatefulWidget {
  final GroupRide groupRide;

  const GroupRideDetailScreen({
    super.key,
    required this.groupRide,
  });

  @override
  State<GroupRideDetailScreen> createState() => _GroupRideDetailScreenState();
}

class _GroupRideDetailScreenState extends State<GroupRideDetailScreen> {
  final _crewService = CrewService();
  final _gpxService = GpxService();
  final _weatherService = WeatherService();
  final _aiService = AIService();
  final _outfitService = OutfitService();
  final _supabase = Supabase.instance.client;
  
  final _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isParticipating = false;
  bool _isCreator = false;
  Map<String, dynamic>? _routeData;
  bool _isMapExpanded = false;
  
  List<Map<String, dynamic>> _weatherPoints = [];
  String? _aiAnalysis;
  OutfitSuggestion? _outfitRecommendation;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _isCreator = widget.groupRide.creatorId == userId;
      _isParticipating = widget.groupRide.participants.any((p) => p.userId == userId);
    }
    
    // Load local notes
    final prefs = await SharedPreferences.getInstance();
    _notesController.text = prefs.getString('notes_${widget.groupRide.id}') ?? '';

    try {
      // 1. Load Route Data
      if (widget.groupRide.gpxFilePath != null) { 
         final file = File(widget.groupRide.gpxFilePath!);
         if (await file.exists()) {
             _routeData = await _gpxService.parseGpxFile(file);
         }
      } 
      
      // Fallback: use stored gpxData if available
      if (_routeData == null && widget.groupRide.gpxData != null) {
        final data = widget.groupRide.gpxData!;
        if (data['allPoints'] != null) {
           final pointsList = (data['allPoints'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
           final points = pointsList.map((e) => {
              'lat': (e['lat'] as num).toDouble(),
              'lng': (e['lng'] as num).toDouble(),
              'ele': (e['ele'] as num?)?.toDouble() ?? 0.0,
           }).toList();
           
           final start = LatLng(points.first['lat']!, points.first['lng']!);
           final end = LatLng(points.last['lat']!, points.last['lng']!);
           final mid = LatLng(points[points.length ~/ 2]['lat']!, points[points.length ~/ 2]['lng']!);

           List<Map<String, double>>? elevationProfile;
           if (data['elevationProfile'] != null) {
              elevationProfile = (data['elevationProfile'] as List).map((e) => {
                 'distance': (e['distance'] as num).toDouble(),
                 'elevation': (e['elevation'] as num).toDouble(),
              }).toList();
           }

           _routeData = {
             'allPoints': points,
             'coordinates': RouteCoordinates(
               startLat: start.latitude,
               startLng: start.longitude,
               middleLat: mid.latitude,
               middleLng: mid.longitude,
               endLat: end.latitude,
               endLng: end.longitude,
             ),
             'elevationProfile': elevationProfile ?? [], 
             'climbs': [],
           };
        }
      }

      // 2. Load Weather & AI
      if (widget.groupRide.meetingLatitude != null && widget.groupRide.meetingLongitude != null) {
         final daysUntil = widget.groupRide.meetingTime.difference(DateTime.now()).inDays;
         if (daysUntil >= -1 && daysUntil <= 7) { 
            final lat = widget.groupRide.meetingLatitude!;
            final lon = widget.groupRide.meetingLongitude!;
            
            try {
              final forecast = await _weatherService.getHourlyForecast(lat, lon);
              
              if (forecast.isNotEmpty) {
                final rideStart = widget.groupRide.meetingTime;
                final rideEnd = rideStart.add(const Duration(hours: 3));
                
                _weatherPoints = forecast.where((p) {
                   final t = DateTime.fromMillisecondsSinceEpoch(p['dt'] * 1000);
                   return t.isAfter(rideStart.subtract(const Duration(hours: 1))) && 
                          t.isBefore(rideEnd.add(const Duration(minutes: 30)));
                }).toList();
              
                // Generate Outfit Suggestion
                if (_weatherPoints.isNotEmpty) {
                    // Calc average conditions
                    double avgTemp = 0;
                    double maxWind = 0;
                    for (var p in _weatherPoints) {
                       avgTemp += (p['main']['temp'] as num).toDouble();
                       double wind = (p['wind']['speed'] as num).toDouble();
                       if (wind > maxWind) maxWind = wind;
                    }
                    avgTemp /= _weatherPoints.length;
                    
                    final conditions = WeatherConditions(
                      temperature: avgTemp,
                      windSpeed: maxWind,
                      windDirection: 0, 
                      precipitation: 0, 
                      weatherCode: (_weatherPoints.first['weather'][0]['id'] as num).toInt(),
                    );
                    
                    _outfitRecommendation = _outfitService.suggestOutfit(
                      weather: conditions, 
                      thermalSensitivity: 3, // Default average sensitivity
                      elevationGain: widget.groupRide.elevation,
                    );
                }
              }
            } catch (e) {
              debugPrint('Weather fetch error: $e');
            }
         }
      }
    } catch (e) {
      debugPrint('Error initializing group ride data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_${widget.groupRide.id}', _notesController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note salvate')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupRide.rideName),
        actions: _isCreator
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmDelete,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Map
                  if (_routeData != null && _routeData!['allPoints'] != null)
                    _buildMapSection(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Info Cards
                        _buildHeroStats(),
                        const SizedBox(height: 16),
                        _buildMeetingInfo(),
                        const SizedBox(height: 24),

                        // 3. Description
                        if (widget.groupRide.description != null) ...[
                          Text('Descrizione', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(widget.groupRide.description!),
                          const SizedBox(height: 24),
                        ],
                        
                        // 4. Participants
                        _buildParticipantsSection(),
                        const SizedBox(height: 24),

                        // 5. Elevation
                        if (_routeData != null && _routeData!['elevationProfile'] != null) ...[
                          Text('Profilo Altimetrico', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          _buildElevationChart(),
                          const SizedBox(height: 24),
                        ],

                        // 6. Weather
                        if (_weatherPoints.isNotEmpty) ...[
                           Text('Meteo Previsto', style: Theme.of(context).textTheme.titleLarge),
                           const SizedBox(height: 16),
                           _buildWeatherTimeline(),
                           const SizedBox(height: 24),
                        ],
                        
                        // 7. Clothing Advice
                        if (_outfitRecommendation != null) ...[
                           Text('Consiglio Abbigliamento', style: Theme.of(context).textTheme.titleLarge),
                           const SizedBox(height: 16),
                           _buildClothingCard(),
                           const SizedBox(height: 24),
                        ],

                        // 8. Notes
                        Text('Note Personali', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Aggiungi appunti su questa uscita...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: _saveNotes,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: !_isCreator
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _toggleParticipation,
              backgroundColor: _isParticipating ? Colors.red.shade100 : Theme.of(context).primaryColor,
              foregroundColor: _isParticipating ? Colors.red : Colors.white,
              icon: Icon(_isParticipating ? Icons.exit_to_app : Icons.add_reaction),
              label: Text(_isParticipating ? 'Lascia Uscita' : 'Partecipa'),
            )
          : null,
    );
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
              _outfitRecommendation!.itemsSummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _outfitRecommendation!.reasoning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isMapExpanded ? 500 : 250,
      child: Stack(
        children: [
          RouteMapWidget(
            routePoints: List<Map<String, double>>.from(_routeData!['allPoints'] as List),
            startPoint: (_routeData!['coordinates'] as RouteCoordinates).start,
            middlePoint: (_routeData!['coordinates'] as RouteCoordinates).middle,
            endPoint: (_routeData!['coordinates'] as RouteCoordinates).end,
            distance: widget.groupRide.distance ?? 0,
            elevation: widget.groupRide.elevation ?? 0,
          ),
          Positioned(
            top: 12,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'map_expand_group',
              onPressed: () => setState(() => _isMapExpanded = !_isMapExpanded),
              child: Icon(_isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
            ),
          ),
          if (!_isMapExpanded)
            Positioned.fill(
              child: Material(
              color: Colors.transparent,
                child: InkWell(onTap: () => setState(() => _isMapExpanded = true)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
             _buildStat(Icons.route, '${widget.groupRide.distance?.toStringAsFixed(1) ?? "--"} km', 'Distanza'),
             _buildStat(Icons.terrain, '${widget.groupRide.elevation?.toStringAsFixed(0) ?? "--"} m', 'Dislivello'),
             _buildDifficultyStat(widget.groupRide.difficultyLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildDifficultyStat(String level) {
    Color color;
    String label;
    switch(level) {
      case 'easy': color = Colors.green; label = 'Facile'; break;
      case 'hard': color = Colors.red; label = 'Difficile'; break;
      case 'expert': color = Colors.purple; label = 'Esperto'; break;
      default: color = Colors.orange; label = 'Medio';
    }
    return Column(
      children: [
        Icon(Icons.bar_chart, size: 28, color: color),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text('Difficoltà', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMeetingInfo() {
    final dateFormat = DateFormat('EEEE d MMMM, HH:mm', 'it_IT');
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data e Ora', style: TextStyle(fontSize: 12)),
                      Text(dateFormat.format(widget.groupRide.meetingTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Punto di Ritrovo', style: TextStyle(fontSize: 12)),
                      Text(widget.groupRide.meetingPoint, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text('Partecipanti', style: Theme.of(context).textTheme.titleLarge),
             Chip(
               label: Text('${widget.groupRide.currentParticipants} / ${widget.groupRide.maxParticipants}'),
               backgroundColor: Theme.of(context).colorScheme.primaryContainer,
             ),
           ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.groupRide.participants.length,
            separatorBuilder: (c, i) => const Divider(height: 1, indent: 56),
            itemBuilder: (context, index) {
              final p = widget.groupRide.participants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(p.displayName[0].toUpperCase()),
                ),
                title: Text(p.displayName),
                subtitle: p.isCreator ? 
                  const Text('Organizzatore', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)) : null,
                trailing: p.status == 'confirmed' 
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : const Icon(Icons.schedule, color: Colors.grey, size: 20),
              );
            },
          ),
        ),
        if (widget.groupRide.currentParticipants < widget.groupRide.maxParticipants && !_isParticipating)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '🔥 Ancora ${widget.groupRide.maxParticipants - widget.groupRide.currentParticipants} posti disponibili!',
              style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildElevationChart() {
    final profile = _routeData!['elevationProfile'] as List<Map<String, double>>;
    if (profile.isEmpty) return const SizedBox();

    final spots = profile.asMap().entries.map((entry) {
      return FlSpot(entry.value['distance']!, entry.value['elevation']!);
    }).toList();

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTimeline() {
    return SizedBox(
      height: 130, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weatherPoints.length,
        itemBuilder: (context, index) {
          final p = _weatherPoints[index];
          final date = DateTime.fromMillisecondsSinceEpoch(p['dt'] * 1000);
          final temp = (p['main']['temp'] as num).toDouble();
          final weather = p['weather'][0];
          final iconUrl = 'http://openweathermap.org/img/w/${weather['icon']}.png';

          return Card(
            margin: const EdgeInsets.only(right: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('HH:mm').format(date)),
                  const SizedBox(height: 4),
                  Image.network(iconUrl, width: 30, height: 30, errorBuilder: (_,__,___) => const Icon(Icons.cloud)),
                  const SizedBox(height: 4),
                  Text('${temp.toStringAsFixed(0)}°C', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleParticipation() async {
    try {
      if (_isParticipating) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lasciare l\'uscita?'),
            content: const Text('Sei sicuro di voler annullare la tua partecipazione?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Si, lascia')),
            ],
          ),
        );
        if (confirm != true) return;
        
        await _crewService.leaveGroupRide(widget.groupRide.id);
        setState(() {
          _isParticipating = false;
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hai lasciato l\'uscita')));
      } else {
        await _crewService.joinGroupRide(widget.groupRide.id);
        setState(() => _isParticipating = true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ti sei unito all\'uscita!')));
      }
      
      Navigator.pop(context, true); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }

  void _confirmDelete() async {
     final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminare uscita?'),
            content: const Text('Questa azione non può essere annullata.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Elimina'),
              ),
            ],
          ),
        );
        
     if (confirm == true) {
       await _supabase.from('group_rides').delete().eq('id', widget.groupRide.id);
       if (mounted) {
         Navigator.pop(context, true);
       }
     }
  }
}
