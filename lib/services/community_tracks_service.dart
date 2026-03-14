import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import '../models/community_track.dart';
import '../models/saved_track.dart';
import '../utils/gpx_optimizer.dart';
import 'supabase_config.dart';
import 'package:gpx/gpx.dart';

/// Service for managing community tracks catalog
class CommunityTracksService {
  SupabaseClient get _supabase => SupabaseConfig.client;

  // ==================== PUBLISH & MANAGE TRACKS ====================

  /// Find track by creator and name (for linking deletion)
  Future<CommunityTrack?> findTrackByCreatorAndName(
    String userId,
    String trackName,
  ) async {
    try {
      final response = await _supabase
          .from('community_tracks')
          .select('id')
          .eq('creator_id', userId)
          .eq('track_name', trackName)
          .maybeSingle();

      if (response == null) return null;
      // Fetch full object or just return dummy with ID?
      // Better fetch basic info to be safe, but ID is enough for deletion.
      // Let's re-fetch or construct. But response only has ID if I select ID.
      // Let's just return a partial object or string?
      // Changed return type to Future<String?>? No, safer to return object.
      // Let's just fetch *
      final fullResponse = await _supabase
          .from('community_tracks')
          .select()
          .eq('creator_id', userId)
          .eq('track_name', trackName)
          .limit(1)
          .maybeSingle();

      if (fullResponse == null) return null;
      return CommunityTrack.fromJson(fullResponse);
    } catch (e) {
      return null;
    }
  }

  /// Safe delete (only if not used)
  Future<bool> safeDeleteTrack(String trackId) async {
    try {
      // 1. Check usages (Saved Tracks)
      final savedCount = await _supabase
          .from('saved_tracks')
          .count(CountOption.exact)
          .eq('track_id', trackId);

      if (savedCount > 0) return false;

      // 2. Check usages (Group Rides - implied by crew_service logic or planned_rides?
      // Note: Group rides usually copy data or link. If they link, we should check.
      // Assuming 'community_rides' or similar link?
      // In this app, rides are in 'group_rides' table (via CrewService).
      // Let's check 'group_rides'.
      final ridesCount = await _supabase
          .from('group_rides')
          .count(CountOption.exact)
          .eq('community_track_id', trackId);

      if (ridesCount > 0) return false;

      // 3. Delete
      await deleteTrack(trackId);
      return true;
    } catch (e) {
      debugPrint('Safe delete failed: $e');
      return false;
    }
  }

  /// Publish track to community catalog (with GPX optimization)
  Future<CommunityTrack> publishTrack({
    required String trackName,
    String? description,
    required Gpx gpx,
    required double distance,
    double elevation = 0,
    int? duration,
    String difficultyLevel = 'medium',
    String? region,
    String? trackType,
    bool isPublic = true,
    double epsilon = 0.0001, // RDP tolerance
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Optimize GPX with RDP
      final optimized = GpxOptimizer.optimizeGpx(gpx, epsilon: epsilon);
      final gpxJson = GpxOptimizer.gpxToJson(optimized.gpx);

      // Extract start coordinates
      double? startLat;
      double? startLon;
      if (gpx.trks.isNotEmpty &&
          gpx.trks.first.trksegs.isNotEmpty &&
          gpx.trks.first.trksegs.first.trkpts.isNotEmpty) {
        final firstPoint = gpx.trks.first.trksegs.first.trkpts.first;
        startLat = firstPoint.lat;
        startLon = firstPoint.lon;
      }

      final data = {
        'creator_id': user.id,
        'track_name': trackName,
        'description': description,
        'gpx_data': gpxJson,
        'distance': distance,
        'elevation': elevation,
        'duration': duration,
        'difficulty_level': difficultyLevel,
        'region': region,
        'track_type': trackType,
        'is_public': isPublic,
        'start_latitude': startLat,
        'start_longitude': startLon,
      };

      final response = await _supabase
          .from('community_tracks')
          .insert(data)
          .select()
          .single();

      return CommunityTrack.fromJson(response);
    } catch (e) {
      throw Exception('Error publishing track: $e');
    }
  }

