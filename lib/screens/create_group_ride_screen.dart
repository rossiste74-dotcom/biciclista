import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/crew_service.dart';
import '../services/database_service.dart';
import '../services/community_tracks_service.dart';
import '../models/planned_ride.dart';
import '../models/saved_track.dart';
import 'explore_community_screen.dart';
import 'group_ride_detail_screen.dart';
import 'package:intl/intl.dart';

/// Screen to create a new group ride
class CreateGroupRideScreen extends StatefulWidget {
  const CreateGroupRideScreen({super.key});

  @override
  State<CreateGroupRideScreen> createState() => _CreateGroupRideScreenState();
}

class _CreateGroupRideScreenState extends State<CreateGroupRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _crewService = CrewService();
  final _db = DatabaseService();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingPointController = TextEditingController();
  
  DateTime _meetingDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _meetingTime = const TimeOfDay(hour: 9, minute: 0);
  String _difficulty = 'medium';
  bool _isPublic = true;
  bool _isLoading = false;
  
  // GPX Route selection
  PlannedRide? _selectedRoute;
  List<PlannedRide> _availableRoutes = [];
  List<SavedTrack> _savedTracks = [];
  final _communityService = CommunityTracksService();
  
  // Location Search
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadAvailableRoutes();
    _loadSavedTracks();
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }

    if (mounted) setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=5&language=it&format=json'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data['results'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Search failed: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }


  Future<void> _loadAvailableRoutes() async {
    try {
      final routes = await _db.getAllPlannedRides();
      setState(() {
        _availableRoutes = routes.where((r) => r.gpxFilePath != null).toList();
      });
    } catch (e) {
      debugPrint('Error loading routes: $e');
    }
  }

  Future<void> _loadSavedTracks() async {
    try {
      final saved = await _communityService.getMySavedTracks();
      setState(() {
        _savedTracks = saved;
      });
    } catch (e) {
      debugPrint('Error loading saved tracks: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    super.dispose();
  }

  Future<void> _createRide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final meetingDateTime = DateTime(
        _meetingDate.year,
        _meetingDate.month,
        _meetingDate.day,
        _meetingTime.hour,
        _meetingTime.minute,
      );

      double? lat;
      double? lon;
      
      if (_selectedRoute != null && (_selectedRoute!.latitude != null)) {
        // Priority: Track Start Point
        lat = _selectedRoute!.latitude;
        lon = _selectedRoute!.longitude;
      } else if (_selectedLocation != null) {
        // Fallback: Searched Location
        lat = _selectedLocation!['latitude'];
        lon = _selectedLocation!['longitude'];
      }

      final newRide = await _crewService.createGroupRide(
        rideName: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        meetingPoint: _meetingPointController.text.trim(),
        meetingLatitude: lat,
        meetingLongitude: lon,
        meetingTime: meetingDateTime,
        difficultyLevel: _difficulty,
        isPublic: _isPublic,
        // Add GPX data from selected route with explicit double conversion
        distance: _selectedRoute?.distance.toDouble(),
        elevation: _selectedRoute?.elevation.toDouble(),
        gpxFileUrl: _selectedRoute?.gpxFilePath,
      );

      if (mounted) {
        // Redirect directly to detail screen
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => GroupRideDetailScreen(groupRide: newRide)),
        ).then((_) {
           // If we pop back from detail, we might want to return true to previous screen?
           // But pushReplacement replaces this screen. 
           // Implementation nuance: pushReplacement returns a Future for the pushed route.
           // However, if the caller of CreateScreen wanted a result, they won't get it easily if we replace.
           // But 'Pop' only goes back.
           // Better UX: Create -> Detail -> (Back) -> List.
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uscita creata con successo!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Uscita di Gruppo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome uscita
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Uscita',
                hintText: 'es. Giro del Canalone',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci un nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrizione
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrizione (opzionale)',
                hintText: 'Racconta qualcosa sull\'uscita...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // GPX Route Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traccia Percorso',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedRoute == null)
                      ListTile(
                        leading: const Icon(Icons.route),
                        title: const Text('Nessuna traccia selezionata'),
                        subtitle: const Text('Tap per scegliere un percorso'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showRouteSelector,
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.route, color: Colors.green),
                        title: Text(_selectedRoute!.rideName ?? 'Senza nome'),
                        subtitle: Text(
                          '${_selectedRoute!.distance.toStringAsFixed(1)} km • '
                          '${_selectedRoute!.elevation.toStringAsFixed(0)} m',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _selectedRoute = null),
                        ),
                        onTap: _showRouteSelector,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Punto di incontro (Searchable)
            TextField(
              controller: _meetingPointController,
              decoration: InputDecoration(
                labelText: 'Punto di Incontro',
                hintText: 'Cerca indirizzo o città...',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: _isSearching 
                    ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) 
                    : null,
                helperText: _selectedLocation != null 
                    ? 'Coordinate trovate: ${_selectedLocation!['latitude']}, ${_selectedLocation!['longitude']}'
                    : 'Inserisci indirizzo per vedere la mappa',
                helperStyle: TextStyle(color: _selectedLocation != null ? Colors.green : null),
              ),
              onChanged: _searchLocation,
            ),
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _searchResults.map((res) {
                    return ListTile(
                      dense: true,
                      title: Text('${res['name']}, ${res['admin1'] ?? ''}'),
                      subtitle: Text(res['country'] ?? ''),
                      onTap: () {
                        setState(() {
                          _selectedLocation = res;
                          _meetingPointController.text = '${res['name']}, ${res['admin1'] ?? ''}';
                          _searchResults = [];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Data e ora
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data e Ora Incontro',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(DateFormat('dd MMMM yyyy', 'it_IT').format(_meetingDate)),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _meetingDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _meetingDate = date);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(_meetingTime.format(context)),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _meetingTime,
                        );
                        if (time != null) {
                          setState(() => _meetingTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Difficoltà
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difficoltà',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'easy', label: Text('Facile')),
                        ButtonSegment(value: 'medium', label: Text('Medio')),
                        ButtonSegment(value: 'hard', label: Text('Duro')),
                        ButtonSegment(value: 'expert', label: Text('Esperto')),
                      ],
                      selected: {_difficulty},
                      onSelectionChanged: (Set<String> selected) {
                        setState(() => _difficulty = selected.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Visibilità
            SwitchListTile(
              title: const Text('Uscita Pubblica'),
              subtitle: Text(_isPublic 
                  ? 'Visibile a tutti gli utenti' 
                  : 'Visibile solo ai tuoi amici'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            const SizedBox(height: 24),

            // Create button
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _createRide,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Creazione...' : 'Crea Uscita'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Seleziona Traccia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Explore catalog button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExploreCommunityScreen(),
                      ),
                    );
                    // Reload saved tracks after returning
                    _loadSavedTracks();
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('Esplora Catalogo Community'),
                ),
              ),
            ),

            // Tabs or sections
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Saved tracks section
                  if (_savedTracks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Tracce Salvate',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ..._savedTracks.map((saved) => ListTile(
                      leading: const Icon(Icons.bookmark, color: Colors.amber),
                      title: Text(saved.displayName),
                      subtitle: saved.distance != null
                          ? Text(
                              '${saved.distance!.toStringAsFixed(1)} km • '
                              '${saved.elevation?.toStringAsFixed(0) ?? 0} m',
                            )
                          : null,
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                      onTap: () {
                        // TODO: Handle community track selection
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funzionalità in arrivo...'),
                          ),
                        );
                      },
                    )),
                    const Divider(),
                  ],

                  // Local routes section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Le Mie Tracce Locali',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (_availableRoutes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.route_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Nessuna traccia locale',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._availableRoutes.map((route) => ListTile(
                      leading: const Icon(Icons.route),
                      title: Text(route.rideName ?? 'Senza nome'),
                      subtitle: Text(
                        '${route.distance.toStringAsFixed(1)} km • '
                        '${route.elevation.toStringAsFixed(0)} m • '
                        '${DateFormat('dd/MM/yyyy').format(route.rideDate)}',
                      ),
                      trailing: _selectedRoute?.id == route.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedRoute = route;
                          // Auto-fill name if empty
                          if (_nameController.text.isEmpty) {
                            _nameController.text = route.rideName ?? '';
                          }
                        });
                        Navigator.pop(context);
                      },
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
