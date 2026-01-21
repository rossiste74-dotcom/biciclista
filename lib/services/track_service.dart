import 'package:isar/isar.dart';
import '../models/track.dart';
import '../models/community_track.dart';
import '../utils/gpx_optimizer.dart';
import 'database_service.dart';
import 'package:gpx/gpx.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Track CRUD operations
class TrackService {
  final _db = DatabaseService();
  final _supabase = Supabase.instance.client;
  final String _storageBucket = 'tracks';
  final String _table = 'personal_tracks';

  // ==================== CREATE ====================

  /// Create a new track
  Future<Track> createTrack({
    required String name,
    String? description,
    required String gpxFilePath,
    required double distance,
    required double elevation,
    int? duration,
    String terrainType = 'road',
    String? region,
    String source = 'manual',
    String? communityTrackId,
  }) async {
    final track = Track()
      ..name = name
      ..description = description
      ..gpxFilePath = gpxFilePath
      ..distance = distance
      ..elevation = elevation
      ..duration = duration
      ..terrainType = terrainType
      ..region = region
      ..source = source
      ..communityTrackId = communityTrackId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final id = await _db.isar.writeTxn(() async {
      return await _db.isar.tracks.put(track);
    });

    track.id = id;
    
    // Trigger sync in background if online
    if (source == 'manual' || source == 'community') {
      _uploadTrack(track).catchError((e) {
        debugPrint('Auto-sync failed for track $id: $e');
      });
    }

    return track;
  }

  /// Import track from community catalog
  Future<Track> importFromCommunity(CommunityTrack communityTrack) async {
    // TODO: Download and save GPX locally if needed
    return await createTrack(
      name: communityTrack.trackName,
      description: communityTrack.description,
      gpxFilePath: '', // TODO: Download GPX from gpxData
      distance: communityTrack.distance,
      elevation: communityTrack.elevation,
      duration: communityTrack.duration,
      terrainType: communityTrack.trackType ?? 'road',
      region: communityTrack.region,
      source: 'community',
      communityTrackId: communityTrack.id,
    );
  }

  // ==================== READ ====================