  /// Update track
  Future<void> updateTrack(String trackId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('community_tracks')
          .update(updates)
          .eq('id', trackId);
    } catch (e) {
      throw Exception('Error updating track: $e');
    }
  }

  /// Delete track
  Future<void> deleteTrack(String trackId) async {
    try {
      await _supabase.from('community_tracks').delete().eq('id', trackId);
    } catch (e) {
      throw Exception('Error deleting track: $e');
    }
  }

  // ==================== SEARCH & FILTER ====================

  /// Get popular tracks
  Future<List<CommunityTrack>> getPopularTracks({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('community_tracks')
          .select('*, profiles(name, avatar_data)')
          .eq('is_public', true)
          .neq('creator_id', _supabase.auth.currentUser?.id ?? '')
          .order('usage_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => CommunityTrack.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching popular tracks: $e');
    }
  }

  /// Get highest rated tracks
  Future<List<CommunityTrack>> getTopRatedTracks({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('community_tracks')
          .select('*, profiles(name)')
          .eq('is_public', true)
          .neq('creator_id', _supabase.auth.currentUser?.id ?? '')
          .gt('total_ratings', 0)
          .order('avg_rating', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => CommunityTrack.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching top rated tracks: $e');
    }
  }

  /// Get newest tracks
  Future<List<CommunityTrack>> getNewestTracks({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('community_tracks')
          .select('*, profiles(name)')
          .eq('is_public', true)
          .neq('creator_id', _supabase.auth.currentUser?.id ?? '')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => CommunityTrack.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching newest tracks: $e');
    }
  }

  /// Get tracks near location (using Haversine distance)
  Future<List<CommunityTrack>> getNearbyTracks({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      // Get all public tracks with coordinates
      final response = await _supabase
          .from('community_tracks')
          .select('*, profiles(name)')
          .eq('is_public', true)
          .neq('creator_id', _supabase.auth.currentUser?.id ?? '')
          .not('start_latitude', 'is', null)
          .not('start_longitude', 'is', null);

      final tracks = (response as List)
          .map((json) => CommunityTrack.fromJson(json))
          .toList();

      // Filter by distance (client-side for now)
      final nearby = tracks.where((track) {
        if (track.startLatitude == null || track.startLongitude == null) {
          return false;
        }
        final distance = _calculateDistance(
          latitude,
          longitude,
          track.startLatitude!,
          track.startLongitude!,
        );
        return distance <= radiusKm;
      }).toList();

      // Sort by distance
      nearby.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.startLatitude!,
          a.startLongitude!,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.startLatitude!,
          b.startLongitude!,
        );
        return distA.compareTo(distB);
      });

      return nearby.take(limit).toList();
    } catch (e) {
      throw Exception('Error fetching nearby tracks: $e');
    }
  }

  /// Search tracks by name, region, difficulty
  Future<List<CommunityTrack>> searchTracks({
    String? query,
    String? difficulty,
    String? region,
    String? trackType,
    double? minDistance,
    double? maxDistance,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('community_tracks')
          .select('*, profiles(name)')
          .eq('is_public', true)
          .neq('creator_id', _supabase.auth.currentUser?.id ?? '');

      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('track_name', '%$query%');
      }

      if (difficulty != null) {
        queryBuilder = queryBuilder.eq('difficulty_level', difficulty);
      }

      if (region != null) {
        queryBuilder = queryBuilder.eq('region', region);
      }

      if (trackType != null) {
        queryBuilder = queryBuilder.eq('track_type', trackType);
      }

      if (minDistance != null) {
        queryBuilder = queryBuilder.gte('distance', minDistance);
      }

      if (maxDistance != null) {
        queryBuilder = queryBuilder.lte('distance', maxDistance);
      }

      final response = await queryBuilder.limit(limit);

      return (response as List)
          .map((json) => CommunityTrack.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error searching tracks: $e');
    }
  }

  // ==================== SAVED TRACKS ====================

  /// Save track to user's lab (creates reference only)
  Future<SavedTrack> saveTrackToLab(
    String trackId, {
    String? customName,
    String? notes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        'user_id': user.id,
        'track_id': trackId,
        'custom_name': customName,
        'notes': notes,
      };

      final response = await _supabase
          .from('saved_tracks')
          .insert(data)
          .select()
          .single();

      return SavedTrack.fromJson(response);
    } catch (e) {
      throw Exception('Error saving track: $e');
    }
  }

  /// Remove saved track
  Future<void> removeSavedTrack(String savedTrackId) async {
    try {
      await _supabase.from('saved_tracks').delete().eq('id', savedTrackId);
    } catch (e) {
      throw Exception('Error removing saved track: $e');
    }
  }

  /// Get user's saved tracks (with track details)
  Future<List<SavedTrack>> getMySavedTracks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('saved_tracks')
          .select('''
            *,
            community_tracks!inner(
              track_name,
              distance,
              elevation,
              difficulty_level,
              gpx_data
            )
          ''')
          .eq('user_id', user.id)
          .order('saved_at', ascending: false);

      return (response as List).map((json) {
        // Flatten joined data
        final trackData = json['community_tracks'];
        return SavedTrack.fromJson({
          ...json,
          'track_name': trackData['track_name'],
          'distance': trackData['distance'],
          'elevation': trackData['elevation'],
          'difficulty_level': trackData['difficulty_level'],
          'gpx_data': trackData['gpx_data'] is Map
              ? jsonEncode(trackData['gpx_data'])
              : trackData['gpx_data'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Error fetching saved tracks: $e');
    }
  }

  /// Check if track is saved
  Future<bool> isTrackSaved(String trackId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('saved_tracks')
          .select('id')
          .eq('user_id', user.id)
          .eq('track_id', trackId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ==================== RATINGS ====================

  /// Rate a track
  Future<TrackRating> rateTrack(
    String trackId,
    int rating, {
    String? comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final data = {
        'user_id': user.id,
        'track_id': trackId,
        'rating': rating,
        'comment': comment,
      };

      final response = await _supabase
          .from('track_ratings')
          .upsert(data, onConflict: 'user_id,track_id')
          .select()
          .single();

      return TrackRating.fromJson(response);
    } catch (e) {
      throw Exception('Error rating track: $e');
    }
  }

  /// Get ratings for a track
  Future<List<TrackRating>> getTrackRatings(String trackId) async {
    try {
      final response = await _supabase
          .from('track_ratings')
          .select()
          .eq('track_id', trackId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TrackRating.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== HELPER FUNCTIONS ====================

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radiusin km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
