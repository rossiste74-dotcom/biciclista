import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/group_ride.dart';
import '../models/planned_ride.dart'; // Added
import '../models/user_profile.dart';
import '../models/terrain_analysis.dart';
import '../models/route_coordinates.dart';
import '../models/outfit_suggestion.dart';
import '../models/weather_conditions.dart';
import '../services/crew_service.dart';
import '../services/gpx_service.dart';
import '../services/weather_service.dart';
import '../services/ai_service.dart';
import '../services/outfit_service.dart';
import '../services/database_service.dart'; // Added
import 'active_navigation_screen.dart'; // Added
import '../widgets/route_map_widget.dart';
import '../widgets/elevation_profile_widget.dart';
import '../widgets/terrain_breakdown_widget.dart';

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
  final _db = DatabaseService(); // Added
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

      // 3. Ensure Creator is in Participants List
      final creatorInList = widget.groupRide.participants.any((p) => p.userId == widget.groupRide.creatorId);
      if (!creatorInList) {
         try {
            final response = await _supabase
              .from('public_profiles')
              .select('display_name')
              .eq('user_id', widget.groupRide.creatorId) // user_id not id in public_profiles?
              .maybeSingle();
              
            String creatorName = 'Organizzatore';
            if (response != null && response['display_name'] != null) {
              creatorName = response['display_name'];
            }
              final creatorPart = GroupRideParticipant(
                 id: 'creator_${widget.groupRide.creatorId}', 
                 userId: widget.groupRide.creatorId, 
                 displayName: creatorName, 
                 joinedAt: widget.groupRide.createdAt,
                 isCreator: true,
                 status: 'confirmed',
              );
              
              if (mounted) {
                 setState(() {
                    // Add to top
                    widget.groupRide.participants.insert(0, creatorPart);
                 });
              }
           } catch (e) {
           debugPrint('Error fetching creator profile: $e');
         }
      }
      
      // 4. Hydrate Participant Details (Fetch names)
      _fetchParticipantDetails();

    } catch (e) {
      debugPrint('Error initializing group ride data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchWeatherAndAnalyze() async {
    if (widget.groupRide.meetingLatitude == null || widget.groupRide.meetingLongitude == null) return;

    setState(() => _isLoading = true);
    
    try {
      // 1. Fetch live weather
      final lat = widget.groupRide.meetingLatitude!;
      final lon = widget.groupRide.meetingLongitude!;
      final forecast = await _weatherService.getHourlyForecast(lat, lon);
      
      String? weatherJson; 

      if (forecast.isNotEmpty) {
         final rideStart = widget.groupRide.meetingTime;
         final rideEnd = rideStart.add(const Duration(hours: 3));
         
         final points = forecast.where((p) {
            final t = DateTime.fromMillisecondsSinceEpoch(p['dt'] * 1000);
            return t.isAfter(rideStart.subtract(const Duration(hours: 1))) && 
                   t.isBefore(rideEnd.add(const Duration(minutes: 30)));
         }).toList();
         
         if (points.isNotEmpty) {
           setState(() => _weatherPoints = points); // Update UI too
           
           // Prepare simple weather object for AI
           final first = points.first;
           final w = {
             'temperature': (first['main']['temp'] as num).toDouble(),
             'windSpeed': (first['wind']['speed'] as num).toDouble(),
             'condition': (first['weather'][0]['main'] as String),
           };
           weatherJson = jsonEncode(w);
         }
      }

      // 2. Wrap in PlannedRide for AI Service
      final dummyRide = PlannedRide()
        ..rideDate = widget.groupRide.meetingTime
        ..distance = widget.groupRide.distance ?? 0.0
        ..elevation = widget.groupRide.elevation ?? 0.0
        ..forecastWeather = weatherJson
        ..rideName = widget.groupRide.rideName;
        
      // 3. Call AI
      final analysis = await _aiService.analyzeRide(dummyRide);
      
      setState(() {
        _aiAnalysis = analysis;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meteo aggiornato e analisi completata! 🤖')),
        );
      }
      
    } catch (e) {
      debugPrint('Error analyzing ride: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  


  Future<void> _fetchParticipantDetails() async {
    final userIds = widget.groupRide.participants.map((p) => p.userId).toSet().toList();
    if (userIds.isEmpty) return;

    try {
      final response = await _supabase
          .from('public_profiles')
          .select('user_id, display_name, profile_image_url')
          .inFilter('user_id', userIds);

      if (mounted) {
        setState(() {
          final List<GroupRideParticipant> updatedParticipants = [];
          
          for (var p in widget.groupRide.participants) {
            final profile = (response as List<dynamic>).firstWhere(
              (json) => json['user_id'] == p.userId,
              orElse: () => <String, dynamic>{}, // Provide an empty map if not found
            );
            
            if (profile.isNotEmpty) { // Check if profile was actually found
              updatedParticipants.add(p.copyWith(
                displayName: profile['display_name'] ?? p.displayName,
                profileImageUrl: profile['profile_image_url'],
              ));
            } else {
              updatedParticipants.add(p);
            }
          }
          
          widget.groupRide.participants = updatedParticipants;
        });
      }
    } catch (e) {
      debugPrint('Error hydrating participants: $e');
    }
  }
  
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_${widget.groupRide.id}', _notesController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note salvate')));
    }
  }

  Future<void> _startNavigation() async {
    if (_routeData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna traccia disponibile per la navigazione')),
      );
      return;
    }
    
    final List<dynamic>? pointsRaw = _routeData!['allPoints'] as List<dynamic>?;
    if (pointsRaw == null || pointsRaw.isEmpty) return;

    final List<LatLng> points = pointsRaw.map((e) {
      final Map<String, dynamic> pt = e as Map<String, dynamic>;
      return LatLng(pt['lat'] as double, pt['lng'] as double);
    }).toList();

    final userId = _supabase.auth.currentUser?.id;
    UserProfile? profile;
    if (userId != null) {
       profile = await _db.getUserProfile();
    }
    
    if (profile == null) {
       // Fallback dummy profile if null
       profile = UserProfile()..id = 'dummy'; 
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ActiveNavigationScreen(
            routePoints: points,
            profile: profile!,
            rideName: widget.groupRide.rideName,
            totalDistanceKm: widget.groupRide.distance ?? 0.0,
          ),
        ),
      );
    }
  }

  Future<void> _completeGroupRide() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Termina Uscita'),
        content: const Text('Vuoi salvare questa uscita di gruppo come completata nel tuo diario personale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sì, Salva'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    try {
      // 1. Update Remote Status (if Creator)
      if (_isCreator) {
        await _crewService.updateRideStatus(widget.groupRide.id, 'completed');
        // Update local object to reflect change immediately if we stay on screen
        // widget.groupRide = widget.groupRide.copyWith(status: 'completed'); // GroupRide is final fields mostly but checking...
        // Actually we can't easily mutate it if it's not designed for it, but we can set a flag.
      }

      // 2. Create a personal Completed Ride from this Group Ride
      final personalRide = PlannedRide()
        ..rideName = widget.groupRide.rideName
        ..rideDate = widget.groupRide.meetingTime
        ..distance = widget.groupRide.distance ?? 0.0
        ..elevation = widget.groupRide.elevation ?? 0.0
        ..isCompleted = true
        ..isGroupRide = true
        ..aiAnalysis = 'Uscita di Gruppo Completata: ${widget.groupRide.rideName}';
      
      await _db.createPlannedRide(personalRide);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grande! Uscita salvata e completata! 🏁')),
        );
        // Return true to refresh agenda
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore salvataggio: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareGroupRide() async {
    try {
      await Share.share(
        'Vieni a pedalare con noi! 🚴‍♂️\n\n'
        '${widget.groupRide.rideName}\n'
        '📅 ${DateFormat('dd/MM HH:mm').format(widget.groupRide.meetingTime)}\n'
        '📍 ${widget.groupRide.meetingPoint}\n'
        '📊 ${widget.groupRide.distance?.toStringAsFixed(1) ?? "?"} km | ${widget.groupRide.elevation?.toStringAsFixed(0) ?? "?"} m\n\n'
        'Unisciti su Biciclista!',
        subject: 'Invito Uscita: ${widget.groupRide.rideName}',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupRide.rideName),
        actions: [
           // Naviga (Prominent)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FilledButton.icon(
              onPressed: _startNavigation,
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
            onPressed: _shareGroupRide,
          ),
          
          // Termina (Salva su diario)
          IconButton(
            icon: const Icon(Icons.save_as),
            tooltip: 'Salva nel Diario (Termina)',
            onPressed: _completeGroupRide,
          ),
        
          if (_isCreator)
             IconButton(
               icon: const Icon(Icons.delete),
               onPressed: _confirmDelete,
             ),
             
          // Menu Altro (Delete if creator, or other options)
          if (_isCreator)
             PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _confirmDelete();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                        
                        // 3. Terrain Breakdown (if available)
                        if (_routeData != null && _routeData!['terrainBreakdown'] != null) ...[
                          const SizedBox(height: 16),
                          Text('Tipo Terreno', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          TerrainBreakdownWidget(
                            terrain: _routeData!['terrainBreakdown'] as TerrainBreakdown,
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // 4. Elevation Profile (moved here, after meeting info)
                        if (_routeData != null && _routeData!['elevationProfile'] != null && (_routeData!['elevationProfile'] as List).isNotEmpty) ...[
                          Text('Profilo Altimetrico', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ElevationProfileWidget(
                            elevationProfile: (_routeData!['elevationProfile'] as List<Map<String, double>>)
                                .map((e) => e['elevation'] ?? 0.0)
                                .toList(),
                            distanceKm: widget.groupRide.distance ?? 0.0,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 5. Description
                        if (widget.groupRide.description != null) ...[
                          Text('Descrizione', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(widget.groupRide.description!),
                          const SizedBox(height: 24),
                        ],
                        
                        // 6. Participants
                        _buildParticipantsSection(),
                        const SizedBox(height: 24),

                        // 7. Weather
                        if (_weatherPoints.isNotEmpty) ...[
                           Text('Meteo Previsto', style: Theme.of(context).textTheme.titleLarge),
                           const SizedBox(height: 16),
                           _buildWeatherTimeline(),
                           const SizedBox(height: 24),
                        ],
                        
                        // 8. Clothing Advice
                        if (_outfitRecommendation != null) ...[
                           Text('Consiglio Abbigliamento', style: Theme.of(context).textTheme.titleLarge),
                           const SizedBox(height: 16),
                           _buildClothingCard(),
                           const SizedBox(height: 24),
                        ],


                        
                        // 9. AI Strategic Analysis
                        if (_aiAnalysis != null) ...[
                          Text('Analisi Strategica (Live)', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(children: [
                                    const Icon(Icons.psychology), 
                                    const SizedBox(width: 8), 
                                    Expanded(child: Text("Il Coach Consiglia:", style: Theme.of(context).textTheme.titleMedium))
                                  ]),
                                  const Divider(),
                                  Text(_aiAnalysis!),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                           Center(
                             child: FilledButton.icon(
                               onPressed: _fetchWeatherAndAnalyze,
                               icon: const Icon(Icons.refresh),
                               label: const Text('Aggiorna Meteo & Analizza'),
                             ),
                           ),
                           const SizedBox(height: 24),
                        ],

                        // 10. Notes
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
               // Show participants count. If list empty but creator exists (fetched above), size is correct.
               label: Text('${widget.groupRide.participants.length} / ${widget.groupRide.maxParticipants}'),
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

        
        final userId = _supabase.auth.currentUser!.id;
        
        setState(() {
          _isParticipating = false;
          // Remove from local list
          widget.groupRide.participants.removeWhere((p) => p.userId == userId);
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hai lasciato l\'uscita')));
      } else {
        final user = _supabase.auth.currentUser!;
        
        // Ensure public profile exists before joining (fixes "Ciclista" name issue)
        // If the user hasn't synced profile, we create a default one now.
        // await _dataModeService.ensurePublicProfile(user); // Removed
        
        try {
            // Check if profile exists
            final publicProfile = await _supabase
                .from('public_profiles')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();
                
            if (publicProfile == null) {
              // Create default public profile
              // Try to get name from local Isar or User Metadata
              String displayName = user.userMetadata?['name'] ?? 'Ciclista';
              
              await _supabase.from('public_profiles').upsert({
                'user_id': user.id,
                'display_name': displayName,
                'updated_at': DateTime.now().toIso8601String(),
              });
            }
        } catch (e) {
            debugPrint('Error ensuring public profile: $e');
            // Continue anyway, join might work if trigger exists
        }

        // Interact after profile check
        await _crewService.joinGroupRide(widget.groupRide.id);

        
        // Add to local list
        // Best effort: Get name from metadata or email (matching default logic)
        String displayName = user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'Ciclista';
        
        final newPart = GroupRideParticipant(
           id: 'temp_${user.id}',
           userId: user.id,
           displayName: displayName,
           joinedAt: DateTime.now(),
           status: 'confirmed',
        );

        setState(() {
           _isParticipating = true;
           widget.groupRide.participants.add(newPart);
        });

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ti sei unito all\'uscita!')));
      }
      

      
      // Do NOT pop, stay on screen to show update
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
