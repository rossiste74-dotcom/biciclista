import 'package:flutter/material.dart';
import '../models/community_track.dart';
import '../services/community_tracks_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../models/user_avatar_config.dart';
import '../widgets/avatar/avatar_preview.dart';

/// Explore Community Tracks screen
class ExploreCommunityScreen extends StatefulWidget {
  const ExploreCommunityScreen({super.key});

  @override
  State<ExploreCommunityScreen> createState() => _ExploreCommunityScreenState();
}

class _ExploreCommunityScreenState extends State<ExploreCommunityScreen>
    with SingleTickerProviderStateMixin {
  final _service = CommunityTracksService();
  late TabController _tabController;

  List<CommunityTrack> _tracks = [];
  bool _isLoading = true;
  Position? _currentPosition;

  // Filters
  String? _selectedDifficulty;
  String? _selectedRegion;
  double? _minDistance;
  double? _maxDistance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _getCurrentLocation();
    _loadTracks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadTracks();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
      if (_tabController.index == 1) {
        _loadTracks(); // Reload nearby tracks
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);

    try {
      List<CommunityTrack> tracks;

      switch (_tabController.index) {
        case 0: // Popolari
          tracks = await _service.getPopularTracks();
          break;
        case 1: // Vicine a te
          if (_currentPosition != null) {
            tracks = await _service.getNearbyTracks(
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
              radiusKm: 50,
            );
          } else {
            tracks = [];
          }
          break;
        case 2: // Nuove
          tracks = await _service.getNewestTracks();
          break;
        default:
          tracks = [];
      }

      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esplora Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Popolari', icon: Icon(Icons.trending_up)),
            Tab(text: 'Vicine a te', icon: Icon(Icons.near_me)),
            Tab(text: 'Nuove', icon: Icon(Icons.fiber_new)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tracks.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadTracks,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tracks.length,
                itemBuilder: (context, index) =>
                    _buildTrackCard(_tracks[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    if (_tabController.index == 1 && _currentPosition == null) {
      message = 'Attiva GPS per vedere tracce vicine';
      icon = Icons.location_off;
    } else {
      message = 'Nessuna traccia disponibile';
      icon = Icons.route_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
          if (_tabController.index == 1 && _currentPosition == null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackCard(CommunityTrack track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showTrackDetail(track),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and rating
            // Header with name and rating
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creator Info
                  Row(
                    children: [
                      _buildCreatorAvatar(track),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          track.creatorName ?? 'Utente Sconosciuto',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      if (track.totalRatings > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${track.avgRating.toStringAsFixed(1)} (${track.totalRatings})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Track Name
                  Text(
                    track.trackName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (track.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      track.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStatChip(
                    Icons.route,
                    '${track.distance.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.terrain,
                    '${track.elevation.toStringAsFixed(0)} m',
                  ),
                  const SizedBox(width: 8),
                  _buildDifficultyBadge(track.difficultyLevel),
                  const Spacer(),
                  if (track.usageCount > 0)
                    Row(
                      children: [
                        const Icon(Icons.bookmark, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${track.usageCount}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Region and type
            if (track.region != null || track.trackType != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (track.region != null)
                      Chip(
                        label: Text(track.region!),
                        avatar: const Icon(Icons.location_on, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (track.trackType != null)
                      Chip(
                        label: Text(track.trackType!),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        label = 'Facile';
        break;
      case 'medium':
        color = Colors.orange;
        label = 'Medio';
        break;
      case 'hard':
        color = Colors.red;
        label = 'Difficile';
        break;
      case 'expert':
        color = Colors.purple;
        label = 'Esperto';
        break;
      default:
        color = Colors.grey;
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showTrackDetail(CommunityTrack track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.trackName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (track.description != null) ...[
                Text(track.description!),
                const SizedBox(height: 16),
              ],
              // Add save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _saveTrack(track),
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Salva nel mio Lab'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTrack(CommunityTrack track) async {
    try {
      await _service.saveTrackToLab(track.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Traccia salvata!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Widget _buildCreatorAvatar(CommunityTrack track) {
    if (track.creatorAvatarData != null) {
      try {
        final config = UserAvatarConfig.fromJson(
          jsonDecode(track.creatorAvatarData!),
        );
        return Container(
          width: 32,
          height: 32,
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
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showFilters() {
    // TODO: Implement filters dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtri'),
        content: const Text('Filtri in arrivo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
