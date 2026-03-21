import 'package:flutter/material.dart';
import '../models/track.dart';
import '../models/community_track.dart';
import '../services/track_service.dart';
import '../services/community_tracks_service.dart';
import 'track_detail_screen.dart';
import 'gpx_import_screen.dart';
import 'qr_scan_screen.dart';
import 'route_planner_screen.dart';
import '../widgets/difficulty_badge.dart';
import '../models/terrain_analysis.dart';
import 'dart:convert';
import '../models/user_avatar_config.dart';
import '../widgets/avatar/avatar_preview.dart';
import '../widgets/route_map_widget.dart';
import '../widgets/elevation_profile_widget.dart';
import '../utils/gpx_optimizer.dart';
import 'package:latlong2/latlong.dart';

/// Routes Library Screen - "Percorsi" (Il tuo Laboratorio)
/// Two tabs: "Miei" (personal tracks) and "Community" (global catalog)
class RoutesLibraryScreen extends StatefulWidget {
  const RoutesLibraryScreen({super.key});

  @override
  State<RoutesLibraryScreen> createState() => _RoutesLibraryScreenState();
}

class _RoutesLibraryScreenState extends State<RoutesLibraryScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _loadMyTracks();
    _loadCommunityTracks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes to foreground or when returning to this screen
    if (state == AppLifecycleState.resumed) {
      _loadMyTracks();
    }
  }

  Future<void> _loadMyTracks() async {
    // Only show loading indicator if list is empty
    if (_myTracks.isEmpty) setState(() => _isLoadingMy = true);

    try {
      // 1. Fetch Personal Tracks
      var personalTracks = await _trackService.getAllTracks();

      // 2. Fetch Saved Community Tracks
      var savedTracks = await _communityService.getMySavedTracks();

      // 3. Convert SavedTrack -> Track
      var convertedSavedTracks = savedTracks.map((s) {
        return Track()
          ..id = s
              .trackId // Use original track ID
          ..name = s.displayName
          ..description = s
              .notes // Use notes as description or keep null
          ..distance = s.distance ?? 0
          ..elevation = s.elevation ?? 0
          ..createdAt = s
              .savedAt // Use saved date for sorting
          ..updatedAt = s.savedAt
          ..source = 'community_saved'
          ..communityTrackId = s.trackId
          ..difficultyLevel = s.difficultyLevel != null
              ? int.tryParse(s.difficultyLevel!)
              : null // Approximate mapping
          ..communityGpxData = s.gpxData; // Important: Pass JSON data
      }).toList();

      // 4. Merge and Sort
      var allTracks = [...personalTracks, ...convertedSavedTracks];
      allTracks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _myTracks = allTracks;
          _isLoadingMy = false;
        });
      }

      // 5. Sync (Background) - Personal tracks only
      await _trackService.syncTracks();
    } catch (e) {
      debugPrint('Error loading/syncing tracks: $e');
      if (mounted) {
        setState(() => _isLoadingMy = false);
        // Only show error if list is empty
        if (_myTracks.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Errore caricamento: $e')));
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
        children: [_buildMyTracksTab(), _buildCommunityTab()],
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
                  MaterialPageRoute(
                    builder: (context) => const GpxImportScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const RoutePlannerScreen(),
                  ),
                ).then((result) {
                  if (result == true) _loadMyTracks();
                });
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
                  if (track.difficultyLevel != null) ...[
                    const SizedBox(width: 16),
                    DifficultyIndicator(
                      difficulty: difficultyFromLevel(track.difficultyLevel!),
                    ),
                  ],
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
      child: InkWell(
        onTap: () => _showTrackDetail(track),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCreatorAvatar(track),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.trackName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (track.creatorName != null)
                          Text(
                            'di ${track.creatorName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
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
      label: Text(labels[index], style: const TextStyle(fontSize: 12)),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackDetail(CommunityTrack track) {
    // Parse GPX data if available
    List<Map<String, double>> routePoints = [];
    List<double> elevationProfile = [];
    LatLng? startPoint;
    LatLng? endPoint;
    LatLng? middlePoint;

    if (track.gpxData != null) {
      try {
        final gpx = GpxOptimizer.jsonToGpx(track.gpxData!);
        if (gpx.trks.isNotEmpty && gpx.trks.first.trksegs.isNotEmpty) {
          final points = gpx.trks.first.trksegs.first.trkpts;

          routePoints = points
              .map((p) => {'lat': p.lat!, 'lng': p.lon!})
              .toList();

          elevationProfile = points
              .where((p) => p.ele != null)
              .map((p) => p.ele!)
              .toList();

          if (routePoints.isNotEmpty) {
            startPoint = LatLng(
              routePoints.first['lat']!,
              routePoints.first['lng']!,
            );
            endPoint = LatLng(
              routePoints.last['lat']!,
              routePoints.last['lng']!,
            );
            middlePoint = LatLng(
              routePoints[routePoints.length ~/ 2]['lat']!,
              routePoints[routePoints.length ~/ 2]['lng']!,
            );
          }
        }
      } catch (e) {
        debugPrint('Error parsing GPX for preview: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets
              .zero, // Zero padding for map to reach edges if wanted, or keep standard
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Preview (Top)
              if (routePoints.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: RouteMapWidget(
                      routePoints: routePoints,
                      startPoint: startPoint,
                      endPoint: endPoint,
                      middlePoint: middlePoint,
                      distance: track.distance,
                      elevation: track.elevation,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.trackName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        _buildCreatorAvatar(track),
                      ],
                    ),
                    if (track.creatorName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        child: Text(
                          'Creato da: ${track.creatorName}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),

                    // Stats Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailStat(
                          Icons.straighten,
                          '${track.distance.toStringAsFixed(1)} km',
                          'Distanza',
                        ),
                        _buildDetailStat(
                          Icons.terrain,
                          '${track.elevation.toStringAsFixed(0)} m',
                          'Dislivello',
                        ),
                        _buildDetailStat(
                          Icons.timer,
                          _formatDuration(track.duration),
                          'Durata',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Elevation Profile
                    if (elevationProfile.isNotEmpty) ...[
                      const Text(
                        'Altimetria',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: ElevationProfileWidget(
                          elevationProfile: elevationProfile,
                          distanceKm: track.distance,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Divider(),
                    const SizedBox(height: 16),
                    if (track.description != null &&
                        track.description!.isNotEmpty) ...[
                      Text(
                        'Descrizione',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(track.description!),
                      const SizedBox(height: 24),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await _communityService.saveTrackToLab(track.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Percorso salvato nei "Miei"! 🎉',
                                  ),
                                ),
                              );
                              _loadMyTracks();
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--:--';
    final duration = Duration(seconds: seconds);
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  Widget _buildCreatorAvatar(CommunityTrack track) {
    if (track.creatorAvatarData != null) {
      try {
        final config = UserAvatarConfig.fromJson(
          jsonDecode(track.creatorAvatarData!),
        );
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ClipOval(child: AvatarPreview(config: config)),
        );
      } catch (e) {
        debugPrint('Error parsing avatar: $e');
      }
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
