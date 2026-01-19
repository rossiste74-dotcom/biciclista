import 'package:isar/isar.dart';
import '../models/track.dart';
import '../models/community_track.dart';
import '../utils/gpx_optimizer.dart';
import 'database_service.dart';
import 'package:gpx/gpx.dart';
import 'dart:io';

/// Service for managing Track CRUD operations
class TrackService {
  final _db = DatabaseService();

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
}
