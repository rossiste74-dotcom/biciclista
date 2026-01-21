import 'package:flutter/material.dart';
import '../models/track.dart';
import '../models/community_track.dart';
import '../services/track_service.dart';
import '../services/community_tracks_service.dart';
import 'track_detail_screen.dart';
import 'gpx_import_screen.dart';
import 'qr_scan_screen.dart';
import 'route_planner_screen.dart';

/// Routes Library Screen - "Percorsi" (Il tuo Laboratorio)
/// Two tabs: "Miei" (personal tracks) and "Community" (global catalog)
class RoutesLibraryScreen extends StatefulWidget {
  const RoutesLibraryScreen({super.key});

  @override
  State<RoutesLibraryScreen> createState() => _RoutesLibraryScreenState();
}

class _RoutesLibraryScreenState extends State<RoutesLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _trackService = TrackService();
  final _communityService = CommunityTracksService();

  List<Track> _myTracks = [];
  List<CommunityTrack> _communityTracks = [];
  bool _isLoadingMy = true;
  bool _isLoadingCommunity = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyTracks();
    _loadCommunityTracks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyTracks() async {
    // Only show loading indicator if list is empty
    if (_myTracks.isEmpty) setState(() => _isLoadingMy = true);
    
    try {
      // 1. Load local tracks immediately
      var tracks = await _trackService.getAllTracks();
      if (mounted) {
        setState(() {
          _myTracks = tracks;
          _isLoadingMy = false;
        });
      }

      // 2. Sync with cloud (background)
      await _trackService.syncTracks();

      // 3. Reload to show any new/updated tracks
      if (mounted) {
        tracks = await _trackService.getAllTracks();
        setState(() {
          _myTracks = tracks;
        });
      }
    } catch (e) {
      debugPrint('Error loading/syncing tracks: $e');
      if (mounted) {
        setState(() => _isLoadingMy = false);
        // Only show error if list is empty, otherwise just log sync error
        if (_myTracks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore caricamento: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadCommunityTracks() async {
    setState(() => _isLoadingCommunity = true);
    try {
      final tracks = await _communityService.getNewestTracks(limit: 50);
      if (mounted) {
        setState(() {
          _communityTracks = tracks;
          _isLoadingCommunity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCommunity = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore caricamento community: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: 'Miei'),
            Tab(icon: Icon(Icons.public), text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTracksTab(),
          _buildCommunityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'routes_add_fab',
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Carica File GPX'),
              subtitle: const Text('Estrai dati e percorso dal file'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GpxImportScreen()),
                ).then((result) {
                  if (result == true) _loadMyTracks();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scansiona QR Code'),
              subtitle: const Text('Importa percorso da un altro ciclista'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScanScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.draw),
              title: const Text('Disegna su Mappa'),
              subtitle: const Text('Crea traccia su mappa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutePlannerScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTracksTab() {
    if (_isLoadingMy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myTracks.isEmpty) {
      return _buildEmptyState(
        'Nessun Percorso',
        'Importa il tuo primo GPX per iniziare!',
        Icons.route_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyTracks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myTracks.length,
        itemBuilder: (context, index) {
          final track = _myTracks[index];
          return _buildTrackCard(
            track: track,
            isCommunity: false,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackDetailScreen(track: track),
                ),
              );
              if (result == true) _loadMyTracks();
            },
          );
        },
      ),
    );
  }

  Widget _buildCommunityTab() {
    if (_isLoadingCommunity) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_communityTracks.isEmpty) {
      return _buildEmptyState(
        'Nessun Percorso Community',
        'Il catalogo è vuoto. Sii il primo a condividere!',
        Icons.explore_off,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommunityTracks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _communityTracks.length,
        itemBuilder: (context, index) {
          final track = _communityTracks[index];
          return _buildCommunityTrackCard(track);
        },
      ),
    );
  }

  Widget _buildTrackCard({
    required Track track,
    required bool isCommunity,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      track.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildTerrainChip(track.terrainType),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${track.distance.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.terrain, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${track.elevation.toStringAsFixed(0)} m',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityTrackCard(CommunityTrack track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    track.trackName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (track.creatorName != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      'di ${track.creatorName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                _buildDifficultyChip(track.difficultyLevel),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${track.distance.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.terrain, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${track.elevation.toStringAsFixed(0)} m',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${track.usageCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await _communityService.saveTrackToLab(track.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Percorso salvato nei "Miei"! 🎉'),
                        ),
                      );
                      _loadMyTracks(); // Refresh my tracks
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Errore: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Salva nei Miei'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerrainChip(String terrainType) {
    final labels = ['Strada', 'Gravel', 'MTB', 'Misto'];
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple];
    
    int index = 0;
    switch (terrainType) {
      case 'road':
        index = 0;
        break;
      case 'gravel':
        index = 1;
        break;
      case 'mtb':
        index = 2;
        break;
      case 'mixed':
        index = 3;
        break;
    }

    return Chip(
      label: Text(
        labels[index],
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: colors[index].withOpacity(0.2),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    final colors = {
      'easy': Colors.green,
      'medium': Colors.orange,
      'hard': Colors.red,
      'expert': Colors.purple,
    };

    return Chip(
      label: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: colors[difficulty] ?? Colors.grey,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