  /// Get all tracks
  Future<List<Track>> getAllTracks() async {
    return await _db.isar.tracks
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get track by ID
  Future<Track?> getTrackById(int id) async {
    return await _db.isar.tracks.get(id);
  }

  /// Get tracks by terrain type
  Future<List<Track>> getTracksByTerrain(String terrainType) async {
    return await _db.isar.tracks
        .filter()
        .terrainTypeEqualTo(terrainType)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get tracks by source
  Future<List<Track>> getTracksBySource(String source) async {
    return await _db.isar.tracks
        .filter()
        .sourceEqualTo(source)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get community-imported tracks
  Future<List<Track>> getCommunityTracks() async {
    return await getTracksBySource('community');
  }

  /// Search tracks by name
  Future<List<Track>> searchTracks(String query) async {
    if (query.isEmpty) return getAllTracks();

    return await _db.isar.tracks
        .filter()
        .nameContains(query, caseSensitive: false)
        .or()
        .descriptionContains(query, caseSensitive: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // ==================== UPDATE ====================

  /// Update track
  Future<void> updateTrack(Track track) async {
    track.updatedAt = DateTime.now();
    await _db.isar.writeTxn(() async {
      await _db.isar.tracks.put(track);
    });
  }

  // ==================== DELETE ====================

  /// Delete track
  /// Warning: Check for PlannedRide references before deleting!
  Future<bool> deleteTrack(int trackId) async {
    // Check if track is used by any PlannedRides
    final allRides = await _db.getAllPlannedRides();
    final usedCount = allRides.where((r) => r.trackId == trackId).length;

    if (usedCount > 0) {
      throw Exception(
        'Impossibile eliminare: traccia usata da $usedCount uscit${usedCount == 1 ? 'a' : 'e'}',
      );
    }

    return await _db.isar.writeTxn(() async {
      return await _db.isar.tracks.delete(trackId);
    });
  }

  /// Force delete track and unlink from PlannedRides
  Future<void> deleteTrackAndUnlink(int trackId) async {
    await _db.isar.writeTxn(() async {
      // Get linked rides
      final allRides = await _db.getAllPlannedRides();
      final linkedRides = allRides.where((r) => r.trackId == trackId).toList();

      // Unlink from planned rides
      for (final ride in linkedRides) {
        ride.trackId = null;
        ride.track.value = null;
        await _db.updatePlannedRide(ride);
      }

      // Delete track
      await _db.isar.tracks.delete(trackId);
    });
  }

  // ==================== STATS ====================

  /// Get total number of tracks
  Future<int> getTotalTracksCount() async {
    return await _db.isar.tracks.count();
  }

  /// Get total distance of all tracks
  Future<double> getTotalTracksDistance() async {
    final tracks = await getAllTracks();
    return tracks.fold<double>(0.0, (sum, track) => sum + track.distance);
  }

  /// Get stats by terrain type
  Future<Map<String, int>> getTrackCountByTerrain() async {
    final tracks = await getAllTracks();
    final stats = <String, int>{};

    for (final track in tracks) {
      stats[track.terrainType] = (stats[track.terrainType] ?? 0) + 1;
    }

    return stats;
  }

  // ==================== WATCH ====================

  /// Watch for changes in tracks
  Stream<void> watchTracks() {
    return _db.isar.tracks.watchLazy();
  }

  // ==================== SYNC ====================

  /// Synchronize tracks (Bidirectional)
  Future<void> syncTracks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Upload local tracks that haven't been synced
      final unsyncedTracks = await _db.isar.tracks
          .filter()
          .supabaseIdIsNull()
          .findAll();

      for (final track in unsyncedTracks) {
        if (track.source == 'manual' || track.source == 'community') {
          await _uploadTrack(track);
        }
      }

      // 2. Download remote tracks that aren't local
      final remoteTracksResponse = await _supabase
          .from(_table)
          .select()
          .eq('user_id', user.id);
      
      final List<dynamic> remoteTracks = remoteTracksResponse as List<dynamic>;
      
      for (final remote in remoteTracks) {
        final String remoteId = remote['id'];
        
        // Check if exists locally
        final existing = await _db.isar.tracks
            .filter()
            .supabaseIdEqualTo(remoteId)
            .findFirst();

        if (existing == null) {
          await _downloadAndCreateTrack(remote);
        }
      }

      // 3. Import "Saved Tracks" (Bookmarks) from Community
      await _importSavedCommunityTracks();
      
    } catch (e) {
      debugPrint('Sync failed: $e');
      rethrow;
    }
  }

  /// Import tracks from 'saved_tracks' table (Community bookmarks)
  Future<void> _importSavedCommunityTracks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('saved_tracks')
          .select('''
            *,
            community_tracks (
              track_name,
              description,
              gpx_data,
              distance,
              elevation,
              duration,
              difficulty_level,
              region,
              track_type
            )
          ''')
          .eq('user_id', user.id);

      final List<dynamic> savedTracks = response as List<dynamic>;

      for (final saved in savedTracks) {
        final String communityTrackId = saved['track_id'];
        
        // Check if already imported locally
        final existing = await _db.isar.tracks
            .filter()
            .communityTrackIdEqualTo(communityTrackId)
            .findFirst();

        if (existing == null) {
          final communityParams = saved['community_tracks'];
          if (communityParams == null) continue; // Track might be deleted

          // Convert JSON GPX to File
          final gpxData = communityParams['gpx_data'];
          if (gpxData == null) continue;

          final gpx = GpxOptimizer.jsonToGpx(gpxData);
          final gpxString = GpxWriter().asString(gpx, pretty: true);
          
          final dir = await getApplicationDocumentsDirectory();
          final filename = 'community_${communityTrackId}.gpx';
          final localFile = File('${dir.path}/tracks/$filename');
          
          if (!await localFile.parent.exists()) {
            await localFile.parent.create(recursive: true);
          }
          await localFile.writeAsString(gpxString);

          // Create local Track
          final track = Track()
            ..name = saved['custom_name'] ?? communityParams['track_name']
            ..description = saved['notes'] ?? communityParams['description']
            ..gpxFilePath = localFile.path
            ..distance = (communityParams['distance'] as num).toDouble()
            ..elevation = (communityParams['elevation'] as num).toDouble()
            ..duration = communityParams['duration']
            ..terrainType = communityParams['track_type'] ?? 'road'
            ..region = communityParams['region']
            ..source = 'community'
            ..communityTrackId = communityTrackId
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

            // Note: We leave supabaseId null so it gets uploaded to personal_tracks 
            // as a distinct "my copy" in the next sync

          await _db.isar.writeTxn(() async {
            await _db.isar.tracks.put(track);
          });
        }
      }
    } catch (e) {
      debugPrint('Error importing saved community tracks: $e');
      // Don't block main sync
    }
  }

  /// Upload a single track to Supabase
  Future<void> _uploadTrack(Track track) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    // Ensure GPX file exists
    final file = File(track.gpxFilePath!);
    if (!await file.exists()) {
       debugPrint('GPX file missing for track ${track.id}');
       return;
    }
    
    try {
      // 1. Upload GPX to Storage
      final fileName = '${track.id}_${DateTime.now().millisecondsSinceEpoch}.gpx';
      final storagePath = '${user.id}/$fileName';
      
      await _supabase.storage.from(_storageBucket).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      // 2. Insert into database
      final trackData = {
        'user_id': user.id,
        'name': track.name,
        'description': track.description,
        'gpx_file_url': storagePath,
        'distance': track.distance,
        'elevation': track.elevation,
        'duration': track.duration,
        'terrain_type': track.terrainType,
        'region': track.region,
        'source': track.source,
        'created_at': track.createdAt.toIso8601String(),
        'updated_at': track.updatedAt.toIso8601String(),
      };
      
      final response = await _supabase
          .from(_table)
          .insert(trackData)
          .select()
          .single();
          
      // 3. Update local record with Supabase ID
      track.supabaseId = response['id'];
      track.gpxUrl = storagePath;
      track.lastSyncedAt = DateTime.now();
      
      await updateTrack(track);
      
    } catch (e) {
      debugPrint('Error uploading track ${track.id}: $e');
      rethrow;
    }
  }

