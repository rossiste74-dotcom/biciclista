import '../models/track.dart';
import '../models/community_track.dart';
// import '../services/community_tracks_service.dart'; // Circular dependency if not careful, but needed for import
import '../utils/gpx_optimizer.dart';
// import 'database_service.dart'; // No longer needed if we access Supabase directly, or we can use DB service for shared logic
import 'package:gpx/gpx.dart';
import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Track CRUD operations (Cloud Only)
class TrackService {
  // final _db = DatabaseService();
  // We use direct Supabase client for flexibility, or could add methods to DatabaseService.
  // Given Track complexity (GPX upload), keeping logic here is fine.
  final _supabase = Supabase.instance.client;
  final String _storageBucket = 'tracks';
  final String _table = 'personal_tracks';

  TrackService();

  String? get _userId => _supabase.auth.currentUser?.id;

  // ==================== CREATE ====================

  /// Create a new track and upload GPX
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
    double? asphaltPercent,
    double? gravelPercent,
    double? pathPercent,
    int? difficultyLevel,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    // 1. Upload GPX to Supabase Storage
    String? gpxUrl;
    final file = File(gpxFilePath);
    if (await file.exists()) {
      final fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}.gpx';
      try {
        await _supabase.storage
            .from(_storageBucket)
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        gpxUrl = fileName;
      } catch (e) {
        debugPrint('GPX Upload Error: $e');
        // Proceed? Or fail?
        // If we can't store the file, the track is useless.
        rethrow;
      }
    }

    // 2. Insert into DB
    final trackData = {
      'user_id': uid,
      'name': name,
      'description': description,
      'gpx_file_url': gpxUrl,
      'distance': distance,
      'elevation': elevation,
      'duration': duration,
      'terrain_type': terrainType,
      'region': region,
      'source': source,
      // 'community_track_id': communityTrackId, // Missing in DB
      'difficulty_level': difficultyLevel,
      'asphalt_percent': asphaltPercent,
      'gravel_percent': gravelPercent,
      'path_percent': pathPercent,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final res = await _supabase
        .from(_table)
        .insert(trackData)
        .select()
        .single();

    return _mapTrack(res);
  }

  /// Import track from community catalog
  Future<Track> importFromCommunity(CommunityTrack communityTrack) async {
    // 1. We need the GPX data.
    // If CommunityTrack has `gpxData` (JSON string), we convert to file and upload?
    // Or we copy from community storage if available?
    // Current CommunityTrack model has `gpxData` field string.

    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    String? gpxUrl;

    // Create a temp GPX file to upload to personal storage
    if (communityTrack.gpxData != null) {
      try {
        final gpx = GpxOptimizer.jsonToGpx(communityTrack.gpxData!);
        final gpxString = GpxWriter().asString(gpx, pretty: true);
        final fileName =
            '$uid/community_${communityTrack.id}_${DateTime.now().millisecondsSinceEpoch}.gpx';

        await _supabase.storage
            .from(_storageBucket)
            .uploadBinary(
              fileName,
              utf8.encode(gpxString),
              fileOptions: const FileOptions(
                contentType: 'application/gpx+xml',
              ),
            );
        gpxUrl = fileName;
      } catch (e) {
        debugPrint('Error uploading community GPX: $e');
      }
    }

    return await createTrack(
      name: communityTrack.trackName,
      description: communityTrack.description,
      gpxFilePath:
          '', // Ignored since we handled upload above, but function requires it.
      // Wait, createTrack handles upload from file. We should adjust createTrack or calling method.
      // Let's call insert directly here to avoid double upload logic.
      distance: communityTrack.distance,
      elevation: communityTrack.elevation,
      duration: communityTrack.duration,
      terrainType: communityTrack.trackType ?? 'road',
      region: communityTrack.region,
      source: 'community',
      communityTrackId: communityTrack.id,
    ).then((t) async {
      // Patch the gpxUrl if we uploaded it differently
      if (gpxUrl != null) {
        await _supabase
            .from(_table)
            .update({'gpx_file_url': gpxUrl})
            .eq('id', t.id!);
        t.gpxUrl = gpxUrl;
      }
      return t;
    });
  }

  // ==================== READ ====================

  /// Get all tracks (Cloud)
  Future<List<Track>> getAllTracks() async {
    final uid = _userId;
    if (uid == null) return [];

    final res = await _supabase
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return (res as List).map((m) => _mapTrack(m)).toList();
  }

  /// Get track by ID
  Future<Track?> getTrackById(String id) async {
    final data = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return _mapTrack(data);
  }

  Track _mapTrack(Map<String, dynamic> map) {
    final t = Track();
    t.id = map['id']?.toString();

    if (t.id == null) {
      debugPrint('CRITICAL: Track has no ID. Raw map keys: ${map.keys}');
    }

    t.userId = map['user_id'];
    t.name = map['name'] ?? 'Senza Nome';
    t.description = map['description'];
    t.gpxUrl = map['gpx_file_url'];

    // Safely parse doubles
    t.distance = _parseDouble(map['distance']);
    t.elevation = _parseDouble(map['elevation']);

    // Safely parse duration (int)
    if (map['duration'] is int) {
      t.duration = map['duration'];
    } else if (map['duration'] is String) {
      t.duration = int.tryParse(map['duration']);
    } else if (map['duration'] is double) {
      t.duration = (map['duration'] as double).toInt();
    }

    t.terrainType = map['terrain_type'] ?? 'road';
    t.region = map['region'];
    t.source = map['source'] ?? 'manual';

    t.communityTrackId = map['community_track_id']?.toString();
    t.difficultyLevel = map['difficulty_level'];
    t.asphaltPercent = _parseDouble(map['asphalt_percent']);
    t.gravelPercent = _parseDouble(map['gravel_percent']);
    t.pathPercent = _parseDouble(map['path_percent']);

    try {
      t.createdAt = DateTime.parse(map['created_at']);
      t.updatedAt = DateTime.parse(map['updated_at']);
    } catch (e) {
      t.createdAt = DateTime.now();
      t.updatedAt = DateTime.now();
    }

    return t;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Get tracks by terrain type
  Future<List<Track>> getTracksByTerrain(String terrainType) async {
    final uid = _userId;
    if (uid == null) return [];
    final res = await _supabase
        .from(_table)
        .select()
        .eq('user_id', uid)
        .eq('terrain_type', terrainType);
    return (res as List).map((m) => _mapTrack(m)).toList();
  }

  // ==================== UPDATE ====================

  /// Update track
  Future<void> updateTrack(Track track) async {
    if (track.id == null) return;

    await _supabase
        .from(_table)
        .update({
          'name': track.name,
          'description': track.description,
          'terrain_type': track.terrainType,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', track.id!);
  }

  // ==================== DELETE ====================

  /// Delete track
  Future<bool> deleteTrack(String trackId) async {
    // Check usages
    // We need to check PlannedRides usage.
    // DatabaseService handles planned rides.
    // We can query Supabase directly for planned_rides usage.

    try {
      final count = await _supabase
          .from('planned_rides')
          .select()
          .eq('track_id', trackId)
          .count(CountOption.exact);

      if (count.count > 0) {
        throw Exception(
          'Impossibile eliminare: traccia usata da ${count.count} uscit${count.count == 1 ? 'a' : 'e'}',
        );
      }
    } catch (e) {
      if (e.toString().contains('Impossibile eliminare')) rethrow;
      // If count fails, maybe proceed or log? Let's proceed carefully but log.
      debugPrint('Warning: Could not check usages: $e');
    }

    // Get track info to delete storage file
    final track = await getTrackById(trackId);
    if (track?.gpxUrl != null) {
      try {
        await _supabase.storage.from(_storageBucket).remove([track!.gpxUrl!]);
      } catch (e) {
        debugPrint('Error deleting GPX file: $e');
        // Continue to delete record even if file deletion fails
      }
    }

    await _supabase.from(_table).delete().eq('id', trackId);
    return true;
  }

  Future<void> deleteTrackAndUnlink(String trackId) async {
    // Unlink
    await _supabase
        .from('planned_rides')
        .update({'track_id': null})
        .eq('track_id', trackId);

    // Delete file
    final track = await getTrackById(trackId);
    if (track?.gpxUrl != null) {
      await _supabase.storage.from(_storageBucket).remove([track!.gpxUrl!]);
    }

    // Delete record
    await _supabase.from(_table).delete().eq('id', trackId);
  }

  // ==================== STATS ====================

  Future<int> getTotalTracksCount() async {
    final uid = _userId;
    if (uid == null) return 0;
    return await _supabase.from(_table).count().eq('user_id', uid);
  }

  Future<double> getTotalTracksDistance() async {
    // Use getAllTracks or RPC
    final tracks = await getAllTracks();
    return tracks.fold<double>(0.0, (sum, t) => sum + t.distance);
  }

  Future<Map<String, int>> getTrackCountByTerrain() async {
    final tracks = await getAllTracks();
    final stats = <String, int>{};
    for (final track in tracks) {
      stats[track.terrainType] = (stats[track.terrainType] ?? 0) + 1;
    }
    return stats;
  }

  // ==================== SYNC ====================
  // No longer needed
  Future<void> syncTracks() async {}

  // ==================== WATCH ====================
  Stream<void> watchTracks() => const Stream.empty();

  // ==================== Helper ====================

  /// Get downloadable URL for GPX
  Future<String?> getGpxUrl(Track track) async {
    if (track.gpxUrl == null) return null;
    try {
      return await _supabase.storage
          .from(_storageBucket)
          .createSignedUrl(track.gpxUrl!, 60 * 60);
    } catch (e) {
      debugPrint('Error signing GPX URL: $e');
      return null;
    }
  }
}
