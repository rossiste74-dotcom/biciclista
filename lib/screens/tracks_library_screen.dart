import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/track_service.dart';
import '../services/database_service.dart';
import '../models/planned_ride.dart';
import 'package:intl/intl.dart';
import 'explore_community_screen.dart';
import 'track_detail_screen.dart';

/// Tracks Library Screen - "I miei Percorsi"
class TracksLibraryScreen extends StatefulWidget {
  const TracksLibraryScreen({super.key});

  @override
  State<TracksLibraryScreen> createState() => _TracksLibraryScreenState();
}

class _TracksLibraryScreenState extends State<TracksLibraryScreen> {
  final _trackService = TrackService();
  final _db = DatabaseService();
  
  List<Track> _tracks = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, road, gravel, mtb, mixed

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);

    try {
      List<Track> tracks;
      if (_filter == 'all') {
        tracks = await _trackService.getAllTracks();
      } else {
        tracks = await _trackService.getTracksByTerrain(_filter);
      }

      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
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
    return Column(
      children: [
        // Filter chips
        _buildFilterChips(),

        // Tracks list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tracks.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadTracks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tracks.length,
                        itemBuilder: (context, index) => _buildTrackCard(_tracks[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tutte', 'all', Icons.route),
            const SizedBox(width: 8),
            _buildFilterChip('Strada', 'road', Icons.directions_bike),
            const SizedBox(width: 8),
            _buildFilterChip('Gravel', 'gravel', Icons.terrain),
            const SizedBox(width: 8),
            _buildFilterChip('MTB', 'mtb', Icons.landscape),
            const SizedBox(width: 8),
            _buildFilterChip('Misto', 'mixed', Icons.route_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
        _loadTracks();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna traccia',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Importa un GPX o cerca su Community',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(Track track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(track.terrainIcon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          track.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.route, size: 14),
                const SizedBox(width: 4),
                Text('${track.distance.toStringAsFixed(1)} km'),
                const SizedBox(width: 12),
                const Icon(Icons.terrain, size: 14),
                const SizedBox(width: 4),
                Text('${track.elevation.toStringAsFixed(0)} m'),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              track.terrainLabel,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'schedule':
                _showScheduleDialog(track);
                break;
              case 'edit':
                _editTrack(track);
                break;
              case 'delete':
                _deleteTrack(track);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'schedule',
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text('Pianifica'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Modifica'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Elimina', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackDetailScreen(track: track),
            ),
          );
          if (result == true) _loadTracks();
        },
      ),
    );
  }

  void _showScheduleDialog(Track track) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool isGroupRide = false;
    String? customName;

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
                  track.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${track.distance.toStringAsFixed(1)} km • ${track.elevation.toStringAsFixed(0)} m'),
                const Divider(height: 24),

                // Date picker
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Data'),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'it_IT').format(selectedDate)),
                  trailing: const Icon(Icons.edit),
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

                // Event type toggle
                SwitchListTile(
                  title: const Text('Uscita di Gruppo'),
                  subtitle: const Text('Condividi con la community'),
                  value: isGroupRide,
                  onChanged: (value) {
                    setDialogState(() => isGroupRide = value);
                  },
                ),

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
                await _scheduleRide(track, selectedDate, isGroupRide, customName);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Pianifica'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleRide(
    Track track,
    DateTime date,
    bool isGroupRide,
    String? customName,
  ) async {
    try {
      final ride = PlannedRide()
        ..rideDate = date
        ..rideName = customName
        ..trackId = track.id
        ..isGroupRide = isGroupRide
        ..distance = track.distance
        ..elevation = track.elevation
        ..gpxFilePath = track.gpxFilePath;

      // Link track
      ride.track.value = track;

      await _db.createPlannedRide(ride);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGroupRide
                  ? 'Uscita di gruppo pianificata!'
                  : 'Uscita personale pianificata!',
            ),
          ),
        );
        
        // TODO: If isGroupRide, sync to Supabase
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  void _editTrack(Track track) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modifica traccia in arrivo...')),
    );
  }

  Future<void> _deleteTrack(Track track) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Traccia'),
        content: Text('Vuoi eliminare "${track.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _trackService.deleteTrack(track.id);
        _loadTracks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Traccia eliminata')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: $e')),
          );
        }
      }
    }
  }
}