  /// Download track data and GPX, then save locally
  Future<void> _downloadAndCreateTrack(Map<String, dynamic> remote) async {
    try {
      final storagePath = remote['gpx_file_url'];
      if (storagePath == null) return;
      
      // 1. Download GPX File
      final fileBytes = await _supabase.storage
          .from(_storageBucket)
          .download(storagePath);
          
      // Save to local directory
      final dir = await getApplicationDocumentsDirectory();
      final filename = p.basename(storagePath);
      final localFile = File('${dir.path}/tracks/$filename');
      
      if (!await localFile.parent.exists()) {
        await localFile.parent.create(recursive: true);
      }
      
      await localFile.writeAsBytes(fileBytes);
      
      // 2. Create local Track record
      final track = Track()
        ..name = remote['name']
        ..description = remote['description']
        ..gpxFilePath = localFile.path
        ..distance = (remote['distance'] as num).toDouble()
        ..elevation = (remote['elevation'] as num).toDouble()
        ..duration = remote['duration']
        ..terrainType = remote['terrain_type'] ?? 'road'
        ..region = remote['region']
        ..source = remote['source'] ?? 'manual'
        ..createdAt = DateTime.parse(remote['created_at'])
        ..updatedAt = DateTime.parse(remote['updated_at'])
        ..supabaseId = remote['id']
        ..gpxUrl = storagePath
        ..lastSyncedAt = DateTime.now();

      await _db.isar.writeTxn(() async {
        await _db.isar.tracks.put(track);
      });
      
    } catch (e) {
      debugPrint('Error downloading track ${remote['id']}: $e');
    }
  }
}
