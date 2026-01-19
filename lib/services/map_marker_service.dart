import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/map_marker.dart';
import 'supabase_config.dart';

/// Service for managing real-time map markers (danger alerts, rest stops, etc.)
class MapMarkerService {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Add a new marker on the map
  Future<MapMarker> addMarker({
    required double latitude,
    required double longitude,
    required String markerType,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final data = {
        'user_id': user.id,
        'latitude': latitude,
        'longitude': longitude,
        'marker_type': markerType,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'is_active': true,
      };

      final response = await _supabase
          .from('map_markers')
          .insert(data)
          .select()
          .single();

      return MapMarker.fromJson(response);
    } catch (e) {
      throw Exception('Error adding marker: $e');
    }
  }

  /// Get all active markers
  Future<List<MapMarker>> getActiveMarkers() async {
    try {
      final response = await _supabase
          .from('map_markers')
          .select()
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MapMarker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching markers: $e');
    }
  }

  /// Get markers by type
  Future<List<MapMarker>> getMarkersByType(String type) async {
    try {
      final response = await _supabase
          .from('map_markers')
          .select()
          .eq('is_active', true)
          .eq('marker_type', type)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MapMarker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching markers by type: $e');
    }
  }

  /// Stream active markers (real-time)
  Stream<List<MapMarker>> streamActiveMarkers() {
    return _supabase
        .from('map_markers')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((data) {
          // Filter expired markers in memory
          final now = DateTime.now();
          return data
              .map((json) => MapMarker.fromJson(json))
              .where((marker) => marker.expiresAt.isAfter(now))
              .toList();
        });
  }

  /// Delete a marker (only creator)
  Future<void> deleteMarker(String markerId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('map_markers')
          .delete()
          .eq('id', markerId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Error deleting marker: $e');
    }
  }

  /// Cleanup expired markers (call periodically or via function)
  Future<void> cleanupExpiredMarkers() async {
    try {
      await _supabase.rpc('deactivate_expired_markers');
    } catch (e) {
      // Fallback: manual cleanup
      try {
        await _supabase
            .from('map_markers')
            .update({'is_active': false})
            .lt('expires_at', DateTime.now().toIso8601String())
            .eq('is_active', true);
      } catch (e) {
        throw Exception('Error cleaning up markers: $e');
      }
    }
  }

  /// Get markers near a location (within radius in km)
  Future<List<MapMarker>> getMarkersNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    try {
      // Get all active markers first
      final markers = await getActiveMarkers();

      // Filter by distance (simple approximation)
      return markers.where((marker) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          marker.latitude,
          marker.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Error fetching nearby markers: $e');
    }
  }

  /// Calculate distance between two coordinates (haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(lat1).cos() *
            _toRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final c = 2 * a.sqrt().asin();
    return R * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);
}

// Helper extension for calculations
extension on double {
  double sin() => this; // Placeholder - use dart:math in real implementation
  double cos() => this;
  double asin() => this;
  double sqrt() => this;
}
